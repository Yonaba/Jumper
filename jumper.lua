-- Defining core modules

local setmetatable, getmetatable = setmetatable, getmetatable

------------------------------  Binary Heaps (local) ------------------------------

local floor = math.floor

-- Lookup for value in a table
local indexOf = function(t,v)
  for i = 1,#t do
    if t[i] == v then return i end
  end
  return nil
end

-- Default comparison function
local function f_min(a,b) 
  return a < b 
end

-- Percolates up
local function percolate_up(heap, index)
  if index == 1 then return end
  local pIndex
  if index <= 1 then return end
  if index%2 == 0 then
    pIndex =  index/2
  else pIndex = (index-1)/2
  end
  if not heap.sort(heap.__heap[pIndex], heap.__heap[index]) then
    heap.__heap[pIndex], heap.__heap[index] = 
      heap.__heap[index], heap.__heap[pIndex]
    percolate_up(heap, pIndex)
  end
end

-- Percolates down
local function percolate_down(heap,index)
  local lfIndex,rtIndex,minIndex
  lfIndex = 2*index
  rtIndex = lfIndex + 1
  if rtIndex > heap.size then
    if lfIndex > heap.size then return
    else minIndex = lfIndex  end
  else
    if heap.sort(heap.__heap[lfIndex],heap.__heap[rtIndex]) then
      minIndex = lfIndex
    else
      minIndex = rtIndex
    end
  end
  if not heap.sort(heap.__heap[index],heap.__heap[minIndex]) then
    heap.__heap[index],heap.__heap[minIndex] = heap.__heap[minIndex],heap.__heap[index]
    percolate_down(heap,minIndex)
  end
end

-- Produces a new heap
local function newHeap(template,comp)
  return setmetatable({__heap = {},
    sort = comp or f_min, size = 0},
  template)
end

local Heap = setmetatable({},
  {__call = function(self,...)
    return newHeap(self,...)
  end})
Heap.__index = Heap

function Heap:empty()
  return (self.size==0)
end

function Heap:clear()
  self.__heap = {}
  self.size = 0
  self.sort = self.sort or f_min
  return self
end

function Heap:push(item)
	if item then
		self.size = self.size + 1
		self.__heap[self.size] = item
		percolate_up(self, self.size)
	end
  return self
end

function Heap:pop()
  local root
  if self.size > 0 then
    root = self.__heap[1]
    self.__heap[1] = self.__heap[self.size]
    self.__heap[self.size] = nil
    self.size = self.size-1
    if self.size>1 then
      percolate_down(self, 1)
    end
  end
  return root
end

function Heap:heapify(item)
  if item then
    local i = indexOf(self.__heap,item)
    if i then 
      percolate_down(self, i)
      percolate_up(self, i)
    end
    return
  end
  for i = floor(self.size/2),1,-1 do
    percolate_down(self,i)
  end
  return self
end

------------------------------  Heuristics (global) ------------------------------

local abs = math.abs
local sqrt = math.sqrt
local sqrt2 = sqrt(2)
local max, min = math.max, math.min

local Heuristics = {}

function Heuristics.MANHATTAN(dx,dy) return abs(dx)+abs(dy) end
function Heuristics.EUCLIDIAN(dx,dy) return sqrt(dx*dx+dy*dy) end
function Heuristics.DIAGONAL(dx,dy) return max(abs(dx),abs(dy)) end
function Heuristics.CARDINTCARD(dx,dy) 
	dx, dy = abs(dx), abs(dy)
	return min(dx,dy) * sqrt2 + max(dx,dy) - min(dx,dy)
end

------------------------------  Node (global) ------------------------------

local assert = assert

Node = {}
Node.__index = Node

function Node:new(x,y)
	return setmetatable({x = x, y = y}, Node)
end

function Node.__lt(A,B) return (A.f < B.f) end

setmetatable(Node,
	{__call = function(self,...) 
		return Node:new(...) 
	end}
)

------------------------------  Path (global) ------------------------------

local t_insert, t_remove = table.insert, table.remove

local Path = {}
Path.__index = Path

function Path:new()
	return setmetatable({}, Path)
end

function Path:iter()
	local i,pathLen = 1,#self
	return function()
		if self[i] then
			i = i+1
			return self[i-1],i-1
		end
	end
