--- Very minimal usage example for Jumper

-- Set up a collision map
local map = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
-- Calls the grid class
local Grid = require ("jumper.grid")
-- Calls the pathfinder class
local Pathfinder = require ("jumper.pathfinder")

-- Creates a grid object
local grid = Grid(map)

-- Creates a pathfinder object using Jump Point Search algorithm
local myFinder = Pathfinder(grid, 'JPS', walkable)

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path = myFinder:getPath(startx, starty, endx, endy)

-- Pretty-printing the results
if path then
  print(('Path found! Length: %.2f'):format(path:getLength()))
	for node, count in path:nodes() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
	end
end
