local W = love.graphics.getWidth()
local H = love.graphics.getHeight()
local Grid = require('grid')
local Ui = require('ui')

local demoGrid
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

local font10 = love.graphics.newFont('res/dungeon.ttf', 10)
local font8 = love.graphics.newFont('res/dungeon.ttf', 8)

function love.load()
	love._openConsole()
	demoGrid = Grid:new(H, 10, false)
end


function love.draw()

	love.graphics.setColor(255, 255, 255, 255)
	demoGrid:draw(H)
	love.graphics.setFont(font10)
	demoGrid:drawMouseCoord(true)
	love.graphics.printf(('Grid type: %s'):format(''), 600, 15, 200, 'center')	
	love.graphics.printf(('Grid size: %dx%d'):format(demoGrid.n_tiles, demoGrid.n_tiles),
		600, 65, 200, 'center')
	love.graphics.printf(('Search Algorithm: %s'):format(''), 600, 115, 200, 'center')
	love.graphics.printf(('Heuristic: %s'):format(''), 600, 220, 200, 'center')
	
	love.graphics.setFont(font8)
	Ui.draw()
end