end

Path.nodes = Path.iter

function Path:getLength()
	local len = 0
	for i = 2,#self do
		local dx = self[i].x - self[i-1].x
		local dy = self[i].y - self[i-1].y
		len = len + Heuristics.EUCLIDIAN(dx, dy)
	end
	return len
end

function Path:fill()
	local i = 2
	local xi,yi,dx,dy
	local N = #self
	local incrX, incrY
	while true do
		xi,yi = self[i].x,self[i].y
		dx,dy = xi-self[i-1].x,yi-self[i-1].y
		if (abs(dx) > 1 or abs(dy) > 1) then
			incrX = dx/max(abs(dx),1)
			incrY = dy/max(abs(dy),1)
			t_insert(self, i, self.grid:getNodeAt(self[i-1].x + incrX, self[i-1].y +incrY))
			N = N+1
		else i=i+1
		end
		if i>N then break end
	end
end

function Path:filter()
	local i = 2
	local xi,yi,dx,dy, olddx, olddy
	xi,yi = self[i].x, self[i].y
	dx, dy = xi - self[i-1].x, yi-self[i-1].y
	while true do
		olddx, olddy = dx, dy
		if self[i+1] then
			i = i+1
			xi, yi = self[i].x, self[i].y
			dx, dy = xi - self[i-1].x, yi - self[i-1].y
			if olddx == dx and olddy == dy then
				t_remove(self, i-1)
				i = i - 1
			end
		else break end
	end
end

setmetatable(Path,
	{__call = function(self,...)
		return Path:new(...)
	end
})

-- Search algorithms

------------------------------  ASTAR ------------------------------
local ipairs = ipairs
local huge = math.huge

-- Updates G-cost
local function computeCost(node, neighbour, finder)
	local mCost = Heuristics.EUCLIDIAN(neighbour.x - node.x, neighbour.y - node.y)
	if node.g + mCost < neighbour.g then
		neighbour.parent = node
		neighbour.g = node.g + mCost
	end	
end

-- Updates vertex node-neighbour
local function updateVertex(finder, node, neighbour, endNode, heuristic, overrideCostEval)
	local oldG = neighbour.g
	local cmpCost = overrideCostEval or computeCost
	cmpCost(node, neighbour, finder)
	if neighbour.g < oldG then
		if neighbour.opened then
			neighbour.opened = false
		end
		neighbour.h = heuristic(endNode.x - neighbour.x, endNode.y - neighbour.y)
		neighbour.f = neighbour.g + neighbour.h
		finder.openList:push(neighbour)
		neighbour.opened = true
	end	
end

-- Calculates a path.
-- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
local function ASTARSEARCH(finder, startNode, endNode, toClear, tunnel, overrideHeuristic, overrideCostEval)
	local heuristic = overrideHeuristic or finder.heuristic
	
	finder.openList:clear()
	startNode.g = 0
	startNode.h = heuristic(endNode.x - startNode.x, endNode.y - startNode.y)
	startNode.f = startNode.g + startNode.h
	finder.openList:push(startNode)
	toClear[startNode] = true
	startNode.opened = true
	
	while not finder.openList:empty() do
		local node = finder.openList:pop()
		node.closed = true
		if node == endNode then
			return node
		end
		local neighbours = finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal, tunnel)
		for i, neighbour in ipairs(neighbours) do
			if not neighbour.closed then
				toClear[neighbour] = true
				if not neighbour.opened then
					neighbour.g = huge
					neighbour.parent = nil					
				end
				updateVertex(finder, node, neighbour, endNode, heuristic, overrideCostEval)
			end			
		end		
	end		
	
	return nil
end

------------------------------  BFS ------------------------------
local t_remove = table.remove

