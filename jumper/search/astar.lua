--- <strong>`A-star` algorithm</strong>.
-- Implementation of <a href="http://en.wikipedia.org/wiki/A-star">A*</a> search algorithm.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script jumper.search.astar

-- This implementation of A-star was based on Nash A. & al. pseudocode
-- Added override args to support dijkstra and thetaStar
-- http://aigamedev.com/open/tutorials/theta-star-any-angle-paths/

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
  return function (finder, startNode, endNode, toClear, tunnel, overrideHeuristic, overrideCostEval)
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
			local neighbours = finder._grid:getNeighbours(node, finder._walkable, finder._allowDiagonal, tunnel)
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

--[[
Copyright (c) 2012-2013 Roland Yonaba

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
