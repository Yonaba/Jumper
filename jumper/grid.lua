--- The Grid class
-- @module grid
--
-- Implementation of the `grid` class.
-- The `grid` is a implicit graph which represents the 2D 
-- world map layout on which the `pathfinder` object will run.
-- During a search, the `pathfinder` object needs to save some critical values. These values are cached within each `node`
-- object, and the whole set of nodes are tight inside the `grid` object itself.

if (...) then
  local _PATH = (...):gsub('%.grid$','')
  local Node = require (_PATH .. '.core.node')
	
  local pairs = pairs
  local assert = assert
  local next = next
  local floor = math.floor
	local otype = type

  ---------------------------------------------------------------------
  -- Private utilities
	
	-- Is i and integer ?
	local isInt = function(i)
		return otype(i) =='number' and floor(i)==i
	end
	
	-- Override type to report integers
	local type = function(v)
		if isInt(v) then return 'int' end
		return otype(v)
	end
	
	-- Real count of for values in an array
	local size = function(t)
		local count = 0
		for k,v in pairs(t) do count = count+1 end
		return count
	end

	-- Checks array contents
	local check_contents = function(t,...)
		local n_count = size(t)
		if n_count < 1 then return false end
		local init_count = t[0] and 0 or 1
		local n_count = (t[0] and n_count-1 or n_count)
		local types = {...}
		if types then types = table.concat(types) end
		for i=init_count,n_count,1 do
			if not t[i] then return false end
			if types then
				if not types:match(type(t[i])) then return false end
			end
		end
		return true
	end

	-- Checks if m is a regular map
  local function isMap(m)
		if not check_contents(m, 'table') then return false end
		local lsize = size(m[next(m)])
		for k,v in pairs(m) do
			if not check_contents(m[k], 'string', 'int') then return false end
			if size(v)~=lsize then return false end
		end
		return true
  end

  -- Is arg a valid string map
  local function isStringMap(s)
    if type(m) ~= 'string' then return false end
    local w
    for row in s:gmatch('[^\n\r]+') do
      if not row then return false end
      w = w or #row
      if w ~= #row then return false end
    end
    return true
  end

  -- Parses a map
  local function parseStringMap(str)
		local map = {}
		local w, h
    for line in str:gmatch('[^\n\r]+') do
      if line then
        w = not w and #line or w
        assert(#line == w, 'Error parsing map, rows must have the same size!')
        h = (h or 0) + 1
        map[h] = {}
        for char in line:gmatch('.') do 
					map[h][#map[h]+1] = char 
				end
      end
    end
    return map
  end

  -- Postprocessing : Get map bounds
  local function getBounds(map)
    local min_bound_x, max_bound_x
    local min_bound_y, max_bound_y
      for y in pairs(map) do
        min_bound_y = not min_bound_y and y or (y<min_bound_y and y or min_bound_y)
        max_bound_y = not max_bound_y and y or (y>max_bound_y and y or max_bound_y)
        for x in pairs(map[y]) do
          min_bound_x = not min_bound_x and x or (x<min_bound_x and x or min_bound_x)
          max_bound_x = not max_bound_x and x or (x>max_bound_x and x or max_bound_x)
        end
      end
    return min_bound_x,max_bound_x,min_bound_y,max_bound_y
  end

  -- Preprocessing
  local function buildGrid(map)
    local min_bound_x, max_bound_x
    local min_bound_y, max_bound_y

    local nodes = {}
      for y in pairs(map) do
        min_bound_y = not min_bound_y and y or (y<min_bound_y and y or min_bound_y)
        max_bound_y = not max_bound_y and y or (y>max_bound_y and y or max_bound_y)
        nodes[y] = {}
        for x in pairs(map[y]) do
          min_bound_x = not min_bound_x and x or (x<min_bound_x and x or min_bound_x)
          max_bound_x = not max_bound_x and x or (x>max_bound_x and x or max_bound_x)
          nodes[y][x] = Node:new(x,y)
        end
      end
    return nodes,
			 (min_bound_x or 0), (max_bound_x or 0),
			 (min_bound_y or 0), (max_bound_y or 0)
  end

  -- Checks if a value is out of and interval [lowerBound,upperBound]
  local function outOfRange(i,lowerBound,upperBound)
    return (i< lowerBound or i > upperBound)
  end

  -- Offsets for straights moves
  local straightOffsets = {
    {x = 1, y = 0} --[[W]], {x = -1, y =  0}, --[[E]]
    {x = 0, y = 1} --[[S]], {x =  0, y = -1}, --[[N]]
  }

  -- Offsets for diagonal moves
  local diagonalOffsets = {
    {x = -1, y = -1} --[[NW]], {x = 1, y = -1}, --[[NE]]
    {x = -1, y =  1} --[[SW]], {x = 1, y =  1}, --[[SE]]
  }

	--- The `Grid` class.<br/>
	-- This class is callable.
	-- Therefore,_ <code>Grid(...)</code> _acts as a shortcut to_ <code>Grid:new(...)</code>.
	-- @type Grid
  local Grid = {}
  Grid.__index = Grid

  -- Specialized grids
  local PreProcessGrid = setmetatable({},Grid)
  local PostProcessGrid = setmetatable({},Grid)
  PreProcessGrid.__index = PreProcessGrid
  PostProcessGrid.__index = PostProcessGrid	
  PreProcessGrid.__call = function (self,x,y)
    return self:getNodeAt(x,y)
  end
  PostProcessGrid.__call = function (self,x,y,create)
    if create then return self:getNodeAt(x,y) end
    return self._nodes[y] and self._nodes[y][x]
  end

  --- Inits a new `grid`
  -- @class function
  -- @tparam table|string map A collision map - (2D array) with consecutive indices (starting at 0 or 1) 
	-- or a `string` with line-break chars (<code>\n</code> or <code>\r</code>) as row delimiters.
  -- @tparam[opt] bool memorySafe When __true__, returns an empty `grid` instance, so that
	-- later on, indexing a non-cached `node` will cause it to be created on purpose.
	-- Defaults to __false__ when omitted.
  -- @treturn grid a new `grid` instance
	-- @usage
	-- -- A simple 3x3 grid
	-- local myGrid = Grid:new({{0,0,0},{0,0,0},{0,0,0}})
	--
	-- -- A memory-safe 3x3 grid
	-- myGrid = Grid('000\n000\n000', true)
  function Grid:new(map, memorySafe)
		map = type(map)=='string' and parseStringMap(map) or map
    assert(isMap(map) or isStringMap(map),('Bad argument #1. Not a valid map'))
    assert(type(memorySafe) == 'boolean' or not memorySafe,
      ('Bad argument #2. Expected \'boolean\', got %s.'):format(type(memorySafe)))
    if memorySafe then
      return PostProcessGrid:new(map,walkable)
    end
    return PreProcessGrid:new(map,walkable)
  end

  --- Checks if `node` at [x,y] is __walkable__.
	-- Will check if `node` at location [x,y] both *exists* on the collision map and *is walkable*
  -- @class function
  -- @tparam int x the x-location of the node
  -- @tparam int y the y-location of the node
  -- @tparam[opt] string|int|func walkable the value for walkable locations in the collision map array (see @{Grid:new}).
	-- Defaults to __false__ when omitted.
  -- If this parameter is a function, it should be prototyped as __f(value)__ and return a `boolean`:
  -- __true__ when value matches a __walkable__ `node`, __false__ otherwise. If this parameter is not given
  -- while location [x,y] __is valid__, this actual function returns __true__.
  -- @treturn bool __true__ if `node` exists and is __walkable__, __false__ otherwise
	-- @usage 
	-- print(myGrid:isWalkableAt(2,3)) --> always true
	-- print(myGrid:isWalkableAt(2,3,0)) --> true if node at [2,3] value is 0
	--
  function Grid:isWalkableAt(x, y, walkable)
    local nodeValue = self._map[y] and self._map[y][x]
    if nodeValue then
      if not walkable then return true end
    else 
			return false
    end
    if self._eval then return walkable(nodeValue) end
    return (nodeValue == walkable)
  end

  --- Returns the `grid` width.
  -- @class function
  -- @treturn int the `grid` width
	-- @usage print(myGrid:getWidth())
  function Grid:getWidth()
    return self._width
  end

  --- Returns the `grid` height.
  -- @class function
  -- @treturn int the `grid` height
	-- @usage print(myGrid:getHeight())
  function Grid:getHeight()
     return self._height
  end

  --- Returns the collision map.
  -- @class function
  -- @treturn map the collision map (see @{Grid:new})
	-- @usage local map = myGrid:getMap()	
  function Grid:getMap()
    return self._map
  end

  --- Returns the set of nodes.
  -- @class function
  -- @treturn {{node,...},...} an array of nodes
	-- @usage local nodes = myGrid:getNodes()		
  function Grid:getNodes()
    return self._nodes
  end

  --- Returns the `grid` bounds. Returned values corresponds to the upper-left 
	-- and lower-right coordinates (in tile units) of the actual `grid` instance.
  -- @class function
  -- @treturn int the upper-left corner x-coordinate
  -- @treturn int the upper-left corner y-coordinate
  -- @treturn int the lower-right corner x-coordinate
  -- @treturn int the lower-right corner y-coordinate
	-- @usage local left_x, left_y, right_x, right_y = myGrid:getBounds()
	function Grid:getBounds()
		return self._min_bound_x, self._min_bound_y,self._max_bound_x, self._max_bound_y
	end
	
  --- Returns neighbours. The returned value is an array of __walkable__ nodes neighbouring a given `node`.
  -- @class function
  -- @tparam node node a given `node`
  -- @tparam[opt] string|int|func walkable the value for walkable locations in the collision map array (see @{Grid:new}).
	-- Defaults to __false__ when omitted.
  -- @tparam[optchain] bool allowDiagonal when __true__, allows adjacent nodes are included (8-neighbours). 
	-- Defaults to __false__ when omitted.
  -- @tparam[optchain] bool tunnel When __true__, allows the `pathfinder` to tunnel through walls when heading diagonally.
	-- Defaults to __false__ when omitted.
  -- @treturn {node,...} an array of nodes neighbouring a given node
	-- @usage
	-- local aNode = myGrid:getNodeAt(5,6)
	-- local neighbours = myGrid:getNeighbours(aNode, 0, true)
  function Grid:getNeighbours(node, walkable, allowDiagonal, tunnel)
		local neighbours = {}
    for i = 1,#straightOffsets do
      local n = self:getNodeAt(
        node._x + straightOffsets[i].x,
        node._y + straightOffsets[i].y
      )
      if n and self:isWalkableAt(n._x, n._y, walkable) then
        neighbours[#neighbours+1] = n
      end
    end

    if not allowDiagonal then return neighbours end
		
		tunnel = not not tunnel
    for i = 1,#diagonalOffsets do
      local n = self:getNodeAt(
        node._x + diagonalOffsets[i].x,
        node._y + diagonalOffsets[i].y
      )
      if n and self:isWalkableAt(n._x, n._y, walkable) then
				if tunnel then
					neighbours[#neighbours+1] = n
				else
					local skipThisNode = false
					local n1 = self:getNodeAt(node._x+diagonalOffsets[i].x, node._y)
					local n2 = self:getNodeAt(node._x, node._y+diagonalOffsets[i].y)
					if ((n1 and n2) and not self:isWalkableAt(n1._x, n1._y, walkable) and not self:isWalkableAt(n2._x, n2._y, walkable)) then
						skipThisNode = true
					end
					if not skipThisNode then neighbours[#neighbours+1] = n end
				end
      end
    end

    return neighbours
  end

  --- Nodes iterator. Iterates on every single node
  -- in the `grid`. Passing __lx, ly, ex, ey__ arguments will iterate
  -- only on nodes inside the bounding-rectangle delimited by those given coordinates.
  -- @class function
  -- @tparam[opt] int lx the leftmost x-coordinate of the rectangle. Default to the `grid` leftmost x-coordinate (see @{Grid:getBounds}).
  -- @tparam[optchain] int ly the topmost y-coordinate of the rectangle. Default to the `grid` topmost y-coordinate (see @{Grid:getBounds}).
  -- @tparam[optchain] int ex the rightmost x-coordinate of the rectangle. Default to the `grid` rightmost x-coordinate (see @{Grid:getBounds}).
  -- @tparam[optchain] int ey the bottom-most y-coordinate of the rectangle. Default to the `grid` bottom-most y-coordinate (see @{Grid:getBounds}).
  -- @treturn node a `node` on the collision map, upon each iteration step
  -- @treturn int the iteration count
	-- @usage
	-- for node, count in myGrid:iter() do
	--   print(node:getX(), node:getY(), count)
	-- end
  function Grid:iter(lx,ly,ex,ey)
    local min_x = lx or self._min_bound_x
    local min_y = ly or self._min_bound_y
    local max_x = ex or self._max_bound_x
    local max_y = ey or self._max_bound_y

    local x, y
    y = min_y
    return function()
      x = not x and min_x or x+1
      if x > max_x then
        x = min_x
        y = y+1
      end
      if y > max_y then
        y = nil
      end
      return self._nodes[y] and self._nodes[y][x] or self:getNodeAt(x,y)
    end
  end

  --- Each transformation. Calls the given function on each `node` in the `grid`,
	-- passing the `node` as the first argument to function __f__.
  -- @class function
  -- @tparam func f a function prototyped as __f(node,...)__
  -- @tparam[opt] vararg ... args to be passed to function __f__
	-- @treturn grid self (the calling `grid` itself, can be chained)
	-- @usage
	-- local function printNode(node)
	--   print(node:getX(), node:getY())
	-- end
	-- myGrid:each(printNode)
  function Grid:each(f,...)
    for node in self:iter() do f(node,...) end
		return self
  end

  --- Each (in range) transformation. Calls a function on each `node` in the range of a rectangle of cells,
	-- passing the `node` as the first argument to function __f__.
  -- @class function
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle
  -- @tparam func f a function prototyped as __f(node,...)__
  -- @tparam[opt] vararg ... args to be passed to function __f__
	-- @treturn grid self (the calling `grid` itself, can be chained)	
	-- @usage
	-- local function printNode(node)
	--   print(node:getX(), node:getY())
	-- end
	-- myGrid:eachRange(1,1,8,8,printNode)
  function Grid:eachRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do f(node,...) end
		return self
  end

  --- Map transformation.
	-- Calls function __f(node,...)__ on each `node` in a given range, passing the `node` as the first arg to function __f__ and replaces
	-- it with the returned value. Therefore, the function should return a `node`.
  -- @class function
  -- @tparam func f a function prototyped as __f(node,...)__
  -- @tparam[opt] vararg ... args to be passed to function __f__
	-- @treturn grid self (the calling `grid` itself, can be chained)	
	-- @usage
	-- local function nothing(node)
	--   return node
	-- end
	-- myGrid:imap(nothing)	
  function Grid:imap(f,...)
    for node in self:iter() do
      node = f(node,...)
    end
		return self
  end

  --- Map in range transformation. 
	-- Calls function __f(node,...)__ on each `node` in a rectangle range, passing the `node` as the first argument to the function and replaces
	-- it with the returned value. Therefore, the function should return a `node`. 
	-- @class function
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle
  -- @tparam func f a function prototyped as __f(node,...)__
  -- @tparam[opt] vararg ... args to be passed to function __f__
	-- @treturn grid self (the calling `grid` itself, can be chained)	
	-- @usage
	-- local function nothing(node)
	--   return node
	-- end
	-- myGrid:imap(1,1,6,6,nothing)		
  function Grid:imapRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do
      node = f(node,...)
    end
		return self
  end

  -- Specialized grids
  -- Inits a preprocessed grid
  function PreProcessGrid:new(map)
    local newGrid = {}
    newGrid._map = map
    newGrid._nodes, newGrid._min_bound_x, newGrid._max_bound_x, newGrid._min_bound_y, newGrid._max_bound_y = buildGrid(newGrid._map)
    newGrid._width = (newGrid._max_bound_x-newGrid._min_bound_x)+1
    newGrid._height = (newGrid._max_bound_y-newGrid._min_bound_y)+1
    return setmetatable(newGrid,PreProcessGrid)
  end

  -- Inits a postprocessed grid
  function PostProcessGrid:new(map)
    local newGrid = {}
    newGrid._map = map
    newGrid._nodes = {}
    newGrid._min_bound_x, newGrid._max_bound_x, newGrid._min_bound_y, newGrid._max_bound_y = getBounds(newGrid._map)
    newGrid._width = (newGrid._max_bound_x-newGrid._min_bound_x)+1
    newGrid._height = (newGrid._max_bound_y-newGrid._min_bound_y)+1
    return setmetatable(newGrid,PostProcessGrid)
  end

  --- Returns the `node` at location [x,y].
  -- @class function
  -- @name Grid:getNodeAt
  -- @tparam int x the x-coordinate coordinate
  -- @tparam int y the y-coordinate coordinate
  -- @treturn node a `node`
	-- @usage local aNode = myGrid:getNodeAt(2,2)
	
  -- Gets the node at location <x,y> on a preprocessed grid
  function PreProcessGrid:getNodeAt(x,y)
    return self._nodes[y] and self._nodes[y][x] or nil
  end

  -- Gets the node at location <x,y> on a postprocessed grid
  function PostProcessGrid:getNodeAt(x,y)
    if not x or not y then return end
    if outOfRange(x,self._min_bound_x,self._max_bound_x) then return end
    if outOfRange(y,self._min_bound_y,self._max_bound_y) then return end
    if not self._nodes[y] then self._nodes[y] = {} end
    if not self._nodes[y][x] then self._nodes[y][x] = Node:new(x,y) end
    return self._nodes[y][x]
  end

  return setmetatable(Grid,{
    __call = function(self,...)
      return self:new(...)
    end
  })

end