-- BFS logic
local function breadth_first_search(finder, node, openList, toClear, tunnel)
	local neighbours = finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal, tunnel)
	for i = 1,#neighbours do
		local neighbour = neighbours[i]
		if not neighbour.closed and not neighbour.opened then
			openList[#openList+1] = neighbour
			neighbour.opened = true
			neighbour.parent = node
			toClear[neighbour] = true
		end
	end
end

-- Calculates a path.
-- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
local function BFSEARCH(finder, startNode, endNode, toClear, tunnel)

	local openList = {} -- We'll use a FIFO queue (simple array)
	openList[1] = startNode
	startNode.opened = true
	toClear[startNode] = true

	local node
	while (#openList > 0) do
		node = openList[1]
		t_remove(openList,1)
		node.closed = true

		if node == endNode then
			return node
		end

		breadth_first_search(finder, node, openList, toClear, tunnel)
	end

	return nil
end

------------------------------  DFS ------------------------------
-- DFS logic
local function depth_first_search(finder, node, openList, toClear)
	local neighbours = finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal, tunnel)
	for i = 1,#neighbours do
		local neighbour = neighbours[i]
		if (not neighbour.closed and not neighbour.opened) then
			openList[#openList+1] = neighbour
			neighbour.opened = true
			neighbour.parent = node
			toClear[neighbour] = true
		end
	end

end

-- Calculates a path.
-- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
local function DFSEARCH(finder, startNode, endNode, toClear, tunnel)

	local openList = {} -- We'll use a LIFO queue (simple array)
	openList[1] = startNode
	startNode.opened = true
	toClear[startNode] = true

	local node
	while (#openList > 0) do
		node = openList[#openList]
		t_remove(openList)
		node.closed = true

		if node == endNode then
			return node
		end

		depth_first_search(finder, node, openList, toClear, tunnel)
	end

	return nil
end

------------------------------  DIJKSTRA ------------------------------
local dijkstraHeuristic = function(...) return 0 end

-- Calculates a path.
-- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
local function DIJKSTRASEARCH(finder, startNode, endNode, toClear, tunnel)
	return ASTARSEARCH(finder, startNode, endNode, toClear, tunnel, dijkstraHeuristic)
end
	
------------------------------  JPS ------------------------------
local step_first = false
local function testFirstStep(finder, jNode, node)
	local is_reachable = true
	local jx, jy = jNode.x, jNode.y
	local dx,dy = jx-node.x, jy-node.y
	if dx <= -1 then
		if not finder.grid:isWalkableAt(jx+1,jy,finder.walkable) then is_reachable = false end
	elseif dx >= 1 then
		if not finder.grid:isWalkableAt(jx-1,jy,finder.walkable) then is_reachable = false end
	end
	if dy <= -1 then
		if not finder.grid:isWalkableAt(jx,jy+1,finder.walkable) then is_reachable = false end
	elseif dy >= 1 then
		if not finder.grid:isWalkableAt(jx,jy-1,finder.walkable) then is_reachable = false end
	end
	return not is_reachable
end

local function findNeighbours(finder,node, tunnel)

	if node.parent then
		local neighbours = {}
		local x,y = node.x, node.y
		-- Node have a parent, we will prune some neighbours
		-- Gets the direction of move
		local dx = (x-node.parent.x)/max(abs(x-node.parent.x),1)
		local dy = (y-node.parent.y)/max(abs(y-node.parent.y),1)

			-- Diagonal move case
		if dx~=0 and dy~=0 then
			local walkY, walkX

			-- Natural neighbours
			if finder.grid:isWalkableAt(x,y+dy,finder.walkable) then
				neighbours[#neighbours+1] = finder.grid:getNodeAt(x,y+dy)
				walkY = true
			end
			if finder.grid:isWalkableAt(x+dx,y,finder.walkable) then
				neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y)
				walkX = true
			end
			if walkX or walkY then
				neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y+dy)
			end

			-- Forced neighbours
			if (not finder.grid:isWalkableAt(x-dx,y,finder.walkable)) and walkY then
				neighbours[#neighbours+1] = finder.grid:getNodeAt(x-dx,y+dy)
			end
			if (not finder.grid:isWalkableAt(x,y-dy,finder.walkable)) and walkX then
				neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y-dy)
			end

		else
			-- Move along Y-axis case
			if dx==0 then
				local walkY
				if finder.grid:isWalkableAt(x,y+dy,finder.walkable) then
					neighbours[#neighbours+1] = finder.grid:getNodeAt(x,y+dy)

					-- Forced neighbours are left and right ahead along Y
					if (not finder.grid:isWalkableAt(x+1,y,finder.walkable)) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x+1,y+dy)
					end
					if (not finder.grid:isWalkableAt(x-1,y,finder.walkable)) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x-1,y+dy)
					end
				end
				-- In case diagonal moves are forbidden : Needs to be optimized
				if not finder.allowDiagonal then
					if finder.grid:isWalkableAt(x+1,y,finder.walkable) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x+1,y)
					end
					if finder.grid:isWalkableAt(x-1,y,finder.walkable)
						then neighbours[#neighbours+1] = finder.grid:getNodeAt(x-1,y)
					end
				end
			else
			-- Move along X-axis case
				if finder.grid:isWalkableAt(x+dx,y,finder.walkable) then
					neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y)

					-- Forced neighbours are up and down ahead along X
					if (not finder.grid:isWalkableAt(x,y+1,finder.walkable)) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y+1)
					end
					if (not finder.grid:isWalkableAt(x,y-1,finder.walkable)) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x+dx,y-1)
					end
				end
				-- : In case diagonal moves are forbidden
				if not finder.allowDiagonal then
					if finder.grid:isWalkableAt(x,y+1,finder.walkable) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x,y+1)
					end
					if finder.grid:isWalkableAt(x,y-1,finder.walkable) then
						neighbours[#neighbours+1] = finder.grid:getNodeAt(x,y-1)
					end
				end
			end
		end
		return neighbours
	end

	-- Node do not have parent, we return all neighbouring nodes
	return finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal, tunnel)
