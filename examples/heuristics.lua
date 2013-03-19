--- Example of use for Heuristics

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