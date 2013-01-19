--- <strong>The <code>grid</code> class API</strong>.
-- 
-- This file contains the implementation of a `grid` class, internally used by the 
-- search algorithm. The `grid` object is automatically generated upon initialization of the 
-- `pathfinder` object, passing it a mandatory *collision map*. 
-- During a search, the pathfinder evaluates __costs values__ for each node being processed, in order to
-- select, after each step of iteration, what node should be expanded next to reach the target 
-- optimally. Those values are cached within an array stored in the `grid` object.
-- 
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module core.grid

if (...) then
  local _PATH = (...):gsub('[^%.]+$','')
  local pairs = pairs
  local assert = assert
  local next = next
  local type = type
  local Node = require (_PATH .. 'node')

  ---------------------------------------------------------------------
  -- Private utilities
  -- Parses a map
  
  local function parseMap(map)
	local map = {}
  local w, h
    for line in str:gmatch('[^\n\r]+') do
      if line then
        w = not w and #line or w
        assert(#line == w, 'Error parsing map, rows must have the same size!')
        h = (h or 0) + 1
        map[h] = {}
        for char in line:gmatch('.') do map[h][#map[h]+1] = char end
      end
    end
    return map
  end
  
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
    local min_bound_x, max_bound_x
    local min_bound_y, max_bound_y
    
    local nodes = {}
      for y in pairs(map) do
        min_bound_y = not min_bound_y and y or (y<min_bound_y and y or min_bound_y)
        max_bound_y = not max_bound_y and y or (y>max_bound_y and y or max_bound_y)
        nodes[y] = {}
        for x in pairs(map[y]) do
          min_bound_x = not min_bound_x and x or (x<min_bound_x and x or min_bound_x)
          max_bound_x = not max_bound_x and x or (x>max_bound_x and x or max_bound_x)
          nodes[y][x] = Node:new(x,y)
        end
      end
    return nodes, min_bound_x,max_bound_x,min_bound_y,max_bound_y
  end

  -- Checks if a value is out of and interval [lowerBound,upperBound]
  local function outOfRange(i,lowerBound,upperBound)
    return (i< lowerBound or i > upperBound)
  end

  local offsets = {
    {x = 1, y = 0} --[[W]], {x = -1, y =  0}, --[[E]]
    {x = 0, y = 1} --[[S]], {x =  0, y = -1}, --[[N]]
    {x = -1, y = -1} --[[NW]], {x = 1, y = -1}, --[[NE]]
    {x = -1, y =  1} --[[SW]], {x = 1, y =  1}, --[[SE]]
 }    
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
  --- The `grid` class
  -- @class table
  -- @name grid
  -- @field width The grid width
  -- @field height The grid height 
  -- @field walkable The value for walkable nodes 
  -- @field map A reference to the collision map 
  -- @field nodes A 2D array of nodes, each node matching a cell on the collision map
  local Grid = {
    width = 0, height = 0, map = {}, nodes = {} }
  
  Grid.__index = Grid
  
  local PreProcessGrid = setmetatable({},Grid)
  local PostProcessGrid = setmetatable({},Grid)
  PreProcessGrid.__index = PreProcessGrid
  PostProcessGrid.__index = PostProcessGrid
  PreProcessGrid.__call = function (self,x,y) return self:getNodeAt(x,y) end
  PostProcessGrid.__call = function (self,x,y,create)
    if create then return self:getNodeAt(x,y) end
    return self.nodes[y] and self.nodes[y][x]
  end
  
  --- Inits a new `grid` object
  -- @class function
  -- @name grid:new
  -- @tparam table|string map A collision map - (2D array) with consecutive integer indices or a string with line-break symbol as a row delimiter.
  -- @tparam[opt] string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean: 
  -- `true` when value matches a *walkable* node, `false` otherwise.
  -- @tparam[optchain] bool processOnDemand whether or not caching nodes in the internal grid should be processed on-demand
  -- @treturn grid a new `grid` object   
  function Grid:new(map,walkable,processOnDemand)
    map = type(map)=='string' and parseMap(map) or map
    if processOnDemand then
      return PostProcessGrid:new(map,walkable)
    end
    return PreProcessGrid:new(map,walkable)
  end

  --- Checks walkability. Tests if `node` [x,y] exists on the collision map and is walkable
  -- @class function
  -- @name grid:isWalkableAt
  -- @tparam int x the x-coordinate of the node
  -- @tparam int y the y-coordinate of the node
  -- @treturn bool `true` if the node exist and is walkable, `false` otherwise
  function Grid:isWalkableAt(x,y)
    if not self.walkable then return true end
    local nodeValue = self.map[y] and self.map[y][x]
    if nodeValue then
      return self.evalf and self.walkable(nodeValue) or (self.walkable == nodeValue)
    end
  end

  --- Returns the neighbours of a given `node` on a grid
  -- @class function
  -- @name grid:getNeighbours
  -- @tparam node node `node` object
  -- @tparam[opt] bool allowDiagonal whether or not 8-directions movements is allowed  
  -- @treturn {node,...} an array of nodes neighbouring a passed-in node on the collision map
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

  --- Iterates on nodes on the grid. When given no args, will iterate on every single node
  -- on the grid, in case the grid is pre-processed. Passing `lx, ly, ex, ey` args will iterate
  -- on nodes inside a bounding-rectangle delimited by those coordinates.
  -- @class function
  -- @name grid:iter
  -- @tparam[opt] int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam[optchain] int ly the topmost y-coordinate of the rectangle
  -- @tparam[optchain] int ex the rightmost x-coordinate of the rectangle
  -- @tparam[optchain] int ey the bottom-most y-coordinate of the rectangle
  -- @treturn node a node on the collision map, upon each iteration step  
  function Grid:iter(lx,ly,ex,ey)  
    local min_x = lx or self.min_bound_x
    local min_y = ly or self.min_bound_y
    local max_x = ex or self.max_bound_x
    local max_y = ey or self.max_bound_y
    
    local x, y
    y = min_y
    return function()
      x = not x and min_x or x+1
      if x>max_x then
        x = min_x
        y = y+1
      end
      if y > max_y then
        y = nil
      end
      return self.nodes[y] and self.nodes[y][x] or self:getNodeAt(x,y)     
    end      
  end
  
  --- Each iterator. Executes a function on each `node` in the `grid`, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:each
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`  
  function Grid:each(f,...)
    for node in self:iter() do f(node,...) end  
  end

  --- Each range interator. Executes a function on each `node` in the range of a rectangle of cells, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:eachRange
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle  
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`  
  function Grid:eachRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do f(node,...) end  
  end

  --- Map iterator. Maps function `f(node,...)` on each `node` in a given range, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:imap
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`  
  function Grid:imap(f,...)
    for node in self:iter() do
      node = f(node,...)
    end
  end
  
  --- Map range iterator. Maps `f(node,...)` on each `nod`e in the range of a rectangle of cells, passing the `node` as the first arg to function `f`.
  -- @class function
  -- @name grid:imapRange
  -- @tparam int lx the leftmost x-coordinate coordinate of the rectangle
  -- @tparam int ly the topmost y-coordinate of the rectangle
  -- @tparam int ex the rightmost x-coordinate of the rectangle
  -- @tparam int ey the bottom-most y-coordinate of the rectangle  
  -- @tparam function f a function prototyped as `f(node,...)`
  -- @tparam[opt] vararg ... args to be passed to function `f`   
  function Grid:imapRange(lx,ly,ex,ey,f,...)
    for node in self:iter(lx,ly,ex,ey) do
      node = f(node,...)
    end
  end
  
  
  -- Specialized grids
  -- Inits a preprocessed grid
  function PreProcessGrid:new(map,walkable)
    local newGrid = {}
    newGrid.map = map
    newGrid.walkable = walkable
    newGrid.nodes, newGrid.min_bound_x, newGrid.max_bound_x, newGrid.min_bound_y, newGrid.max_bound_y = buildGrid(newGrid.map,newGrid.walkable)
    newGrid.width = (newGrid.max_bound_x-newGrid.min_bound_x)+1
    newGrid.height = (newGrid.max_bound_y-newGrid.min_bound_y)+1
    newGrid.evalf = type(walkable)=='function'
    return setmetatable(newGrid,PreProcessGrid)
  end

  -- Inits a postprocessed grid
  function PostProcessGrid:new(map,walkable)
    local newGrid = {}
    newGrid.map = map
    newGrid.walkable = walkable
    newGrid.nodes = {}
    newGrid.min_bound_x, newGrid.max_bound_x, newGrid.min_bound_y, newGrid.max_bound_y = getBounds(newGrid.map)
    newGrid.width = (newGrid.max_bound_x-newGrid.min_bound_x)+1
    newGrid.height = (newGrid.max_bound_y-newGrid.min_bound_y)+1
    newGrid.evalf = type(walkable)=='function'    
    return setmetatable(newGrid,PostProcessGrid)
  end

  --- Returns the `node`[x,y] on a `grid`.
  -- @class function
  -- @name grid:getNodeAt
  -- @tparam int x the x-coordinate coordinate
  -- @tparam int y the y-coordinate coordinate
  -- @treturn node a `node` object  
  -- Gets the node at location <x,y> on a preprocessed grid
  function PreProcessGrid:getNodeAt(x,y)
    return self.nodes[y] and self.nodes[y][x] or nil
  end

  -- Gets the node at location <x,y> on a postprocessed grid
  function PostProcessGrid:getNodeAt(x,y)
    if not x or not y then return end
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