end

local function jump(finder, node, parent, endNode)
	if not node then return end

	local x,y = node.x, node.y
	local dx, dy = x - parent.x,y - parent.y

	-- If the node to be examined is unwalkable, return nil
	if not finder.grid:isWalkableAt(x,y,finder.walkable) then return end

	-- If the node to be examined is the endNode, return this node
	if node == endNode then return node end

	-- Diagonal search case
	if dx~=0 and dy~=0 then
		-- Current node is a jump point if one of his leftside/rightside neighbours ahead is forced
		if (finder.grid:isWalkableAt(x-dx,y+dy,finder.walkable) and (not finder.grid:isWalkableAt(x-dx,y,finder.walkable))) or
			 (finder.grid:isWalkableAt(x+dx,y-dy,finder.walkable) and (not finder.grid:isWalkableAt(x,y-dy,finder.walkable))) then
			return node
		end
	else
		-- Search along X-axis case
		if dx~=0 then
			if finder.allowDiagonal then
				-- Current node is a jump point if one of his upside/downside neighbours is forced
				if (finder.grid:isWalkableAt(x+dx,y+1,finder.walkable) and (not finder.grid:isWalkableAt(x,y+1,finder.walkable))) or
					 (finder.grid:isWalkableAt(x+dx,y-1,finder.walkable) and (not finder.grid:isWalkableAt(x,y-1,finder.walkable))) then
					return node
				end
			else
				-- : in case diagonal moves are forbidden
				if finder.grid:isWalkableAt(x+1,y,finder.walkable) or finder.grid:isWalkableAt(x-1,y,finder.walkable) then return node end
			end
		else
		-- Search along Y-axis case
			-- Current node is a jump point if one of his leftside/rightside neighbours is forced
			if finder.allowDiagonal then
				if (finder.grid:isWalkableAt(x+1,y+dy,finder.walkable) and (not finder.grid:isWalkableAt(x+1,y,finder.walkable))) or
					 (finder.grid:isWalkableAt(x-1,y+dy,finder.walkable) and (not finder.grid:isWalkableAt(x-1,y,finder.walkable))) then
					return node
				end
			else
				-- : in case diagonal moves are forbidden
				if finder.grid:isWalkableAt(x,y+1,finder.walkable) or finder.grid:isWalkableAt(x,y-1,finder.walkable) then return node end
			end
		end
	end

	-- Recursive horizontal/vertical search
	if dx~=0 and dy~=0 then
		if jump(finder,finder.grid:getNodeAt(x+dx,y),node,endNode) then return node end
		if jump(finder,finder.grid:getNodeAt(x,y+dy),node,endNode) then return node end
	end

	-- Recursive diagonal search
	if finder.allowDiagonal then
		if finder.grid:isWalkableAt(x+dx,y,finder.walkable) or finder.grid:isWalkableAt(x,y+dy,finder.walkable) then
			return jump(finder,finder.grid:getNodeAt(x+dx,y+dy),node,endNode)
		end
	end
