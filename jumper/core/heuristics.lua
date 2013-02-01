--- <strong>Heuristics for the search algorithm</strong>.
-- A <a href="http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html">heuristic</a> 
-- provides an *estimate of the optimal cost* from a given location to a target. 
-- As such, it guides the pathfinder to the goal, helping it to decide which route is the best.
--
-- This script holds the definition of built-in heuristics available.
--
-- Distance functions are internally used by the `pathfinder` to evaluate the optimal path
-- from the start location to the goal. These functions share the same prototype:
-- <ul>
-- <pre class="example">
-- local function myHeuristic(dx, dy)
--   -- function body
-- end
-- </pre></ul>
-- Jumper features some built-in distance heuristics, named `MANHATTAN`, `EUCLIDIAN`, `DIAGONAL`, `CARDINTCARD`.
-- You can also supply your own heuristic function, using the template given above.
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license MIT
-- @module jumper.core.heuristics

--- @usage
local usage = [[
  -- Example
  local Distance = require ('jumper.core.heuristics')
  local Grid = require ("jumper.grid")
  local Pathfinder = require ("jumper.pathfinder")
  local walkable = 0
  -- Placeholder: local map = {...}
  local grid = Grid(map)
  local myFinder = Pathfinder('ASTAR', grid, walkable)
  
  -- Use Euclidian heuristic to evaluate distance
  myFinder:setHeuristic('EUCLIDIAN') 
  -- etc ... 
]]

local abs = math.abs
local sqrt = math.sqrt
local sqrt2 = sqrt(2)
local max, min = math.max, math.min

local Heuristics = {}
  --- Manhattan distance.
  -- <br/>This heuristic is the default one being used by the `pathfinder` object.
  -- <br/>Evaluates as `distance = |dx|+|dy|`
  -- @class function
  -- @name Heuristics.MANHATTAN
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location `startX, startY` to location `endX, endY`
  -- <ul>
  -- <pre class="example">
  -- -- First method
  -- pathfinder:setHeuristic('MANHATTAN')<br/>
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.MANHATTAN)
  -- </pre></ul>
  function Heuristics.MANHATTAN(dx,dy) return abs(dx)+abs(dy) end
  
  --- Euclidian distance.
  -- <br/>Evaluates as `distance = squareRoot(dx*dx+dy*dy)`
  -- @class function
  -- @name Heuristics.EUCLIDIAN
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location `startX, startY` to location `endX, endY`
  -- <ul>
  -- <pre class="example">
  -- -- First method
  -- pathfinder:setHeuristic('EUCLIDIAN')<br/>
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.EUCLIDIAN)
  -- </pre></ul>  
  function Heuristics.EUCLIDIAN(dx,dy) return sqrt(dx*dx+dy*dy) end
  
  --- Diagonal distance.
  -- <br/>Evaluates as `distance = max(|dx|, abs|dy|)`
  -- @class function
  -- @name Heuristics.DIAGONAL
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location `startX, startY` to location `endX, endY`
  -- <ul>
  -- <pre class="example">
  -- -- First method
  -- pathfinder:setHeuristic('DIAGONAL')<br/>
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.DIAGONAL)
  -- </pre></ul>   
  function Heuristics.DIAGONAL(dx,dy) return max(abs(dx),abs(dy)) end
  
  --- Cardinal/Intercardinal distance.
  -- <br/>Evaluates as `distance = min(dx, dy)*squareRoot(2) + max(dx, dy) - min(dx, dy)`
  -- @class function
  -- @name Heuristics.CARDINTCARD
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location `startX, startY` to location `endX, endY`
  -- <ul>
  -- <pre class="example">
  -- -- First method
  -- pathfinder:setHeuristic('CARDINTCARD')<br/>
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.CARDINTCARD)
  -- </pre></ul>  
  function Heuristics.CARDINTCARD(dx,dy) 
    dx, dy = abs(dx), abs(dy)
    return min(dx,dy) * sqrt2 + max(dx,dy) - min(dx,dy)
  end

return Heuristics

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