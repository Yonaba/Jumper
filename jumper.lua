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

local _VERSION = "1.6.0"
if (...) then
  local _PATH = (...):gsub('[^%.]+$','')
  local insert = table.insert
  local pairs = pairs
  local max, abs = math.max, math.abs
  local assert = assert

  -- Loads dependancies
  local Heuristic = require (_PATH .. 'core.heuristics')
  local Grid = require (_PATH ..'core.grid')
  local Heap = require (_PATH .. 'core.third-party.Binary-Heaps.binary_heap')
  local Class = require (_PATH .. 'core.third-party.30log.30log')

  -- Will keep track of all nodes expandes during the search
  local toClear = {}
  
  -- Keeps track of the lastest computed path cost
  local cost = 0
  
  -- Check if a node is reachable in diagonal-search mode
  -- Will prevent from "tunneling" issue
  local step_first = false
  local function testFirstStep(grid, jx,jy,x,y)
    local is_reachable = true
    local dx,dy = jx-x, jy-y
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

  -- Local helpers, these routines will stay private
  -- As they are internally used by the main public class

  -- Resets only nodes expanded during a search
  -- This is a lot faster than resetting all nodes
  -- Between successive pathfinding calls
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
        cost = self.endNode.f
        reset()
        return self.autoFill and self:fill(path) or path
      end
    end
    
    cost = 0
    reset()
    return nil
  end

  --[[
    Looks for the neighbours of a given node.
    Returns its natural neighbours plus forced neighbours when the given
    node has no parent (generally occurs with the starting node).
    Otherwise, based on the direction of move from the parent, returns
    neighbours while pruning directions which will lead to symmetric paths.

    Tweak : In case diagonal moves are forbidden, when the given node has no
    parent, we return straight neighbours (up, down, left and right).
    Otherwise, we add left and right node (perpendicular to the direction
    of move) in the neighbours list.
  --]]
  local function findNeighbours(self,node)
    local parent = node.parent
    local neighbours = {}

    local x,y = node.x,node.y
    local px,py,dx,dy

    if parent then
      -- Node have a parent, we will prune some neighbours
      px,py = parent.x,parent.y

      -- Gets the direction of move
      dx = (x-px)/max(abs(x-px),1)
      dy = (y-py)/max(abs(y-py),1)

        -- Diagonal move case
      if dx~=0 and dy~=0 then
        -- Natural neighbours
        if self.grid:isWalkableAt(x,y+dy) then neighbours[#neighbours+1]={x = x, y = y+dy } end
        if self.grid:isWalkableAt(x+dx,y) then neighbours[#neighbours+1]={x = x+dx, y = y} end
        if self.grid:isWalkableAt(x,y+dy) or self.grid:isWalkableAt(x+dx,y) then neighbours[#neighbours+1]={x = x+dx, y = y+dy} end
        -- Forced neighbours
        if (not self.grid:isWalkableAt(x-dx,y)) and self.grid:isWalkableAt(x,y+dy) then neighbours[#neighbours+1]={x = x-dx, y = y+dy} end
        if (not self.grid:isWalkableAt(x,y-dy)) and self.grid:isWalkableAt(x+dx,y) then neighbours[#neighbours+1]={x = x+dx, y = y-dy} end
      else
        -- Move along Y-axis case
        if dx==0 then
          if self.grid:isWalkableAt(x,y+dy) then
            -- Natural neighbour is ahead along Y
            if self.grid:isWalkableAt(x,y+dy) then neighbours[#neighbours+1]={x = x, y = y +dy} end
            -- Forced neighbours are left and right ahead along Y
            if (not self.grid:isWalkableAt(x+1,y)) then neighbours[#neighbours+1]={x = x+1, y = y+dy} end
            if (not self.grid:isWalkableAt(x-1,y)) then neighbours[#neighbours+1]={x = x-1, y = y+dy} end
          end
          --Tweak : In case diagonal moves are forbidden
          if not self.allowDiagonal then
            if self.grid:isWalkableAt(x+1,y) then neighbours[#neighbours+1]={x = x+1, y = y} end
            if self.grid:isWalkableAt(x-1,y) then neighbours[#neighbours+1]={x = x-1, y = y} end
          end
        else
        -- Move along X-axis case
          if self.grid:isWalkableAt(x+dx,y) then
            -- Natural neighbour is ahead along X
            if self.grid:isWalkableAt(x+dx,y) then neighbours[#neighbours+1]={x = x+dx, y = y} end
            -- Forced neighbours are up and down ahead along X
            if (not self.grid:isWalkableAt(x,y+1)) then neighbours[#neighbours+1]={x = x+dx, y = y+1} end
            if (not self.grid:isWalkableAt(x,y-1)) then neighbours[#neighbours+1]={x = x+dx, y = y-1} end
          end
          --Tweak : In case diagonal moves are forbidden
          if not self.allowDiagonal then
            if self.grid:isWalkableAt(x,y+1) then neighbours[#neighbours+1]={x = x, y = y+1} end
            if self.grid:isWalkableAt(x,y-1) then neighbours[#neighbours+1]={x = x, y = y-1} end
          end
        end
      end
    else
    -- Node do not have parent, we return all neighbouring nodes
      neighbours = self.grid:getNeighbours(node,self.allowDiagonal)
    end
    return neighbours
  end



  --[[
    Searches for a jump point (or a turning point) in a specific direction.
    This is a generic translation of the algorithm 2 in the paper:
      http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
    The current node, to be examined happens to be a jump point if near a forced node
    ahead, in the direction of move.

    Tweak : In case diagonal moves are forbidden, when lateral nodes (perpendicular to
    the direction of moves are walkable, we force them to be turning points in other
    to perform a straight move.
  --]]
  local function jump(self,x,y,px,py)
    local dx, dy = x - px,y - py
    local jphx,jphy,jpvx,jpvy

    -- If the node to be examined is unwalkable, return nil
    if not self.grid:isWalkableAt(x,y) then return nil end

    -- If the node to be examined is the endNode, return this node
    if self.grid:getNodeAt(x,y) == self.endNode then return x,y end

    -- Diagonal search case
    if dx~=0 and dy~=0 then
      -- Current node is a jump point if one of his leftside/rightside neighbours ahead is forced
      if (self.grid:isWalkableAt(x-dx,y+dy) and (not self.grid:isWalkableAt(x-dx,y))) or
         (self.grid:isWalkableAt(x+dx,y-dy) and (not self.grid:isWalkableAt(x,y-dy))) then
        return x,y
      end
    else
      -- Search along X-axis case
      if dx~=0 then
        if self.allowDiagonal then
          -- Current node is a jump point if one of his upside/downside neighbours is forced
          if (self.grid:isWalkableAt(x+dx,y+1) and (not self.grid:isWalkableAt(x,y+1))) or
             (self.grid:isWalkableAt(x+dx,y-1) and (not self.grid:isWalkableAt(x,y-1))) then
            return x,y
          end
        else
          -- Tweak : in case diagonal moves are forbidden
          if self.grid:isWalkableAt(x+1,y) or self.grid:isWalkableAt(x-1,y) then return x,y end
        end
      else
      -- Search along Y-axis case
        -- Current node is a jump point if one of his leftside/rightside neighbours is forced
        if self.allowDiagonal then
          if (self.grid:isWalkableAt(x+1,y+dy) and (not self.grid:isWalkableAt(x+1,y))) or
             (self.grid:isWalkableAt(x-1,y+dy) and (not self.grid:isWalkableAt(x-1,y))) then
            return x,y
          end
        else
          -- Tweak : in case diagonal moves are forbidden
          if self.grid:isWalkableAt(x,y+1) or self.grid:isWalkableAt(x,y-1) then return x,y end
        end
      end
    end

    -- Diagonal search case
    if dx~=0 and dy~=0 then
      -- Is there a jump point from the current node ahead along X-axis ?
      jphx,jphy = jump(self,x+dx,y,x,y)
      if (jphx and jphy) then return x,y end
      -- Is there a jump point from the current node ahead along Y-axis ?
      jpvx,jpvy = jump(self,x,y+dy,x,y)
      -- If so, the current node is a jump point
      if (jpvx and jpvy) then return x, y end
    end

    -- Recursive search for a jump point diagonally
    if self.allowDiagonal then
      if self.grid:isWalkableAt(x+dx,y) or self.grid:isWalkableAt(x,y+dy) then
        return jump(self,x+dx,y+dy,x,y)
      end
    end
end

  --[[
    Searches for successors of a given node in the direction of each of its neighbours.
    This is a generic translation of the algorithm 1 in the paper:
      http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf

    Tweak : In case a jump point was found, and this node happened to be diagonal to the
    node currently expanded, we skip this jump point in other to cancel any diagonal move.
  --]]
  local function identifySuccessors(self,node)
    local grid = self.grid
    local heuristic = self.heuristic
    local openList = self.openList
    local endX,endY = self.endNode.x,self.endNode.y

    local x,y = node.x,node.y
    local jumpPointX, jumpPointY, jumpNode

    -- Gets the valid neighbours of the given node
    -- Looks for a jump point in the direction of each neighbour
    local neighbours = findNeighbours(self,node)
    for i = #neighbours,1,-1 do
      local skip = false
      local neighbour = neighbours[i]
      jumpPointX, jumpPointY = jump(self,neighbour.x,neighbour.y,x,y)

      -- Tweak : in case a diagonal jump point was found in straight mode, skip it.
      if jumpPointX and jumpPointY and not self.allowDiagonal then
        if ((jumpPointX ~= x) and (jumpPointY ~= y)) then skip = true end
      end

      -- Hacky trick to discard "tunneling" in diagonal mode for the first step
      if self.allowDiagonal and not step_first then
        if jumpPointX == self.endNode.x and jumpPointY == self.endNode.y then
          step_first = true
          if not skip then
            skip = testFirstStep(self.grid, jumpPointX, jumpPointY, x, y)
          end
        end
      end

      -- Performs regular A-star
      if jumpPointX and jumpPointY and not skip then
        jumpNode = self.grid:getNodeAt(jumpPointX,jumpPointY)
        toClear[jumpNode] = true
        -- Update the jump node using heuristics and move it in the closed list
        if not jumpNode.closed then
          local dist = Heuristic.EUCLIDIAN(jumpPointX-x,jumpPointY-y)
          local ng = node.g + dist
          if not jumpNode.opened or ng < jumpNode.g then
            jumpNode.g = ng
            jumpNode.h = jumpNode.h or (self.heuristic(jumpPointX-endX,jumpPointY-endY))
            jumpNode.f = jumpNode.g+jumpNode.h
            jumpNode.parent = node
            if not jumpNode.opened then
              self.openList:insert(jumpNode)
              if not step_first then step_first = true end
              jumpNode.opened = true
            else
              self.openList:heap()
            end
          end
        end
      end
    end
  end

  -- Jump Point Search Class
  local JPS = Class {
    allowDiagonal = true, -- By default, allows diagonal moves
    autoFill = false -- Will not fill paths by default
  }

  -- Custom initializer (walkable, allowDiagonal,heuristic and autoFill are optional)
  function JPS:__init(map,walkable,allowDiagonal,heuristicName,autoFill,postProcess)
    self.grid = Grid(map,walkable,postProcess)
    self.allowDiagonal = allowDiagonal
    self:setHeuristic(heuristicName or 'MANHATTAN')
    self.autoFill = autoFill or false
  end

  -- Changes the heuristic
  function JPS:setHeuristic(distanceName)
    assert(Heuristic[distanceName],'Not a valid heuristic name!')
    self.heuristic = Heuristic[distanceName]
    self._heuristicName = distanceName
    return self
  end

  -- Gets the name of the heuristic currently used, as a string
  function JPS:getHeuristic()
    return Heuristic[self._heuristicName]
  end

  -- Enables or disables diagonal moves
  function JPS:setDiagonalMoves(bool)
    assert(type(bool) == 'boolean','Argument must be a boolean')
    self.allowDiagonal = bool
    return self
  end

  -- Returns whether diagonal moves are enabled or not
  function JPS:getDiagonalMoves()
    return self.allowDiagonal
  end

  -- Enables or disables autoFill feature
  function JPS:setAutoFill(bool)
    assert(type(bool) == 'boolean','Argument must be a boolean')
    self.autoFill = bool
    return self
  end

  -- Returns whether or not autoFillfeature is activated
  function JPS:getAutoFill()
    return self.autoFill
  end

  --[[
    Main search fuction. Requires a start x,y and an end x,y coordinates.
    StartNode and endNode must be walkable.
    Returns the path when found, otherwise nil.
  --]]
  function JPS:getPath(startX,startY,endX,endY)
    self.openList = Heap()
    self.startNode = self.grid:getNodeAt(startX,startY)
    self.endNode = self.grid:getNodeAt(endX,endY)
    local node

    step_first = false

    -- Moves the start node in the openList
    self.startNode.g, self.startNode.f = 0,0
    self.openList:insert(self.startNode)
    self.startNode.opened = true
    toClear[self.startNode] = true

    while not self.openList:empty() do
      -- Pops the lowest-F node, moves it in the closed list
      node = self.openList:pop()
      node.closed = true
        -- If the popped node is the endNode, traceback and return the path and the path cost
        if node == self.endNode then  return traceBackPath(self),cost end
      -- Else, identify successors of the popped node
      identifySuccessors(self,node)
    end

    -- No path found, return nil
    return nil
  end

  --[[
    Naive path filling helper. As the path returned with JPS algorithm
    consists of straight lines, they maybe some holes inside. This function
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

  -- Returns a pointer to the internal grid
  function JPS:getGrid()
    return self.grid
  end

  -- Returns pathfinder
  return JPS
end
