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
  -- Postprocessing
  local function getBounds(map)
    local min_bound_x, max_bound_x
    local min_bound_y, max_bound_y
   
      for y in pairs(map) do
        min_bound_y = not min_bound_y and y or (y<min_bound_y and y or min_bound_y)
        max_bound_y = not max_bound_y and y or (y>max_bound_y and y or max_bound_y)
        --nodes[y] = {}
        for x in pairs(map[y]) do
          min_bound_x = not min_bound_x and x or (x<min_bound_x and x or min_bound_x)
          max_bound_x = not max_bound_x and x or (y>max_bound_x and y or max_bound_x)
          --nodes[y][x] = Node(x,y)
        end
      end
    return min_bound_x,max_bound_x,min_bound_y,max_bound_y
  end
  
  -- Preprocessing
  local function buildGrid(map, walkable)
    local map_width, map_height = 0,0
    local nodes = {}
      for y in pairs(map) do
      map_height = map_height+1
      nodes[y] = {}
        for x in pairs(map[y]) do
          map_width = map_width+1
          nodes[y][x] = Node(x,y)
        end
      end
    return nodes, map_width/map_height, map_height
  end

  -- Checks if a value is out of and interval [lowerBound,upperBound] 
  -- Early exit approach, faster than checking "i inside [l,u]"
  local function outOfRange(i,lowerBound,upperBound)
    return (i< lowerBound or i > upperBound)
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
  
  local PreProcessGrid = Grid:extends()
  local PostProcessGrid = Grid:extends()
  
  -- Returns a new grid
  function Grid:new(map,walkable,postProcess)
    if postProcess then 
      return PostProcessGrid(map,walkable) 
    end
    return PreProcessGrid(map,walkable)
  end
  
  -- Checks if node [x,y] exists and is walkable
  function Grid:isWalkableAt(x,y)
    return self.map[y] and self.map[y][x] and (self.map[y][x]==self.walkable)
  end
  
    -- Sets Node [x,y] as obstructed or not
  function Grid:setWalkableAt(x,y,walkable)
    self.map[y][x] = walkable
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
  
  -- Specialization for derived classes
  
  -- Inits a preprocessed grid
  function PreProcessGrid:__init(map,walkable)
    print('PreProcessing')
    self.map = map
    self.walkable = walkable or 0
    self.nodes, self.width, self.height = buildGrid(self.map,self.walkable)  
  end

  -- Inits a postprocessed grid
  function PostProcessGrid:__init(map,walkable)
    print('PostProcessing')
    self.map = map
    self.walkable = walkable or 0
    self.nodes = {}
    self.min_bound_x, self.max_bound_x, self.min_bound_y, self.max_bound_y = getBounds(self.map,postProcess)
    self.width = (self.max_bound_x-self.min_bound_x)+1
    self.height = (self.max_bound_y-self.min_bound_y)+1
  end

  -- Gets the node at location <x,y> on a preprocessed grid
  function PreProcessGrid:getNodeAt(x,y)
    return self.nodes[y] and self.nodes[y][x] or nil
  end
  
  -- Gets the node at location <x,y> on a postprocessed grid
  function PostProcessGrid:getNodeAt(x,y)
    if outOfRange(x,self.min_bound_x,self.max_bound_x) then return end
    if outOfRange(y,self.min_bound_y,self.max_bound_y) then return end
    if not self.nodes[y] then self.nodes[y] = {} end
    if not self.nodes[y][x] then self.nodes[y][x] = Node(x,y) end
    return self.nodes[y][x]
  end

  return Grid
end