end

local function identifySuccessors(finder,node,endNode,toClear, tunnel)

	-- Gets the valid neighbours of the given node
	-- Looks for a jump point in the direction of each neighbour
	local neighbours = findNeighbours(finder,node, tunnel)
	for i = #neighbours,1,-1 do

		local skip = false
		local neighbour = neighbours[i]
		local jumpNode = jump(finder,neighbour,node,endNode)

		-- : in case a diagonal jump point was found in straight mode, skip it.
		if jumpNode and not finder.allowDiagonal then
			if ((jumpNode.x ~= node.x) and (jumpNode.y ~= node.y)) then skip = true end
		end

		-- Performs regular A-star on a set of jump points
		if jumpNode and not skip then
			-- Update the jump node and move it in the closed list if it wasn't there
			if not jumpNode.closed then
				local extraG = Heuristics.EUCLIDIAN(jumpNode.x-node.x,jumpNode.y-node.y)
				local newG = node.g + extraG
				if not jumpNode.opened or newG < jumpNode.g then
					toClear[jumpNode] = true -- Records this node to reset its properties later.
					jumpNode.g = newG
					jumpNode.h = jumpNode.h or
						(finder.heuristic(jumpNode.x-endNode.x,jumpNode.y-endNode.y))
					jumpNode.f = jumpNode.g+jumpNode.h
					jumpNode.parent = node
					if not jumpNode.opened then
						finder.openList:push(jumpNode)
						jumpNode.opened = true
						if not step_first then step_first = true end
					else
						finder.openList:heapify(jumpNode)
					end
				end
			end
		end
	end
end

local function JUMPPOINTSEARCH(finder, startNode, endNode, toClear, tunnel)
	step_first = false
	startNode.g, startNode.f = 0,0
	finder.openList:clear()
	finder.openList:push(startNode)
	startNode.opened = true
	toClear[startNode] = true

	local node
	while not finder.openList:empty() do
		-- Pops the lowest F-cost node, moves it in the closed list
		node = finder.openList:pop()
		node.closed = true
			-- If the popped node is the endNode, return it
			if node == endNode then
				return node
			end
		-- otherwise, identify successors of the popped node
		identifySuccessors(finder, node, endNode, toClear, tunnel)
	end

	-- No path found, return nil
	return nil
end

------------------------------  Grid Module (global) ------------------------------
local pairs = pairs
local next = next
local otype = type
	
-- Local helpers

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

function Grid:getWidth() return self.width end

function Grid:getHeight() return self.height end

function Grid:getMap() return self.map end

function Grid:getNodes() return self.nodes end

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

function Grid:each(f,...)
	for node in self:iter() do f(node,...) end
end

function Grid:eachRange(lx,ly,ex,ey,f,...)
	for node in self:iter(lx,ly,ex,ey) do f(node,...) end
end

function Grid:imap(f,...)
	for node in self:iter() do
		node = f(node,...)
	end
end

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

function PreProcessGrid:getNodeAt(x,y)
	return self.nodes[y] and self.nodes[y][x] or nil
end

function PostProcessGrid:getNodeAt(x,y)
	if not x or not y then return end
	if outOfRange(x,self.min_bound_x,self.max_bound_x) then return end
	if outOfRange(y,self.min_bound_y,self.max_bound_y) then return end
	if not self.nodes[y] then self.nodes[y] = {} end
	if not self.nodes[y][x] then self.nodes[y][x] = Node:new(x,y) end
	return self.nodes[y][x]
end

setmetatable(Grid,{
	__call = function(self,...)
		return self:new(...)
	end
})
	
------------------------------  Pathfinder Module (global) ------------------------------	
local _VERSION = "1.8.1"
local _RELEASEDATE = "03/01/2013"

local function isAGrid(grid)
	return getmetatable(grid) and getmetatable(getmetatable(grid)) == Grid
end
	
local Finders = {
	['ASTAR']     = ASTARSEARCH,	
	['DIJKSTRA']  = DIJKSTRASEARCH,
	['BFS']       = BFSEARCH,
	['DFS']       = DFSEARCH,
	['JPS']       = JUMPPOINTSEARCH,
}	

