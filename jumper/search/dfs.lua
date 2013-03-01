--- <strong>`Depth First Search` algorithm</strong>.
-- Implementation of <a href="http://en.wikipedia.org/wiki/Depth-first_search">Depth First Search</a> search algorithm.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script jumper.search.dfs



if (...) then
  -- Internalization
  local t_remove = table.remove

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
  return function (finder, startNode, endNode, toClear, tunnel)

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
