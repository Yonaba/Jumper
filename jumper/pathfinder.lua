--- <strong>The <strong>pathfinder</strong> class API</strong>.
--
-- This file holds the implementation of the `pathfinder` class.
-- 
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script pathfinder

local _VERSION = "1.7.0"
local _RELEASEDATE = "01/22/2013"

--- @usage
local usage = [[
-- Usage Example
-- First, set a collision map
local map = {
	{0,1,0,1,0 },
	{0,1,0,1,0 },
	{0,1,1,1,0 },
	{0,0,0,0,0 },
}
-- Value for walkable tiles
local walkable = 0 

-- Library setup
local Pathfinder = require ("jumper.init")
local myFinder = Pathfinder(map,walkable)

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path, length = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(length))
	for x,y,step in path:iter() do
	  print(('Step: %d - x: %d - y: %d'):format(step,x,y))
	end
end
]]




if (...) then

  -- Internalization
  local t_insert, t_remove = table.insert, table.remove
  local pairs = pairs
  local assert = assert
  local setmetatable = setmetatable
  
  -- Loads dependancies
  local _PATH = (...):gsub('%.pathfinder$','')  
  local Heuristic = require (_PATH .. '.core.heuristics')
  local Grid = require (_PATH ..'.core.grid')
  local Heap = require (_PATH .. '.core.bheap')

  -- Available search algorithms
  local Finders = {
    ['ASTAR'] = require (_PATH .. '.search.astar'),
    ['JPS'] = require (_PATH .. '.search.jps'),
  }

  -- Collect keys in an array
  local function collect_keys(t)
    local keys = {}
    for k,v in pairs(t) do keys[#keys+1] = k end
    return keys
  end
  
  -- Arg type checking
  local function type_checking(testArg, argName, argI, ...)
    local argType = type(testArg)
    local validTypes = table.concat({...},'.')
    local displayTypes = validTypes:gsub('%.',', ')
      :gsub('(,)(%s%w+)$',function(comma,str) return ' or'..str end)
    local errmsg = ('Bad argument #%d. Expected arg \'%s\' to be %s, got %s.')
      :format(argI, argName,displayTypes,argType)
    local check = (validTypes:match(argType))
    if check then return true end
    return false, errmsg
  end
  
  -- Will keep track of all nodes expanded during the search
  -- to easily reset their properties for the next pathfinding call
  local toClear = {}

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

  -- Keeps track of the last computed path cost
  local lastPathCost = 0

  -- Path iterator
  local path_mt = {}
  path_mt.__index = path_mt
  function path_mt:iter()
    local i,pathLen = 1,#self
    return function()
      if self[i] then
        local x, y = self[i].x, self[i].y
        i = i+1
        return x,y,i-1
      end
    end
  end

  -- Availables search modes
  local searchModes = {['DIAGONAL'] = true, ['ORTHOGONAL'] = true}

  -- Performs a traceback from the goal node to the start node
  -- Only happens when the path was found
  local function traceBackPath(finder, node, startNode)
    local path = setmetatable({node}, path_mt)
    lastPathCost = node.f

    while true do
      if node.parent then
        t_insert(path,1,node)
        node = node.parent
      else
        reset()
        t_insert(path,1,startNode)
        return path
      end
    end
  end

  --- The `pathfinder` class
  -- @class table
  -- @name pathfinder
  local Pathfinder = {}
  Pathfinder.__index = Pathfinder

  --- Inits a new `pathfinder` object
  -- @class function
  -- @name pathfinder:new
  -- @tparam table|string map A collision map - (2D array) with consecutive integer indices or a string with line-break symbol as a row delimiter.
  -- @tparam[opt] string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean: 
  -- `true` when value matches a *walkable* node, `false` otherwise.
  -- @tparam[optchain] bool processOnDemand whether or not caching nodes in the internal grid should be processed on-demand
  -- @treturn pathfinder a new `pathfinder` object  
  function Pathfinder:new(map, walkable, processOnDemand)
  
    assert(type_checking(map, 'map', 1, 'table','string'))
    assert(type_checking(walkable, 'walkable', 2, 'string','number','function'))
    assert(type_checking(processOnDemand, 'processOnDemand', 3, 'boolean','nil'))
    
    local newPathfinder = {}
    setmetatable(newPathfinder, Pathfinder)
    newPathfinder.grid = Grid:new(map, walkable, processOnDemand)
    newPathfinder.openList = Heap()
    newPathfinder:setMode('DIAGONAL')
    newPathfinder:setHeuristic('MANHATTAN')
    newPathfinder:setFinder('JPS')
    return newPathfinder
  end

  --- Sets a finder. The finder refers to the search algorithm used by the `pathfinder` object.
  -- The default finder is `JPS` (for *Jump Point Search*), which is the fastest available.
  -- Use @{pathfinder:getFinders} to get the list of available finders.
  -- @class function
  -- @name pathfinder:setFinder
  -- @tparam string finderName the name of the finder to be used for further searches.
  -- @see pathfinder:getFinders
  function Pathfinder:setFinder(finderName)
    assert(Finders[finderName],'Not a valid finder name!')
    self.finder = finderName
    return self
  end

  --- Gets the name of the finder being used. The finder refers to the search algorithm used by the `pathfinder` object.
  -- @class function
  -- @name pathfinder:getFinder
  -- @treturn string the name of the finder to be used for further searches.  
  function Pathfinder:getFinder()
    return self.finder
  end

  --- Gets the list of all available finders names.
  -- @class function
  -- @name pathfinder:getFinders
  -- @treturn {string,...} array of finders names.  
  function Pathfinder:getFinders()
    return collect_keys(Finders)
  end
  
  --- Set a heuristic. This is a function internally used by the `pathfinder` to get the optimal path during a search.
  -- Use @{pathfinder:getHeuristics} to get the list of all available heuristics. One can also defined
  -- his own heuristic function.
  -- @class function
  -- @name pathfinder:setHeuristic
  -- @tparam function|string heuristic a heuristic function, prototyped as `f(dx,dy)` or a string.  
  -- @see pathfinder:getHeuristics
  function Pathfinder:setHeuristic(heuristic)
    assert(Heuristic[heuristic] or (type(heuristic) == 'function'),'Not a valid heuristic!')
    self.heuristic = Heuristic[heuristic] or heuristic
    return self
  end

  --- Gets the heuristic used. Returns the function itself.
  -- @class function
  -- @name pathfinder:getHeuristic
  -- @treturn function the heuristic function being used by the `pathfinder` object  
  function Pathfinder:getHeuristic()
    return self.heuristic
  end
  
  --- Gets the list of all available heuristics.
  -- @class function
  -- @name pathfinder:getHeuristics
  -- @treturn {string,...} array of heuristic names.  
  function Pathfinder:getHeuristics()
    return collect_keys(Heuristic)
  end  

  --- Changes the search mode. Defines a new search mode for the `pathfinder` object.
  -- The default search mode is `DIAGONAL`, which implies 8-possible directions when moving (north, south, east, west and diagonals).
  -- In `ORTHOGONAL` mode, only 4-directions are allowed (north, south, east and west).
  -- Use @{pathfinder:getModes} to get the list of all available search modes.
  -- @class function
  -- @name pathfinder:setMode
  -- @tparam string mode the new search mode. 
  -- @see pathfinder:getModes
  function Pathfinder:setMode(mode)
    assert(searchModes[mode],'Invalid mode')
    self.allowDiagonal = (mode == 'DIAGONAL')
    return self
  end

  --- Gets the search mode.
  -- @class function
  -- @name pathfinder:getMode
  -- @treturn string the current search mode
  function Pathfinder:getMode()
    return (self.allowDiagonal and 'DIAGONAL' or 'ORTHOGONAL')
  end
  
  --- Gets the list of all available search modes.
  -- @class function
  -- @name pathfinder:getModes
  -- @treturn {string,...} array of search modes.   
  function Pathfinder:getModes()
    return collect_keys(searchModes)
  end

  --- Returns the `grid` object. Returns a reference to the internal `grid` object used by the `pathfinder` object
  -- @class function
  -- @name pathfinder:getGrid
  -- @treturn grid the `grid` object  
  function Pathfinder:getGrid()
    return self.grid
  end

  --- Returns version and release date.
  -- @class function
  -- @name pathfinder:version
  -- @treturn string the version of the current implementation 
  -- @treturn string the release of the current implementation   
  function Pathfinder:version()
    return _VERSION, _RELEASEDATE
  end

  --- Calculates a path. Returns the path from location `<startX, startY>` to location `<endX, endY>`.
  -- Both locations must exist on the collision map.
  -- @class function
  -- @name pathfinder:getPath
  -- @tparam number startX the x-coordinate for the starting location
  -- @tparam number startY the y-coordinate for the starting location
  -- @tparam number endX the x-coordinate for the goal location
  -- @tparam number endY the y-coordinate for the goal location
  -- @treturn {node,...} a path (array of `nodes`) when found, otherwise `nil`
  -- @treturn number the path length when found, `0` otherwise
  function Pathfinder:getPath(startX, startY, endX, endY)
    local startNode = self.grid:getNodeAt(startX, startY)
    local endNode = self.grid:getNodeAt(endX, endY)
    assert(startNode, ('Invalid location [%d, %d]'):format(startX, startY))
    assert(endNode and self.grid:isWalkableAt(endX, endY),
      ('Invalid or unreachable location [%d, %d]'):format(endX, endY))
    local _endNode = Finders[self.finder](self, startNode, endNode, toClear)
    if _endNode then return 
      traceBackPath(self, _endNode, startNode), lastPathCost 
    end
    lastPathCost = 0
    return nil, lastPathCost
  end

  --- Path filling function. It interpolates between non contiguous locations along a path
  -- to build a fully continuous path. It maybe useful when using `Jump Point Search` finder.
  -- It does the opposite of @{pathfinder:filter}
  -- @class function
  -- @name pathfinder:fill
  -- @tparam {node,...} path the path found with @{pathfinder:getPath}
  -- @treturn {node,...} the passed-in path, interpolated
  -- @see pathfinder:filter  
  function Pathfinder:fill(path)
    local i = 2
    local xi,yi,dx,dy
    local N = #path
    local incrX, incrY
    while true do
      xi,yi = path[i].x,path[i].y
      dx,dy = xi-path[i-1].x,yi-path[i-1].y
      if (abs(dx) > 1 or abs(dy) > 1) then
        incrX = dx/max(abs(dx),1)
        incrY = dy/max(abs(dy),1)
        t_insert(path, i, self.grid:getNodeAt(path[i-1].x + incrX, path[i-1].y +incrY))
        N = N+1
      else i=i+1
      end
      if i>N then break end
    end
    return path
  end
  
  --- Path compression. Given a path, it eliminates useless nodes to return a path consisting of
  -- straight directions. It does the opposite of @{pathfinder:fill} 
  -- @class function
  -- @name pathfinder:filter
  -- @tparam {node,...} path the path found with @{pathfinder:getPath}
  -- @treturn {node,...} the passed-in path, filtered 
  -- @see pathfinder:fill
  function Pathfinder:filter(path)
    local i = 2
    local xi,yi,dx,dy, olddx, olddy
    xi,yi = path[i].x, path[i].y
    dx, dy = xi - path[i-1].x, yi-path[i-1].y
    while true do
      olddx, olddy = dx, dy
      if path[i+1] then
        i = i+1
        xi, yi = path[i].x, path[i].y
        dx, dy = xi - path[i-1].x, yi - path[i-1].y
        if olddx == dx and olddy == dy then
          t_remove(path, i-1)
          i = i - 1
        end
      else break end
    end
    return path
  end

  -- Returns Pathfinder class
  return setmetatable(Pathfinder,{
    __call = function(self,...)
      return self:new(...)
    end
  })

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
