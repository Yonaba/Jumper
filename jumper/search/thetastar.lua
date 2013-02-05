--- <strong>`Theta-star` algorithm</strong>.
-- Implementation of <a href="http://aigamedev.com/open/tutorials/theta-star-any-angle-paths">Theta star</a> search algorithm.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script jumper.search.thetastar


-- This implementation of A-star was based on Nash A. & al. pseudocode
-- See: http://aigamedev.com/open/tutorials/theta-star-any-angle-paths/
if (...) then
	
	local _PATH = (...)

	-- Depandancies
	local Heuristics = require (_PATH:gsub('%.search.thetastar$', '.core.heuristics'))
	local astar_search = require (_PATH:gsub('%.thetastar$','.astar'))

	-- Internalization
	local ipairs = ipairs
	local huge, abs = math.huge, math.abs
	
	-- Line Of Sight (Bresenham's line marching algorithm)
	-- http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
	local lineOfSight = function (node, neighbour, finder)
		local x0, y0 = node.x, node.y
		local x1, y1 = neighbour.x, neighbour.y
		local dx = abs(x1-x0)
		local dy = abs(y1-y0)
		local err = dx - dy
		local sx = (x0 < x1) and 1 or -1
		local sy = (y0 < y1) and 1 or -1		

		while true do
			if not finder.grid:isWalkableAt(x0, y0, finder.walkable) then 
				return false 
			end
			if x0 == x1 and y0 == y1 then
				break
			end
			local e2 = 2*err
			if e2 > -dy then
				err = err - dy
				x0 = x0 + sx
			end
			if e2 < dx then
				err = err + dx
				y0 = y0 + sy
			end
		end
		return true
	end
	
	-- Theta star cost evaluation
	local function computeCost(node, neighbour, finder)
		local parent = node.parent or node
		local mpCost = Heuristics.EUCLIDIAN(neighbour.x - parent.x, neighbour.y - parent.y)
		if lineOfSight(parent, neighbour, finder) then
			if parent.g + mpCost < neighbour.g then
				neighbour.parent = parent
				neighbour.g = parent.g + mpCost
			end
		else
			local mCost = Heuristics.EUCLIDIAN(neighbour.x - node.x, neighbour.y - node.y)
			if node.g + mCost < neighbour.g then
				neighbour.parent = node
				neighbour.g = node.g + mCost
			end
		end
	end

  -- Calculates a path.
  -- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
  return function (finder, startNode, endNode, toClear, overrideHeuristic)
    return astar_search(finder, startNode, endNode, toClear, overrideHeuristic, computeCost)
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
