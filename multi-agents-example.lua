-- Example of use for multi-agents pathfinding
-- Uses a modified version of Jumper

-- Setting a map
local map = {
	{0,0,0,0,0,0,0},
	{0,0,0,1,0,0,0},
	{0,0,0,0,0,0,0},
	{0,0,0,1,0,0,0},
	{0,0,0,1,0,0,0},
	{0,0,0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
local Grid = require ("jumper.grid") -- The grid class
local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass

-- Creates a grid object
local grid = Grid(map)
-- Creates a pathfinder object using ASTAR (DIJKSTRA can be used, too)
local myFinder = Pathfinder(grid, 'ASTAR', walkable)

-- Implements onPathFound callback, 
-- so that it will be called right after a path has been found
-- This implementation actually increases the cost of each node lying along the path found, so that the next path request
-- will try to avoid these nodes and look for alternative possible routes to the same goal.
function myFinder.onPathFound(path)
	for node in path:nodes() do
		node.weight = node.weight + 1
	end
end

-- Define a commonn start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 7,6

-- Pathfinding for 10 agents
local agents = {}
for i = 1,10 do
	-- inits the 10 agents
	agents[i] = {path = false}
	agents[i].path = myFinder:getPath(startx, starty, endx, endy) -- Path request
	
	-- If a path was found, pretty-print it:
	if agents[i].path then
		local path = agents[i].path
		print(('Agent %d : Found!'):format(i))
		for node, count in path:nodes() do
			print(('\tStep: %d - x: %d - y: %d'):format(count, node.x, node.y))
		end
	end
end
-- Do not forget to reset each nodes weight to zero, 
-- for the next group path request.
grid:each(function(node) node.weight = 0 end)