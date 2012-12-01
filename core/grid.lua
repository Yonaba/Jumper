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
  local assert = assert
  local Node = require (_PATH .. 'node')

  ---------------------------------------------------------------------
  -- Private utilities
  -- Postprocessing : Get map bounds
  local function getBounds(map)
    local min_bound_x, max_bound_x
    local min_bound_y, max_bound_y

      for y in pairs(map) do
        min_bound_y = not min_bound_y and y or (y<min_bound_y and y or min_bound_y)
        max_bound_y = not max_bound_y and y or (y>max_bound_y and y or max_bound_y)
        for x in pairs(map[y]) do
          min_bound_x = not min_bound_x and x or (x<min_bound_x and x or min_bound_x)
          max_bound_x = not max_bound_x and x or (x>max_bound_x and x or max_bound_x)
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
          nodes[y][x] = Node:new(x,y)
        end
      end
    return nodes, map_width/map_height, map_height
  end

  -- Checks if a value is out of and interval [lowerBound,upperBound]
  local function outOfRange(i,lowerBound,upperBound)
    return (i< lowerBound or i > upperBound)
  end

  -- Offsets for straights moves
  local straightOffsets = {
    {x = 1, y = 0} --[[W]], {x = -1, y =  0}, --[[E]]
    {x = 0, y = 1} --[[S]], {x =  0, y = -1}, --[[N]]
  }
  
  -- Offsets for diagonal moves
  local diagonalOffsets = {
    {x = -1, y = -1} --[[NW]], {x = 1, y = -1}, --[[NE]]
    {x = -1, y =  1} --[[SW]], {x = 1, y =  1}, --[[SE]]
  }  

  ---------------------------------------------------------------------

  -- Creates a grid class
  local Grid = {
    width = 0, height = 0,
    walkable = 0,
    map = {}, nodes = {},
  }
  
  Grid.__index = Grid

  local PreProcessGrid = setmetatable({},Grid)
  local PostProcessGrid = setmetatable({},Grid)
  PreProcessGrid.__index = PreProcessGrid
  PostProcessGrid.__index = PostProcessGrid
  
  -- Returns a new grid
  function Grid:new(map,walkable,postProcess)
    if postProcess then
      return PostProcessGrid:new(map,walkable)
    end
    return PreProcessGrid:new(map,walkable)
  end

  -- Checks if node [x,y] exists and is walkable
  function Grid:isWalkableAt(x,y)
    return self.map[y] and self.map[y][x] and (self.map[y][x] == self.walkable)
  end

    -- Sets Node [x,y] as obstructed or not
  function Grid:setWalkableAt(x,y,walkable)
    assert(self.map[y] and self.map[y][x], ('Location [%d,%d] is out of bounds!'):format(x,y))
    self.map[y][x] = walkable
  end

  -- Returns the neighbours of a given node on a grid
  function Grid:getNeighbours(node,allowDiagonal)
    local neighbours = {}
    
    for i = 1,#straightOffsets do
      local node = self:getNodeAt(
        node.x + straightOffsets[i].x,
        node.y + straightOffsets[i].y
      )
      if node and self:isWalkableAt(node.x, node.y) then 
        neighbours[#neighbours+1] = node 
      end
    end
    
    if not allowDiagonal then return neighbours end

    for i = 1,#diagonalOffsets do
      local node = self:getNodeAt(
        node.x + diagonalOffsets[i].x,
        node.y + diagonalOffsets[i].y
      )
      if node and self:isWalkableAt(node.x, node.y) then 
        neighbours[#neighbours+1] = node 
      end
    end
    
    return neighbours
  end

  -- Specialized grids
  -- Inits a preprocessed grid
  function PreProcessGrid:new(map,walkable)
    local newGrid = {}
    newGrid.map = map
    newGrid.walkable = walkable or 0
    newGrid.nodes, newGrid.width, newGrid.height = buildGrid(newGrid.map,newGrid.walkable)
    return setmetatable(newGrid,PreProcessGrid)
  end

  -- Inits a postprocessed grid
  function PostProcessGrid:new(map,walkable)
    local newGrid = {}
    newGrid.map = map
    newGrid.walkable = walkable or 0
    newGrid.nodes = {}
    newGrid.min_bound_x, newGrid.max_bound_x, newGrid.min_bound_y, newGrid.max_bound_y = getBounds(newGrid.map)
    newGrid.width = (newGrid.max_bound_x-newGrid.min_bound_x)+1
    newGrid.height = (newGrid.max_bound_y-newGrid.min_bound_y)+1
    return setmetatable(newGrid,PostProcessGrid)
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
    if not self.nodes[y][x] then self.nodes[y][x] = Node:new(x,y) end
    return self.nodes[y][x]
  end

  return setmetatable(Grid,{
    __call = function(self,...)
      return self:new(...)
    end
  })

end


