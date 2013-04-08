--- Example of use for Heuristics

local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")

local map = {
  {0,0,0,0,0,0},
  {0,0,0,0,0,0},
  {0,1,1,1,1,0},
  {0,0,0,0,0,0},
  {0,0,0,0,0,0},
}

local walkable = 0
local grid = Grid(map)
local myFinder = Pathfinder(grid, 'ASTAR', walkable)

-- Use Euclidian heuristic to evaluate distance
myFinder:setHeuristic('EUCLIDIAN')
myFinder:setHeuristic('DIAGONAL')
myFinder:setHeuristic('MANHATTAN')

-- Custom
local h = function(nodeA, nodeB)
	return (0.1 * (math.abs(nodeA:getX() - nodeB:getX()))
	      + 0.9 * (math.abs(nodeA:getY() - nodeB:getY())))
end
myFinder:setHeuristic(h)

local p = myFinder:getPath(1,1, 6,5)
for node, count in p:nodes() do
  print(('%d. Node(%d,%d)'):format(count, node:getX(), node:getY()))
end
print(('Path length: %.2f'):format(p:getLength()))

-- etc ...
