--- <strong>The <code>grid</code> class API</strong>.
--
-- Implementation of a `grid` class, which represents the 2D map (graph) on which a `pathfinder` will perform.
--
-- During a search, the pathfinder evaluates __costs values__ for each node being processed, in order to
-- select, after each step of iteration, what node should be expanded next to reach the target
-- optimally. Those values are cached within an array of nodes inside the `grid` object.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module jumper.grid

--- @usage
local usage = [[
-- Usage Example
-- First, set a collision map
local map = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
local Grid = require ("jumper.grid") -- The grid class

-- Creates a grid object
local grid = Grid(map)
]]

if (...) then
  local _PATH = (...):gsub('%.grid$','')
  local pairs = pairs
  local assert = assert
  local next = next
  local floor = math.floor
	local otype = type
  local Node = require (_PATH .. '.core.node')

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

  ---------------------------------------------------------------------
  --- The `grid` class
  -- @class table
  -- @name grid
  -- @field width The grid width
  -- @field height The grid height
  -- @field map A reference to the collision map
  -- @field nodes A 2D array of nodes, each node matching a cell on the collision map
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
    return self.nodes[y] and self.nodes[y][x]
  end

  --- Inits a new `grid` object
  -- @class function
  -- @name grid:new
  -- @tparam table|string map A collision map - (2D array) with consecutive integer indices or a string with line-break symbol as a row delimiter.
  -- @tparam[optchain] bool processOnDemand whether or not caching nodes in the internal grid should be processed on-demand
  -- @treturn grid a new `grid` object
  function Grid:new(map, processOnDemand)
		map = type(map)=='string' and parseStringMap(map) or map
    assert(isMap(map) or isStringMap(map),('Bad argument #1. Not a valid map'))
    assert(type(processOnDemand) == 'boolean' or not processOnDemand,
      ('Bad argument #2. Expected \'boolean\', got %s.'):format(type(processOnDemand)))

    if processOnDemand then
      return PostProcessGrid:new(map,walkable)
    end
    return PreProcessGrid:new(map,walkable)
  end

  --- Checks walkability. Tests if `node` [x,y] exists on the collision map and is walkable
  -- @class function
  -- @name grid:isWalkableAt
  -- @tparam int x the x-coordinate of the node
  -- @tparam int y the y-coordinate of the node
  -- @tparam string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean:
  -- `true` when value matches a *walkable* node, `false` otherwise. If this parameter is not given and
  -- node [x,y] exists, this function return `true`.
  -- @treturn bool `true` if the node exist and is walkable, `false` otherwise
  function Grid:isWalkableAt(x, y, walkable)
    local nodeValue = self.map[y] and self.map[y][x]
    if nodeValue then
      if not walkable then return true end
    else 
			return false
    end
    if self.__eval then return walkable(nodeValue) end
    return (nodeValue == walkable)
  end

  --- Gets the `grid` width.
  -- @class function
  -- @name grid:getWidth
  -- @treturn int the `grid` object width
  function Grid:getWidth()
    return self.width
  end

  --- Gets the `grid` height.
  -- @class function
  -- @name grid:getHeight
  -- @treturn int the `grid` object height
  function Grid:getHeight()
     return self.height
  end

  --- Gets the collision map.
  -- @class function
  -- @name grid:getMap
  -- @treturn {{value},...} the collision map previously passed to the `grid` object on initalization
  function Grid:getMap()
    return self.map
  end

  --- Gets the `grid` nodes.
  -- @class function
  -- @name grid:getNodes
  -- @treturn {{node},...} the `grid` nodes
  function Grid:getNodes()
    return self.nodes
  end

  --- Returns the neighbours of a given `node` on a `grid`
  -- @class function
  -- @name grid:getNeighbours
  -- @tparam node node `node` object
  -- @tparam string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean:
  -- `true` when value matches a *walkable* node, `false` otherwise.
  -- @tparam[opt] bool allowDiagonal whether or not adjacent nodes (8-directions moves) are allowed
  -- @tparam[optchain] bool tunnel Whether or not the pathfinder can tunnel though walls diagonally
  -- @treturn {node,...} an array of nodes neighbouring a passed-in node on the collision map
  function Grid:getNeighbours(node, walkable, allowDiagonal, tunnel)
		local neighbours = {}
    for i = 1,#straightOffsets do
      local n = self:getNodeAt(
        node.x + straightOffsets[i].x,
        node.y + straightOffsets[i].y
      )
      if n and self:isWalkableAt(n.x, n.y, walkable) then
        neighbours[#neighbours+1] = n
      end
    end

    if not allowDiagonal then return neighbours end
		
		tunnel = not not tunnel
    for i = 1,#diagonalOffsets do
      local n = self:getNodeAt(
        node.x + diagonalOffsets[i].x,
        node.y + diagonalOffsets[i].y
      )
      if n and self:isWalkableAt(n.x, n.y, walkable) then
				if tunnel then
					neighbours[#neighbours+1] = n
				else
					local skipThisNode = false
					local n1 = self:getNodeAt(node.x+diagonalOffsets[i].x, node.y)
					local n2 = self:getNodeAt(node.x, node.y+diagonalOffsets[i].y)
					if ((n1 and n2) and not self:isWalkableAt(n1.x, n1.y, walkable) and not self:isWalkableAt(n2.x, n2.y, walkable)) then
						skipThisNode = true
					end
					if not skipThisNode then neighbours[#neighbours+1] = n end
				end
      end
    end

    return neighbours
  end

  --- Iterates on nodes on the grid. When given no args, will iterate on every single node
  -- on the grid, in case the grid is pre-processed. Passing `lx, ly, ex, ey` args will iterate
  -- on nodes inside a bounding-rectangle delimited by those coordinates.
  -- @class function
  -- @name grid:iter
  -- @tparam[opt] int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam[optchain] int ly the topmost y-coordinate of the rectangle
  -- @tparam[optchain] int ex the rightmost x-coordinate of the rectangle
  -- @tparam[optchain] int ey the bottom-most y-coordinate of the rectangle
  -- @treturn node a node on the collision map, upon each iteration step
  function Grid:iter(lx,ly,ex,ey)
    local min_x = lx or self.min_bound_x
    local min_y = ly or self.min_bound_y
    local max_x = ex or self.max_bound_x
    local max_y = ey or self.max_bound_y

    local x, y
    y = min_y
    return function()
      x = not x and min_x or x+1
      if x>max_x then
        x = min_x
        y = y+1
      end
      if y > max_y then
        y = nil
      end
      return self.nodes[y] and self.nodes[y][x] or self:getNodeAt(x,y)
    end
  end

  --- Each transformation. Executes a function on each `node` in the `grid`, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:each
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`
  function Grid:each(f,...)
    for node in self:iter() do f(node,...) end
  end

  --- Each in range transformation. Executes a function on each `node` in the range of a rectangle of cells, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:eachRange
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`
  function Grid:eachRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do f(node,...) end
  end

  --- Map transformation. Maps function `f(node,...)` on each `node` in a given range, passing the `node` as the first arg to function `f`. The passed-in function should return a `node` object.
  -- @class function
  -- @name grid:imap
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`
  function Grid:imap(f,...)
    for node in self:iter() do
      node = f(node,...)
    end
  end

  --- Map in range transformation. Maps `f(node,...)` on each `nod`e in the range of a rectangle of cells, passing the `node` as the first arg to function `f`. The passed-in function should return a `node` object.
  -- @class function
  -- @name grid:imapRange
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`
  function Grid:imapRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do
      node = f(node,...)
    end
  end


  -- Specialized grids
  -- Inits a preprocessed grid
  function PreProcessGrid:new(map)
    local newGrid = {}
    newGrid.map = map
    newGrid.nodes, newGrid.min_bound_x, newGrid.max_bound_x, newGrid.min_bound_y, newGrid.max_bound_y = buildGrid(newGrid.map)
    newGrid.width = (newGrid.max_bound_x-newGrid.min_bound_x)+1
    newGrid.height = (newGrid.max_bound_y-newGrid.min_bound_y)+1
    return setmetatable(newGrid,PreProcessGrid)
  end

  -- Inits a postprocessed grid
  function PostProcessGrid:new(map)
    local newGrid = {}
    newGrid.map = map
    newGrid.nodes = {}
    newGrid.min_bound_x, newGrid.max_bound_x, newGrid.min_bound_y, newGrid.max_bound_y = getBounds(newGrid.map)
    newGrid.width = (newGrid.max_bound_x-newGrid.min_bound_x)+1
    newGrid.height = (newGrid.max_bound_y-newGrid.min_bound_y)+1
    return setmetatable(newGrid,PostProcessGrid)
  end

  --- Returns the `node`[x,y] on a `grid`.
  -- @class function
  -- @name grid:getNodeAt
  -- @tparam int x the x-coordinate coordinate
  -- @tparam int y the y-coordinate coordinate
  -- @treturn node a `node` object
  -- Gets the node at location <x,y> on a preprocessed grid
  function PreProcessGrid:getNodeAt(x,y)
    return self.nodes[y] and self.nodes[y][x] or nil
  end

  -- Gets the node at location <x,y> on a postprocessed grid
  function PostProcessGrid:getNodeAt(x,y)
    if not x or not y then return end
    if outOfRange(x,self.min_bound_x,self.max_bound_x) then return end
    if outOfRange(y,self.min_bound_y,self.max_bound_y) then return end
    if not self.nodes[y] then self.nodes[y] = {} end
    if not self.nodes[y][x] then self.nodes[y][x] = Node:new(x,y) end
    return self.nodes[y][x]
  end

  return setmetatable(Grid,{
    __call = function(self,...)
      return self:new(...)
    end
  })

end


--[[
Copyright (c) 2012 Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]