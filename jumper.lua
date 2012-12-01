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

local _VERSION = "1.6.2"
if (...) then
  local _PATH = (...):gsub('[^%.]+$','')
  local insert = table.insert
  local pairs = pairs
  local max, abs = math.max, math.abs
  local assert, type = assert, type

  -- Loads dependancies
  local Heuristic = require (_PATH .. 'core.heuristics')
  local Grid = require (_PATH ..'core.grid')
  local Heap = require (_PATH .. 'core.bheap')

  -------------------------------------------------------------------------------------------------
  -- Local helpers, these routines will stay private
  -- As they are internally used by the public interface

  -- Will keep track of all nodes expanded during the search
  -- to easily reset their properties for the next pathfinding call
  local toClear = {}

  -- Keeps track of the last computed path cost
  local lastPathCost = 0

  -- Check if a node is reachable in diagonal-search mode
  -- Will prevent from "tunneling" issue when
  -- the goal node is neighbouring a starting location
  local step_first = false

  local function testFirstStep(grid, jNode, node)
    local is_reachable = true
    local jx, jy = jNode.x, jNode.y
    local dx,dy = jx-node.x, jy-node.y
    if dx <= -1 then
      if not grid:isWalkableAt(jx+1,jy) then is_reachable = false end
    elseif dx >= 1 then
      if not grid:isWalkableAt(jx-1,jy) then is_reachable = false end
    end
    if dy <= -1 then
      if not grid:isWalkableAt(jx,jy+1) then is_reachable = false end
    elseif dy >= 1 then
      if not grid:isWalkableAt(jx,jy-1) then is_reachable = false end
    end
    return not is_reachable
 end

  -- Resets properties of nodes expanded during a search
  -- This is a lot faster than resetting all nodes
  -- between consecutive pathfinding requests
  local function reset()
    for node in pairs(toClear) do
      node.g, node.h, node.f = nil, nil, nil
      node.opened, node.closed, node.parent = nil, nil, nil
    end
    toClear = {}
  end

  -- Performs a traceback from the goal node to the start node
  -- Only happens when the path was found
  local function traceBackPath(self)
    local sx,sy = self.startNode.x,self.startNode.y
    local x,y
    local path = {{x = self.endNode.x, y = self.endNode.y}}
    local node

    while true do
      x,y = path[1].x,path[1].y
      node = self.grid:getNodeAt(x,y)
      if node.parent then
        x,y = node.parent.x,node.parent.y
        insert(path,1,{x = x, y = y})
      else
        lastPathCost = self.endNode.f
        reset()
        return self.autoFill and self:fill(path) or path
      end
    end

    lastPathCost = 0
    reset()
    return nil
  end

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
  local function findNeighbours(self,node)

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
        if self.grid:isWalkableAt(x,y+dy) then
          neighbours[#neighbours+1] = self.grid:getNodeAt(x,y+dy)
          walkY = true
        end
        if self.grid:isWalkableAt(x+dx,y) then
          neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y)
          walkX = true
        end
        if walkX or walkY then
          neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y+dy)
        end

        -- Forced neighbours
        if (not self.grid:isWalkableAt(x-dx,y)) and walkY then
          neighbours[#neighbours+1] = self.grid:getNodeAt(x-dx,y+dy)
        end
        if (not self.grid:isWalkableAt(x,y-dy)) and walkX then
          neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y-dy)
        end

      else
        -- Move along Y-axis case
        if dx==0 then
          local walkY
          if self.grid:isWalkableAt(x,y+dy) then
            neighbours[#neighbours+1] = self.grid:getNodeAt(x,y+dy)

            -- Forced neighbours are left and right ahead along Y
            if (not self.grid:isWalkableAt(x+1,y)) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x+1,y+dy)
            end
            if (not self.grid:isWalkableAt(x-1,y)) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x-1,y+dy)
            end
          end
          -- In case diagonal moves are forbidden : Needs to be optimized
          if not self.allowDiagonal then
            if self.grid:isWalkableAt(x+1,y) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x+1,y)
            end
            if self.grid:isWalkableAt(x-1,y)
              then neighbours[#neighbours+1] = self.grid:getNodeAt(x-1,y)
            end
          end
        else
        -- Move along X-axis case
          if self.grid:isWalkableAt(x+dx,y) then
            neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y)

            -- Forced neighbours are up and down ahead along X
            if (not self.grid:isWalkableAt(x,y+1)) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y+1)
            end
            if (not self.grid:isWalkableAt(x,y-1)) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x+dx,y-1)
            end
          end
          -- : In case diagonal moves are forbidden
          if not self.allowDiagonal then
            if self.grid:isWalkableAt(x,y+1) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x,y+1)
            end
            if self.grid:isWalkableAt(x,y-1) then
              neighbours[#neighbours+1] = self.grid:getNodeAt(x,y-1)
            end
          end
        end
      end
      return neighbours
    end

    -- Node do not have parent, we return all neighbouring nodes
    return self.grid:getNeighbours(node,self.allowDiagonal)
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
  local function jump(self, node, parent)
	if not node then return end

    local x,y = node.x, node.y
    local dx, dy = x - parent.x,y - parent.y

    -- If the node to be examined is unwalkable, return nil
    if not self.grid:isWalkableAt(x,y) then return end

    -- If the node to be examined is the endNode, return this node
    if node == self.endNode then return node end

    -- Diagonal search case
    if dx~=0 and dy~=0 then
      -- Current node is a jump point if one of his leftside/rightside neighbours ahead is forced
      if (self.grid:isWalkableAt(x-dx,y+dy) and (not self.grid:isWalkableAt(x-dx,y))) or
         (self.grid:isWalkableAt(x+dx,y-dy) and (not self.grid:isWalkableAt(x,y-dy))) then
        return node
      end
    else
      -- Search along X-axis case
      if dx~=0 then
        if self.allowDiagonal then
          -- Current node is a jump point if one of his upside/downside neighbours is forced
          if (self.grid:isWalkableAt(x+dx,y+1) and (not self.grid:isWalkableAt(x,y+1))) or
             (self.grid:isWalkableAt(x+dx,y-1) and (not self.grid:isWalkableAt(x,y-1))) then
            return node
          end
        else
          -- : in case diagonal moves are forbidden
          if self.grid:isWalkableAt(x+1,y) or self.grid:isWalkableAt(x-1,y) then return node end
        end
      else
      -- Search along Y-axis case
        -- Current node is a jump point if one of his leftside/rightside neighbours is forced
        if self.allowDiagonal then
          if (self.grid:isWalkableAt(x+1,y+dy) and (not self.grid:isWalkableAt(x+1,y))) or
             (self.grid:isWalkableAt(x-1,y+dy) and (not self.grid:isWalkableAt(x-1,y))) then
            return node
          end
        else
          -- : in case diagonal moves are forbidden
          if self.grid:isWalkableAt(x,y+1) or self.grid:isWalkableAt(x,y-1) then return node end
        end
      end
    end

    -- Recursive horizontal/vertical search
    if dx~=0 and dy~=0 then
      if jump(self,self.grid:getNodeAt(x+dx,y),node) then return node end
      if jump(self,self.grid:getNodeAt(x,y+dy),node) then return node end
    end

    -- Recursive diagonal search
    if self.allowDiagonal then
      if self.grid:isWalkableAt(x+dx,y) or self.grid:isWalkableAt(x,y+dy) then
        return jump(self,self.grid:getNodeAt(x+dx,y+dy),node)
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
  local function identifySuccessors(self,node)

    -- Gets the valid neighbours of the given node
    -- Looks for a jump point in the direction of each neighbour
    local neighbours = findNeighbours(self,node)
    for i = #neighbours,1,-1 do

      local skip = false
      local neighbour = neighbours[i]
      local jumpNode = jump(self,neighbour,node)

      -- : in case a diagonal jump point was found in straight mode, skip it.
      if jumpNode and not self.allowDiagonal then
        if ((jumpNode.x ~= node.x) and (jumpNode.y ~= node.y)) then skip = true end
      end

      -- Hacky trick to discard "tunneling" in diagonal mode search for the first step
      if jumpNode and self.allowDiagonal and not step_first then
        if jumpNode.x == self.endNode.x and jumpNode.y == self.endNode.y then
          step_first = true
          if not skip then
            skip = testFirstStep(self.grid, jumpNode, node)
          end
        end
      end

      -- Performs regular A-star
      if jumpNode and not skip then
        toClear[jumpNode] = true -- Records this node to reset its properties later.
        -- Update the jump node and move it in the closed list if it wasn't there
        if not jumpNode.closed then
          local extraG = Heuristic.EUCLIDIAN(jumpNode.x-node.x,jumpNode.y-node.y)
          local newG = node.g + extraG
          if not jumpNode.opened or newG < jumpNode.g then
            jumpNode.g = newG
            jumpNode.h = jumpNode.h or
              (self.heuristic(jumpNode.x-self.endNode.x,jumpNode.y-self.endNode.y))
            jumpNode.f = jumpNode.g+jumpNode.h
            jumpNode.parent = node
            if not jumpNode.opened then
              self.openList:push(jumpNode)
              jumpNode.opened = true
              if not step_first then step_first = true end
            else
              self.openList:heapify()
            end
          end
        end
      end
    end
  end
  -------------------------------------------------------------------------------------------------

  -- Public interface
  -- Jump Point Search Class
  local JPS = {
    allowDiagonal = true, -- By default, allows diagonal moves
    autoFill = false -- Will not fill paths by default
  }
  JPS.__index = JPS

  -- Availables search modes
  local searchModes = { ['DIAGONAL'] = true, ['ORTHOGONAL'] = true}

  -- Custom initializer (walkable, allowDiagonal,heuristic and autoFill are optional)
  function JPS:new(map,walkable,postProcess)
    local newPather = {}
    setmetatable(newPather,JPS)
    newPather.grid = Grid(map,walkable,postProcess)
    newPather.allowDiagonal = true
    newPather:setHeuristic('MANHATTAN')
    newPather.autoFill = false
    newPather.openList = Heap()
    return newPather
  end

  -- Changes the heuristic used for guidance to the target
  -- Supports custom heuristics
  function JPS:setHeuristic(heuristic)
    assert(Heuristic[heuristic] or (type(heuristic) == 'function'),'Not a valid heuristic!')
    self.heuristic = Heuristic[heuristic] or heuristic
    return self
  end

  -- Gets a reference to the heuristic function currently used
  function JPS:getHeuristic()
    return self.heuristic
  end

  -- Enables or disables diagonal moves
  function JPS:setMode(mode)
    assert(searchModes[mode],'Invalid mode')
    self.allowDiagonal = (mode == 'DIAGONAL')
    return self 
  end

  -- Returns search mode
  function JPS:getMode()
    return (self.allowDiagonal and 'DIAGONAL' or 'ORTHOGONAL')
  end

  -- Enables or disables autoFill
  function JPS:setAutoFill(bool)
    assert(type(bool) == 'boolean','Argument must be a boolean')
    self.autoFill = bool
    return self
  end

  -- Returns whether or not autoFill is enabled
  function JPS:getAutoFill()
    return self.autoFill
  end

  --[[
    Main search fuction. Requires a start location and end location.
    endNode must be walkable.
    Returns the path when found, otherwise nil.
  --]]
  function JPS:getPath(startX,startY,endX,endY)    
    self.startNode = self.grid:getNodeAt(startX,startY)
    self.endNode = self.grid:getNodeAt(endX,endY)
    local node
    step_first = false
    self.openList:clear()
    
    -- Moves the start node in the openList
    self.startNode.g, self.startNode.f = 0,0
    self.openList:push(self.startNode)
    self.startNode.opened = true
    toClear[self.startNode] = true

    while not self.openList:empty() do
      -- Pops the lowest-F node, moves it in the closed list
      node = self.openList:pop()
      node.closed = true
        -- If the popped node is the endNode, traceback and return the path and the path cost
        if node == self.endNode then  
          return traceBackPath(self),lastPathCost 
        end
      -- Else, identify successors of the popped node
      identifySuccessors(self,node)
    end

    -- No path found, return nil
    return nil
  end

  --[[
    Simple path filling utility. As the path returned by JPS algorithm
    consists of jump locations, it contains some holes. This function
    alters the given path, inserting missing nodes.
  --]]
  function JPS:fill(path)
    local i = 2
    local xi,yi,dx,dy
    local N = #path

    while true do
      xi,yi = path[i].x,path[i].y
      dx,dy = xi-path[i-1].x,yi-path[i-1].y
      if (abs(dx) > 1 or abs(dy) > 1) then
        incrX = dx/max(abs(dx),1)
        incrY = dy/max(abs(dy),1)
        insert(path,i,{x = path[i-1].x+incrX,y = path[i-1].y+incrY})
        N = N+1
      else i=i+1
      end
      if i>N then break end
    end
    return path
  end

  -- Returns a reference to the internal grid
  function JPS:getGrid() return self.grid end

  -- Returns JPS Pathfinder
  return setmetatable(JPS,{
    __call = function(self,...)
      return self:new(...)
    end
  })
end
