--- <strong>`A-star` algorithm</strong>.
-- Implementation of <a href="http://en.wikipedia.org/wiki/A-star">A*</a> search algorithm.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script jumper.search.astar



if (...) then
  local sqrt2 = math.sqrt(2)

  local function astar_search(finder, node, endNode, toClear, overrideHeuristic)
    -- Collect all neighbouring nodes from the current examined node
    local neighbours = finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal)
    for i = 1, #neighbours do
      local neighbour = neighbours[i]
      if not neighbour.closed then -- If not in closed list
        
        local x, y = neighbour.x, neighbour.y
        local dx, dy = x - node.x, y - node.y
        local extraG = node.g + ((dx == 0 or dy == 0) and 1 or sqrt2) -- Evaluates the new G-cost

        if (not neighbour.opened or extraG < neighbour.g) then
          -- Updates G, H and F-costs and its parent
          toClear[neighbour] = true
          neighbour.g = extraG
          local d_to_end_x, d_to_end_y = (endNode.x - x),(endNode.y - y)
          local heuristic = overrideHeuristic or finder.heuristic
          neighbour.h = neighbour.h or heuristic(d_to_end_x, d_to_end_y)
          neighbour.f = neighbour.g + neighbour.h
          neighbour.parent = node
          
          if not neighbour.opened then
            -- Moves it in openList
            finder.openList:push(neighbour)
            neighbour.opened = true
          else
            finder.openList:heapify(neighbour) -- Updates the node rank in the openList
          end
        end
      end
    end
  end

  -- Calculates a path.
  -- Returns the path from location `<startX, startY>` to location `<endX, endY>`.  
  return function (finder, startNode, endNode, toClear, overrideHeuristic)

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
      -- otherwise, keep going A-star search from the popped node        
      astar_search(finder, node, endNode, toClear, overrideHeuristic)
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
