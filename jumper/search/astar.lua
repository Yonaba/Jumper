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
	
	-- Depandancies
	local Heuristics = require ((...):match('(.+)%.search.astar$') .. '.core.heuristics')
	
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
  return function (finder, startNode, endNode, toClear, tunnel, overrideHeuristic, overrideCostEval)
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
