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

if (...) then
  local _PATH = (...):gsub('[^%.]+$','')
  local pairs = pairs

  -- Loads dependancies
  local Class = require (_PATH .. 'third-party.30log.30log')
  local Node = require (_PATH .. 'node')

  -- Private utilities
  -- Creates a list of nodes, given a 2D map
  local function buildGrid(map, walkable)
    local map_width, map_height = 0,0
    local nodes = {}
      for y in pairs(map) do
      map_height = map_height+1
      nodes[y] = {}
        for x in pairs(map[y]) do
          map_width = map_width+1
          nodes[y][x] = Node(x,y,(map[y][x] == walkable))
        end
      end
    return nodes, map_width/map_height, map_height
  end

  -- Checks if a value is within interval [lowerBound,upperBound]
  local function within(i,lowerBound,upperBound)
    return (i>= lowerBound and i<= upperBound)
  end

  -- Set of vectors used to identify neighbours of a given location <x,y> on a 2D grid
  local xOffsets = {-1,0,1,0}
  local yOffsets = {0,1,0,-1}
  local xDiagonalOffsets = {-1,-1,1,1}
  local yDiagonalOffsets = {-1,1,1,-1}

  ---------------------------------------------------------------------

  -- Creates a grid class
  local Grid = Class {
    width = 0, height = 0,
    walkable = 0,
    map = {}, nodes = {},
  }

  -- Custom initializer
  function Grid:__init(map,walkable)
    self.map = map
    self.walkable = walkable or 0
    self.nodes, self.width, self.height = buildGrid(self.map,self.walkable)
  end

  -- Returns the node at a given position
  function Grid:getNodeAt(x,y)
    return self.nodes[y] and self.nodes[y][x] or nil
  end

  -- Checks if node [x,y] exists and is walkable
  function Grid:isWalkableAt(x,y)
    return self.nodes[y] and self.nodes[y][x] and self.nodes[y][x].walkable
  end

  -- Sets Node [x,y] as obstructed or not
  function Grid:setWalkableAt(x,y,walkable)
    self.nodes[y][x].walkable = walkable
  end

  -- Returns the neighbours of a given node on a grid
  function Grid:getNeighbours(node,allowDiagonal)
    local x,y = node.x,node.y
    local nx , ny
    local neighbours = {}

    for i=1,#xOffsets do
      nx, ny = x+xOffsets[i],y+yOffsets[i]
      if self:isWalkableAt(nx,ny) then
        neighbours[#neighbours+1] = {x = nx, y = ny}
      end
    end

    if not allowDiagonal then return neighbours end

    for i=1,#xDiagonalOffsets do
      nx, ny = x+xDiagonalOffsets[i],y+yDiagonalOffsets[i]
      if self:isWalkableAt(nx,ny) then
        neighbours[#neighbours+1] = {x = nx, y = ny}
      end
    end

    return neighbours
  end

  return Grid
end


