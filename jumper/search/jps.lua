--- <strong>`Jump Point Search` algorithm</strong>.
-- This file holds an implementation of <a href="http://harablog.wordpress.com/2011/09/07/jump-point-search/">Jump Point Search</a> algorithm.
-- To quote its authors, __Jump Point Search__ is basically
-- "*an online symmetry breaking algorithm which speeds up pathfinding
-- on uniform-cost grid maps by __jumping over__ many locations that would otherwise
-- need to be explicitly considered* ".
--
-- It neither requires preprocessing, nor generates memory overhead, and thus performs consistently fast than classical A*.
--
-- The following implementation was written with respect to the core pseudo-code given in
-- its <a href="http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf">
-- technical papers,</a> plus a wide
-- range of optimizations and additional features.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script jumper.search.jps


if (...) then

  -- Dependancies
  local _PATH = (...):match('(.+)%.search.jps$')
  local Heuristics = require (_PATH .. '.core.heuristics')

  -- Internalization
  local max, abs = math.max, math.abs

  -- Local helpers, these routines will stay private
  -- As they are internally used by the public interface

  -- Check if a node is reachable in diagonal-search mode
  -- Will prevent from "tunneling" issue when
  -- the goal node is neighbouring a starting location
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

  -- Resets properties of nodes expanded during a search
  -- This is a lot faster than resetting all nodes
  -- between consecutive pathfinding requests

  --[[
    Looks for the neighbours of a given node.
    Returns its natural neighbours plus forced neighbours when the given
    node has no parent (generally occurs with the starting node).
    Otherwise, based on the direction of move from the parent, returns
    neighbours while pruning directions which will lead to symmetric paths.

    In case diagonal moves are forbidden, when the given node has no
    parent, we return straight neighbours (up, down, left and right).
    Otherwise, we add left and right node (perpendicular to the direction
    of move) in the neighbours list.
  --]]
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

  --[[
    Searches for a jump point (or a turning point) in a specific direction.
    This is a generic translation of the algorithm 2 in the paper:
      http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
    The current expanded node is a jump point if near a forced node

    In case diagonal moves are forbidden, when lateral nodes (perpendicular to
    the direction of moves are walkable, we force them to be turning points in other
    to perform a straight move.
  --]]
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

  --[[
    Searches for successors of a given node in the direction of each of its neighbours.
    This is a generic translation of the algorithm 1 in the paper:
      http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf

    Also, we notice that processing neighbours in a reverse order producing a natural
    looking path, as the pathfinder tends to keep heading in the same direction.
    In case a jump point was found, and this node happened to be diagonal to the
    node currently expanded in a straight mode search, we skip this jump point.
  --]]
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

			--[[
      -- Hacky trick to discard "tunneling" in diagonal mode search for the first step
      if jumpNode and finder.allowDiagonal and not step_first then
        if jumpNode.x == endNode.x and jumpNode.y == endNode.y then
          step_first = true
          if not skip then
            skip = testFirstStep(finder, jumpNode, node)
          end
        end
      end
			--]]
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

  -- Calculates a path.
  -- Returns the path from location `<startX, startY>` to location `<endX, endY>`.
  return function(finder, startNode, endNode, toClear, tunnel)

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
