local W = love.graphics.getWidth()
local H = love.graphics.getHeight()
local Grid = require('grid')
local Ui = require('ui')

local demoGrid
local BGridType = Ui.addButton(650, 35, 100, 15,{0,255,0,255},'PREPROCESSED')
local BGridSizeRed = Ui.addButton(682.5, 85, 15, 15,{0,255,0,255},'-')
local BGridSizeInc = Ui.addButton(702.5, 85, 15, 15,{0,255,0,255},'+')
local BASTAR = Ui.addButton(625, 140, 70, 15, {0,255,0,255}, 'ASTAR')
local BDIJKSTRA = Ui.addButton(705, 140, 70, 15, {0,255,0,255}, 'DIJKSTRA')
local BDFS = Ui.addButton(625, 165, 70, 15, {0,255,0,255}, 'DFS')
local BBFS = Ui.addButton(705, 165, 70, 15, {0,255,0,255}, 'BFS')
local BTASTAR = Ui.addButton(625, 190, 70, 15, {0,255,0,255}, 'TASTAR')
local BJPS = Ui.addButton(705, 190, 70, 15, {0,255,0,255}, 'JPS')

function love.load()
	love._openConsole()
	demoGrid = Grid:new(H, 10, false)
end


function love.draw()
	demoGrid:draw(H)
	demoGrid:drawMouseCoord(true)
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(('Grid type: %s'):format(''), 600, 15, 200, 'center')	
	love.graphics.printf(('Grid size: %dx%d'):format(demoGrid.n_tiles, demoGrid.n_tiles),
		600, 65, 200, 'center')
	love.graphics.printf(('Search Algorithm: %s'):format(''), 600, 115, 200, 'center')
	love.graphics.printf(('Heuristic: %s'):format(''), 600, 220, 200, 'center')
	Ui.draw()
end
