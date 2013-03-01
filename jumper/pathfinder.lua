--- <strong>The <strong>pathfinder</strong> class API</strong>.
--
-- Implementation of the `pathfinder` class.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module jumper.pathfinder

local _VERSION = "1.8.1"
local _RELEASEDATE = "03/01/2013"

--- @usage
local usage = [[
-- Usage Example
-- First, set a collision map
local map = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
local Grid = require ("jumper.grid") -- The grid class
local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass

-- Creates a grid object
local grid = Grid(map)
-- Creates a pathfinder object using Jump Point Search
local myFinder = Pathfinder(grid, 'JPS', walkable)

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path, length = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(length))
	for node, count in path:iter() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node.x, node.y))
	end
end

--> Output:
--> Path found! Length: 8.83
--> Step: 1 - x: 1 - y: 1
--> Step: 2 - x: 1 - y: 3
--> Step: 3 - x: 2 - y: 4
--> Step: 4 - x: 4 - y: 4
--> Step: 5 - x: 5 - y: 3
--> Step: 6 - x: 5 - y: 1
]]

if (...) then

  -- Internalization
  local t_insert, t_remove = table.insert, table.remove
	local floor = math.floor
  local pairs = pairs
  local assert = assert
  local setmetatable, getmetatable = setmetatable, getmetatable
	
	-- Type function ovverride, to support integers
	local otype = type
	local isInt = function(v) 
		return otype(v) == 'number' and floor(v) == v and 'int' or nil 
	end
	local type = function(v)
		return isInt(v) or otype(v)
	end
	
  -- Dependancies
  local _PATH = (...):gsub('%.pathfinder$','')
  local Heap      = require (_PATH .. '.core.bheap')
  local Heuristic = require (_PATH .. '.core.heuristics')
  local Grid      = require (_PATH .. '.grid')
  local Path      = require (_PATH .. '.core.path')

  -- Is arg a grid object
  local function isAGrid(grid)
    return getmetatable(grid) and getmetatable(getmetatable(grid)) == Grid
  end

  -- Available search algorithms
  local Finders = {
    ['ASTAR']     = require (_PATH .. '.search.astar'),	
    ['DIJKSTRA']  = require (_PATH .. '.search.dijkstra'),
    ['BFS']       = require (_PATH .. '.search.bfs'),
    ['DFS']       = require (_PATH .. '.search.dfs'),
    ['JPS']       = require (_PATH .. '.search.jps'),
  }

  -- Collect keys in an array
  local function collect_keys(t)
    local keys = {}
    for k,v in pairs(t) do keys[#keys+1] = k end
    return keys
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

  -- Availables search modes
  local searchModes = {['DIAGONAL'] = true, ['ORTHOGONAL'] = true}

  -- Performs a traceback from the goal node to the start node
  -- Only happens when the path was found
  local function traceBackPath(finder, node, startNode)
    local path = Path:new()
    path.grid = finder.grid
    lastPathCost = node.f or path:getLength()

    while true do
      if node.parent then
        t_insert(path,1,node)
        node = node.parent
      else
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
  -- @tparam grid grid a `grid` object
  -- @tparam[opt] string finderName the name of the `finder` (search algorithm) to be used for further searches.
	-- Defaults to `ASTAR` when not given. Use @{pathfinder:getFinders} to get the full list of available finders..
  -- @tparam[optchain] string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean:
  -- `true` when value matches a *walkable* node, `false` otherwise.
  -- @treturn pathfinder a new `pathfinder` object
  function Pathfinder:new(grid, finderName, walkable)
    local newPathfinder = {}
    setmetatable(newPathfinder, Pathfinder)
	  newPathfinder:setGrid(grid)
    newPathfinder:setFinder(finderName)
    newPathfinder:setWalkable(walkable)
    newPathfinder:setMode('DIAGONAL')
    newPathfinder:setHeuristic('MANHATTAN')
    newPathfinder.openList = Heap()
    return newPathfinder
  end

  --- Sets a `grid` object. Defines the `grid` on which the `pathfinder` will make path searches.
  -- @class function
  -- @name pathfinder:setGrid
  -- @tparam grid grid a `grid` object
  function Pathfinder:setGrid(grid)
    assert(isAGrid(grid), 'Bad argument #1. Expected a \'grid\' object')
    self.grid = grid
    self.grid.__eval = self.walkable and type(self.walkable) == 'function'
    return self
  end

  --- Returns the `grid` object. Returns a reference to the internal `grid` object used by the `pathfinder` object.
  -- @class function
  -- @name pathfinder:getGrid
  -- @treturn grid the `grid` object
  function Pathfinder:getGrid()
    return self.grid
  end

  --- Sets the `walkable` value or function.
  -- @class function
  -- @name pathfinder:setWalkable
  -- @tparam string|int|function walkable the value for walkable nodes on the passed-in map array.
  -- If this parameter is a function, it should be prototyped as `f(value)`, returning a boolean:
  -- `true` when value matches a *walkable* node, `false` otherwise.
  function Pathfinder:setWalkable(walkable)
    assert(('stringintfunctionnil'):match(type(walkable)),
      ('Bad argument #2. Expected \'string\', \'number\' or \'function\', got %s.'):format(type(walkable)))
    self.walkable = walkable
    self.grid.__eval = type(self.walkable) == 'function'
    return self
  end

  --- Gets the `walkable` value or function.
  -- @class function
  -- @name pathfinder:getWalkable
  -- @treturn string|int|function the `walkable` previously set
  function Pathfinder:getWalkable()
    return self.walkable
  end

  --- Sets a finder. The finder refers to the search algorithm used by the `pathfinder` object.
  -- The default finder is `ASTAR`. Use @{pathfinder:getFinders} to get the list of available finders.
  -- @class function
  -- @name pathfinder:setFinder
  -- @tparam string finderName the name of the finder to be used for further searches.
  -- @see pathfinder:getFinders
  function Pathfinder:setFinder(finderName)
		local finderName = finderName
		if not finderName then
			if not self.finder then 
				finderName = 'ASTAR' 
			else return 
			end
		end
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
  -- @tparam[opt] bool tunnel Whether or not the pathfinder can tunnel though walls diagonally (not compatible with `Jump Point Search`)
  -- @treturn {node,...} a path (array of `nodes`) when found, otherwise `nil`
  -- @treturn number the path length when found, `0` otherwise
  function Pathfinder:getPath(startX, startY, endX, endY, tunnel)
		reset()
    local startNode = self.grid:getNodeAt(startX, startY)
    local endNode = self.grid:getNodeAt(endX, endY)
    assert(startNode, ('Invalid location [%d, %d]'):format(startX, startY))
    assert(endNode and self.grid:isWalkableAt(endX, endY),
      ('Invalid or unreachable location [%d, %d]'):format(endX, endY))
    local _endNode = Finders[self.finder](self, startNode, endNode, toClear, tunnel)
    if _endNode then 
			return traceBackPath(self, _endNode, startNode), lastPathCost
    end
    lastPathCost = 0
    return nil, lastPathCost
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