-- Collect keys in an array
local function collect_keys(t)
	local keys = {}
	for k,v in pairs(t) do keys[#keys+1] = k end
	return keys
end

local toClear = {}

local function reset()
	for node in pairs(toClear) do
		node.g, node.h, node.f = nil, nil, nil
		node.opened, node.closed, node.parent = nil, nil, nil
	end
	toClear = {}
end

-- Keeps track of the last computed path cost
local lastPathCost = 0

-- Availables search modes
local searchModes = {['DIAGONAL'] = true, ['ORTHOGONAL'] = true}

local function traceBackPath(finder, node, startNode)
	local path = Path:new()
	path.grid = finder.grid
	lastPathCost = node.f or path:getLength()

	while true do
		if node.parent then
			t_insert(path,1,node)
			node = node.parent
		else
			t_insert(path,1,startNode)
			return path
		end
	end
end

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(grid, finderName, walkable)
	local newPathfinder = {}
	setmetatable(newPathfinder, Pathfinder)
	newPathfinder:setGrid(grid)
	newPathfinder:setFinder(finderName)
	newPathfinder:setWalkable(walkable)
	newPathfinder:setMode('DIAGONAL')
	newPathfinder:setHeuristic('MANHATTAN')
	newPathfinder.openList = Heap()
	return newPathfinder
end

function Pathfinder:setGrid(grid)
	assert(isAGrid(grid), 'Bad argument #1. Expected a \'grid\' object')
	self.grid = grid
	self.grid.__eval = self.walkable and type(self.walkable) == 'function'
	return self
end

function Pathfinder:getGrid()
	return self.grid
end

function Pathfinder:setWalkable(walkable)
	assert(('stringintfunctionnil'):match(type(walkable)),
		('Bad argument #2. Expected \'string\', \'number\' or \'function\', got %s.'):format(type(walkable)))
	self.walkable = walkable
	self.grid.__eval = type(self.walkable) == 'function'
	return self
end

function Pathfinder:getWalkable()
	return self.walkable
end

function Pathfinder:setFinder(finderName)
	local finderName = finderName
	if not finderName then
		if not self.finder then 
			finderName = 'ASTAR' 
		else return 
		end
	end
	assert(Finders[finderName],'Not a valid finder name!')
	self.finder = finderName
	return self
end

function Pathfinder:getFinder()
	return self.finder
end

function Pathfinder:getFinders()
	return collect_keys(Finders)
end

function Pathfinder:setHeuristic(heuristic)
	assert(Heuristics[heuristic] or (type(heuristic) == 'function'),'Not a valid heuristic!')
	self.heuristic = Heuristics[heuristic] or heuristic
	return self
end

function Pathfinder:getHeuristic()
	return self.heuristic
end

function Pathfinder:getHeuristics()
	return collect_keys(Heuristics)
end

function Pathfinder:setMode(mode)
	assert(searchModes[mode],'Invalid mode')
	self.allowDiagonal = (mode == 'DIAGONAL')
	return self
end

function Pathfinder:getMode()
	return (self.allowDiagonal and 'DIAGONAL' or 'ORTHOGONAL')
end

function Pathfinder:getModes()
	return collect_keys(searchModes)
end

function Pathfinder:version()
	return _VERSION, _RELEASEDATE
end

function Pathfinder:getPath(startX, startY, endX, endY, tunnel)
	reset()
	local startNode = self.grid:getNodeAt(startX, startY)
	local endNode = self.grid:getNodeAt(endX, endY)
	assert(startNode, ('Invalid location [%d, %d]'):format(startX, startY))
	assert(endNode and self.grid:isWalkableAt(endX, endY),
		('Invalid or unreachable location [%d, %d]'):format(endX, endY))
	local _endNode = Finders[self.finder](self, startNode, endNode, toClear, tunnel)
	if _endNode then 
		return traceBackPath(self, _endNode, startNode), lastPathCost
	end
	lastPathCost = 0
	return nil, lastPathCost
end

setmetatable(Pathfinder,{
	__call = function(self,...)
		return self:new(...)
	end
})

------------------------------  Spawns module into the global env ------------------------------
Jumper = {
	Heuristics = Heuristics,
	Node = Node,
	Path = Path,
	Grid = Grid,
	Pathfinder = Pathfinder
}