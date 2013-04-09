-- Tests sample for clearance metrics calculation
-- See Figure 10 at http://aigamedev.com/open/tutorial/clearance-based-pathfinding/
local Grid = require 'jumper.grid'
local PF = require 'jumper.pathfinder'
local map = {
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,1,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,1,0,0,0,0,0,0},
	{0,0,1,0,0,0,0,0,2,0},
	{0,0,1,1,1,0,0,2,0,0},
	{0,0,0,1,1,0,2,0,0,2},
	{0,0,0,0,1,0,0,0,0,2},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0}
}
local grid = Grid(map)
local walkable = function(v) return v~=2 end
local finder = PF(grid, 'ASTAR',walkable)
finder:annotateGrid()

for y = 1, #map do
	local s = ''
	for x = 1, #map[y] do
	  local node = grid:getNodeAt(x,y)
		s = (s .. ' ' .. node:getClearance(walkable))
	end
	print(s)
end

-- Expected output
--  6 6 5 5 4 4 4 3 2 1
--  6 5 5 4 4 3 3 3 2 1
--  6 5 4 4 3 3 2 2 2 1
--  6 5 4 3 3 2 2 1 1 1
--  6 5 4 3 2 2 1 1 0 1
--  5 5 4 3 2 1 1 0 1 1
--  4 4 4 3 2 1 0 2 1 0
--  3 3 3 3 3 3 3 2 1 0
--  2 2 2 2 2 2 2 2 2 1
--  1 1 1 1 1 1 1 1 1 1

