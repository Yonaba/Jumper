--- Heuristic functions for search algorithms.
-- A <a href="http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html">distance heuristic</a> 
-- provides an *estimate of the optimal distance cost* from a given location to a target. 
-- As such, it guides the pathfinder to the goal, helping it to decide which route is the best.
--
-- This script holds the definition of some built-in heuristics available through jumper.
--
-- Distance functions are internally used by the `pathfinder` to evaluate the optimal path
-- from the start location to the goal. These functions share the same prototype:
-- <ul>
-- <pre class="example">
-- local function myHeuristic(dx, dy)
--   -- function body
-- end
-- </pre></ul>
-- Jumper features some built-in distance heuristics, namely `MANHATTAN`, `EUCLIDIAN`, `DIAGONAL`, `CARDINTCARD`.
-- You can also supply your own heuristic function, following the same template as above.
-- @module heuristics

local abs = math.abs
local sqrt = math.sqrt
local sqrt2 = sqrt(2)
local max, min = math.max, math.min

local Heuristics = {}
  --- Manhattan distance.
  -- <br/>This heuristic is the default one being used by the `pathfinder` object.
  -- <br/>Evaluates as <code>distance = |dx|+|dy|</code>
  -- @class function
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location __[startX, startY]__ to location __[endX, endY]__
	-- @usage
  -- -- First method
  -- pathfinder:setHeuristic('MANHATTAN')
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.MANHATTAN)
  function Heuristics.MANHATTAN(dx,dy) return abs(dx)+abs(dy) end
  
  --- Euclidian distance.
  -- <br/>Evaluates as <code>distance = squareRoot(dx*dx+dy*dy)</code>
  -- @class function
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location __[startX, startY]__ to location __[endX, endY]__
	-- @usage
  -- -- First method
  -- pathfinder:setHeuristic('EUCLIDIAN')
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.EUCLIDIAN) 
  function Heuristics.EUCLIDIAN(dx,dy) return sqrt(dx*dx+dy*dy) end
  
  --- Diagonal distance.
  -- <br/>Evaluates as <code>distance = max(|dx|, abs|dy|)</code>
  -- @class function
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location __[startX, startY]__ to location __[endX, endY]__
	-- @usage
  -- -- First method
  -- pathfinder:setHeuristic('DIAGONAL')
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.DIAGONAL)
  function Heuristics.DIAGONAL(dx,dy) return max(abs(dx),abs(dy)) end
  
  --- Cardinal/Intercardinal distance.
  -- <br/>Evaluates as <code>distance = min(dx, dy)*squareRoot(2) + max(dx, dy) - min(dx, dy)</code>
  -- @class function
  -- @tparam int dx the difference endX-startX
  -- @tparam int dy the difference endY-startY
  -- @treturn number the distance from location __[startX, startY]__ to location __[endX, endY]__
	-- @usage
  -- -- First method
  -- pathfinder:setHeuristic('CARDINTCARD')
  -- -- Second method
  -- local Distance = require ('jumper.core.heuristics')
  -- pathfinder:setHeuristic(Distance.CARDINTCARD)
  function Heuristics.CARDINTCARD(dx,dy) 
    dx, dy = abs(dx), abs(dy)
    return min(dx,dy) * sqrt2 + max(dx,dy) - min(dx,dy)
  end

return Heuristics