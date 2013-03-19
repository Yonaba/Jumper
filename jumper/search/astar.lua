-- Astar algorithm
-- This actual implementation of A-star is based on 
-- [Nash A. & al. pseudocode](http://aigamedev.com/open/tutorials/theta-star-any-angle-paths/)

if (...) then

	-- Internalization
	local ipairs = ipairs
	local huge = math.huge
	
	-- Dependancies
	local _PATH = (...):match('(.+)%.search.astar$')
	local Heuristics = require (_PATH .. '.core.heuristics')
	local Heap = require (_PATH.. '.core.bheap')
	
	-- Updates G-cost
	local function computeCost(node, neighbour, finder)
		local mCost = Heuristics.EUCLIDIAN(neighbour._x - node._x, neighbour._y - node._y)
		if node._g + mCost < neighbour._g then
			neighbour._parent = node
			neighbour._g = node._g + mCost
		end	
	end
	
	-- Updates vertex node-neighbour
	local function updateVertex(finder, openList, node, neighbour, endNode, heuristic, overrideCostEval)
		local oldG = neighbour._g
		local cmpCost = overrideCostEval or computeCost
		cmpCost(node, neighbour, finder)
		if neighbour._g < oldG then
			if neighbour._opened then
				neighbour._opened = false
			end
			neighbour._h = heuristic(endNode._x - neighbour._x, endNode._y - neighbour._y)
			neighbour._f = neighbour._g + neighbour._h
			openList:push(neighbour)
			neighbour._opened = true
		end	
	end

  -- Calculates a path.
  -- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
  return function (finder, startNode, endNode, toClear, overrideHeuristic, overrideCostEval)
		local heuristic = overrideHeuristic or finder._heuristic
		
		local openList = Heap()
		startNode._g = 0
		startNode._h = heuristic(endNode._x - startNode._x, endNode._y - startNode._y)
		startNode._f = startNode._g + startNode._h
		openList:push(startNode)
		toClear[startNode] = true
		startNode._opened = true
		
		while not openList:empty() do
			local node = openList:pop()
			node._closed = true
			if node == endNode then return node end
			local neighbours = finder._grid:getNeighbours(node, finder._walkable, finder._allowDiagonal, finder._tunnel)
			for i = 1,#neighbours do
				local neighbour = neighbours[i]
				if not neighbour._closed then
					toClear[neighbour] = true
					if not neighbour._opened then
						neighbour._g = huge
						neighbour._parent = nil					
					end
					updateVertex(finder, openList, node, neighbour, endNode, heuristic, overrideCostEval)
				end			
			end		
		end		
		
		return nil
	end
	
end