local W = love.graphics.getWidth()
local H = love.graphics.getHeight()
local Grid = require('grid')
local Ui = require('ui')
local PF = require ('jumper.pathfinder')
local font10 = love.graphics.newFont('res/dungeon.ttf', 10)
local font8 = love.graphics.newFont('res/dungeon.ttf', 8)

local demoGrid
local finder
local log = ''

local BGTYPE = Ui.addButton(650, 35, 100, 15,{153,51,0,255},'PREPROCESSED')
local BGRED = Ui.addButton(682.5, 85, 15, 15,{153,51,0,255},'-')
local BGINC = Ui.addButton(702.5, 85, 15, 15,{153,51,0,255},'+')
local BASTAR = Ui.addButton(625, 140, 70, 15, {153,51,0,255}, 'ASTAR')
local BDIJKSTRA = Ui.addButton(705, 140, 70, 15, {153,51,0,255}, 'DIJKSTRA')
local BDFS = Ui.addButton(625, 165, 70, 15, {153,51,0,255}, 'DFS')
local BBFS = Ui.addButton(705, 165, 70, 15, {153,51,0,255}, 'BFS')
local BTASTAR = Ui.addButton(625, 190, 70, 15, {153,51,0,255}, 'TASTAR')
local BJPS = Ui.addButton(705, 190, 70, 15, {153,51,0,255}, 'JPS')
local BMANHATTAN = Ui.addButton(625, 245, 70, 15, {153,51,0,255}, 'MANHATTAN')
local BEUCLIDIAN = Ui.addButton(705, 245, 70, 15, {153,51,0,255}, 'EUCLIDIAN')
local BDIAGONAL = Ui.addButton(625, 275, 70, 15, {153,51,0,255}, 'DIAGONAL')
local BCARDINTCARD = Ui.addButton(705, 275, 70, 15, {153,51,0,255}, 'CARDINTCARD')
local BMODE = Ui.addButton(650, 335, 100, 15,{153,51,0,255},'DIAGONAL')
local BOBST = Ui.addButton(645, 375, 50, 15, {0,0,255,255},nil,'set\nunwalkable')
local BCLEAROBST = Ui.addButton(705, 375, 50, 15, {255,255,255,255},nil,'set\nwalkable')
local BSTART = Ui.addButton(645, 400, 50, 15, {0, 255, 0, 255},nil,'set\nstart')
local BGOAL = Ui.addButton(705, 400, 50, 15, {255,0,0,255},nil,'set\ngoal')
local BGETPATH = Ui.addButton(630, 470, 70, 15, {255,0,0,255},'CALCULATE')
local BFILLPATH = Ui.addButton(630, 495,70, 15, {255,0,0,255},'FILL PATH')
local BFILTERPATH = Ui.addButton(630, 520, 70, 15, {255,0,0,255},'FILTER PATH')

function love.load()
	love._openConsole()
	demoGrid = Grid:new(H)
	finder = PF(demoGrid.grid)
	
	BGTYPE:setCallback(function(button)
		button.label = ((button.label == 'PREPROCESSED') and 'PROCESSONDEMAND' or 'PREPROCESSED')
		demoGrid:set(H, demoGrid.n_tiles)
		local timeGenGrid, memUsed = demoGrid:make(button.label == 'PROCESSONDEMAND')
		log = ('Grid generated in: %d ms\nMemory count: %d kiB'):format(timeGenGrid, memUsed)
		finder:setGrid(demoGrid.grid)
	end)
	
end


function love.draw()

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(font10)
	love.graphics.printf(('Grid type: %s'):format(''), 600, 15, 200, 'center')	
	love.graphics.printf(('Grid size: %dx%d'):format(demoGrid.n_tiles, demoGrid.n_tiles),
		600, 65, 200, 'center')
	love.graphics.printf(('Search Algorithm: %s'):format(''), 600, 115, 200, 'center')
	love.graphics.printf(('Heuristic: %s'):format(''), 600, 220, 200, 'center')
	love.graphics.printf(('Mode: %s'):format(''), 600, 310, 200, 'center')
	love.graphics.printf(('Path calculation'):format(''), 600, 440, 200, 'center')
	love.graphics.printf((': %d ms'):format(0), 710, 470, 100, 'left')
	love.graphics.printf((': %d ms'):format(0), 710, 495, 100, 'left')
	love.graphics.printf((': %d ms'):format(0), 710, 520, 100, 'left')
	love.graphics.printf(('Path length: %.2f'):format(0), 600, 550, 200, 'center')
	love.graphics.setColor(245, 245, 10, 255)
	love.graphics.printf(log, 600, 570, 200, 'center')
	
	love.graphics.setColor(255, 255, 255, 255)	
	demoGrid:draw(H)	
	demoGrid:drawMouseCoord(true)
	
	love.graphics.setFont(font8)
	Ui.draw()
end
