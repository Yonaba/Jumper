local W = love.graphics.getWidth()
local H = love.graphics.getHeight()
local Grid = require('grid')
local Ui = require('ui')
local PF = require ('jumper.pathfinder')
local measure = require ('utils').measure
local font10 = love.graphics.newFont('res/dungeon.ttf', 10)
local font8 = love.graphics.newFont('res/dungeon.ttf', 8)

local demoGrid
local finder
local log = ''
local selFinder, selHeuristic
local MOUSEMODE = ''
local SNODE, ENODE
local TIMEFILLPATH, TIMEFILTERPATH, TIMEPATH = 0, 0, 0

local BDEFCOLOR = {153,51,0,255}
local BLUE = {0,0,255,255}
local WHITE = {255,255,255,255}
local GREEN = {0, 255, 0, 255}
local RED = {255,0,0,255}
local SELCOLOR = {100, 100, 100, 255}
local LOGCOLOR = {245, 245, 10, 255}


local BGTYPE = Ui.addButton(650, 35, 100, 15,BDEFCOLOR,'PREPROCESSED')
local BGRED = Ui.addButton(672.5, 85, 25, 15,BDEFCOLOR,'-')
local BGINC = Ui.addButton(712.5, 85, 25, 15,BDEFCOLOR,'+')
local BASTAR = Ui.addButton(625, 140, 70, 15, BDEFCOLOR, 'ASTAR')
local BDIJKSTRA = Ui.addButton(705, 140, 70, 15, BDEFCOLOR, 'DIJKSTRA')
local BDFS = Ui.addButton(625, 165, 70, 15, BDEFCOLOR, 'DFS')
local BBFS = Ui.addButton(705, 165, 70, 15, BDEFCOLOR, 'BFS')
local BTASTAR = Ui.addButton(625, 190, 70, 15, BDEFCOLOR, 'THETASTAR')
local BJPS = Ui.addButton(705, 190, 70, 15, BDEFCOLOR, 'JPS')
local BMANHATTAN = Ui.addButton(625, 245, 70, 15, BDEFCOLOR, 'MANHATTAN')
local BEUCLIDIAN = Ui.addButton(705, 245, 70, 15, BDEFCOLOR, 'EUCLIDIAN')
local BDIAGONAL = Ui.addButton(625, 275, 70, 15, BDEFCOLOR, 'DIAGONAL')
local BCARDINTCARD = Ui.addButton(705, 275, 70, 15, BDEFCOLOR, 'CARDINTCARD')
local BMODE = Ui.addButton(650, 335, 100, 15,BDEFCOLOR,'DIAGONAL')
local BOBST = Ui.addButton(645, 375, 50, 15, BLUE)
local BCLEAROBST = Ui.addButton(705, 375, 50, 15, WHITE)
local BSTART = Ui.addButton(645, 400, 50, 15, GREEN)
local BGOAL = Ui.addButton(705, 400, 50, 15, RED)
local BGETPATH = Ui.addButton(630, 470, 70, 15, RED,'CALCULATE')
local BFILLPATH = Ui.addButton(630, 495,70, 15, RED,'FILL PATH')
local BFILTERPATH = Ui.addButton(630, 520, 70, 15, RED,'FILTER PATH')

function love.load()
	love._openConsole()
	demoGrid = Grid:new(H)
	finder = PF(demoGrid.grid, 'ASTAR', 0)
	
	BGTYPE:setCallback(function(button)
		button.label = ((button.label == 'PREPROCESSED') and 'PROCESSONDEMAND' or 'PREPROCESSED')
		demoGrid:set(H, demoGrid.n_tiles)
		local timeGenGrid, memUsed = demoGrid:make(button.label == 'PROCESSONDEMAND')
		log = ('Grid generated in: %d ms\nMemory count: %d kiB'):format(timeGenGrid, memUsed)
		finder:setGrid(demoGrid.grid)
	end)
	
	local f = function(button, step)
		local n_tiles
		if step < 0 then 
			n_tiles = math.max(Grid.min_tiles, demoGrid.n_tiles+step)
		else
			n_tiles = math.min(Grid.max_tiles, demoGrid.n_tiles+step)		
		end
		if n_tiles == demoGrid.n_tiles then return end
		demoGrid:set(H, n_tiles)
		local timeGenGrid, memUsed = demoGrid:make(BGTYPE.label == 'PROCESSONDEMAND')
		log = ('Grid generated in: %d ms\nMemory count: %d kiB'):format(timeGenGrid, memUsed)
		finder:setGrid(demoGrid.grid)
	end
	
	BGRED:setCallback(f,-5)
	BGINC:setCallback(f,5)
	
	local f = function(button)
		if button == BDFS or button == BBFS then
			BMANHATTAN:hide()
			BDIAGONAL:hide()
			BEUCLIDIAN:hide()
			BCARDINTCARD:hide()
		else
			BMANHATTAN:show()
			BDIAGONAL:show()
			BEUCLIDIAN:show()
			BCARDINTCARD:show()		
		end
		if selFinder ~= button then
			selFinder.backColor = BDEFCOLOR
		end
		button.backColor = SELCOLOR
		selFinder = button
		finder:setFinder(button.label)
		log = ('Finder chosen: %s'):format(finder:getFinder())
	end
	
	BASTAR:setCallback(f)
	BDIJKSTRA:setCallback(f)
	BBFS:setCallback(f)
	BDFS:setCallback(f)
	BTASTAR:setCallback(f)
	BJPS:setCallback(f)	
	
	local f = function(button)
		if selHeuristic ~= button then
			selHeuristic.backColor = BDEFCOLOR
		end
		button.backColor = SELCOLOR
		selHeuristic = button
		finder:setHeuristic(button.label)
		log = ('Heuristic chosen: %s'):format(button.label)
	end	
	
	BMANHATTAN:setCallback(f)
	BDIAGONAL:setCallback(f)
	BEUCLIDIAN:setCallback(f)
	BCARDINTCARD:setCallback(f)
	
	BMODE:setCallback(function(button)
		button.label = ((button.label == 'DIAGONAL') and 'ORTHOGONAL' or 'DIAGONAL')
		finder:setMode(button.label)
		log = ('Mode chosen: %s'):format(button.label)		
	end)
	
	selFinder = BASTAR
	BASTAR.backColor = SELCOLOR
	selHeuristic = BMANHATTAN
	BMANHATTAN.backColor = SELCOLOR
	
	local function set(button, flag) MOUSEMODE = flag end
	BOBST:setCallback(set, 'OBST')
	BCLEAROBST:setCallback(set, 'CLR')
	BSTART:setCallback(set, 'START')
	BGOAL:setCallback(set, 'GOAL')
	
	local function path(button)
		local timePath = demoGrid:getPath(finder)
		if demoGrid.path then
			TIMEPATH = timePath or 0
		end
	end
	BGETPATH:setCallback(path)
	
	local function flpath(button)
		if demoGrid.path then
			local n_nodes = #demoGrid.path
			
			local timeFlpath = measure(function(p)
				p:fill()
			end, demoGrid.path)
			
			TIMEFILLPATH = timeFlpath or 0
			log = ('Path interpolated. %d nodes added!'):format(#demoGrid.path - n_nodes)
		end
	end
	BFILLPATH:setCallback(flpath)
	
	local function ftpath(button)
		if demoGrid.path then	
			local n_nodes = #demoGrid.path

			local timeFtpath = measure(function(p)
				p:filter()
			end, demoGrid.path)
			
			TIMEFILTERPATH = timeFtpath or 0
			log = ('Path filtered. %d nodes removed!'):format(n_nodes - #demoGrid.path)
		end
	end
	BFILTERPATH:setCallback(ftpath)
	
end

local function setObst()
	if love.mouse.isDown('l') then
		local x, y = demoGrid:getMouseCoordOnHover()
		if x and y and demoGrid.cmap[y] and demoGrid.cmap[y][x] then
			demoGrid.cmap[y][x] = (MOUSEMODE == 'OBST' and 1 or (MOUSEMODE == 'CLR' and 0 or demoGrid.cmap[y][x]))
		end	
	end
end

function love.update(dt)
	setObst()
end

function love.draw()

	love.graphics.setColor(WHITE)
	love.graphics.setFont(font10)
	love.graphics.printf(('Grid type: %s'):format(''), 600, 15, 200, 'center')	
	love.graphics.printf(('Grid size: %dx%d'):format(demoGrid.n_tiles, demoGrid.n_tiles),
		600, 65, 200, 'center')
	love.graphics.printf(('Search Algorithm: %s'):format(''), 600, 115, 200, 'center')
	love.graphics.printf(('Heuristic: %s'):format(''), 600, 220, 200, 'center')
	love.graphics.printf(('Mode: %s'):format(''), 600, 310, 200, 'center')
	love.graphics.printf(('Path calculation'):format(''), 600, 440, 200, 'center')
	love.graphics.printf((': %d ms'):format(TIMEPATH), 710, 470, 100, 'left')
	love.graphics.printf((': %d ms'):format(TIMEFILLPATH), 710, 495, 100, 'left')
	love.graphics.printf((': %d ms'):format(TIMEFILTERPATH), 710, 520, 100, 'left')
	love.graphics.printf(('Path length: %.2f'):format(demoGrid.path and demoGrid.path:getLength() or 0), 600, 550, 200, 'center')
	love.graphics.setColor(LOGCOLOR)
	love.graphics.printf(log, 600, 570, 200, 'center')
	
	demoGrid:draw(H, BLUE, WHITE, GREEN, RED)	
	demoGrid:drawMouseCoord(true)
	
	love.graphics.setFont(font8)
	Ui.draw()
end

function love.mousepressed(x, y, button)
	local x, y = demoGrid:getMouseCoordOnHover(x, y)
	if x and y then
		if MOUSEMODE == 'START' then 
			demoGrid.snode = {x = x, y = y}
		elseif MOUSEMODE == 'GOAL' then
			if demoGrid.cmap[y][x]~=1 then
				demoGrid.enode = {x = x, y = y}
			end
		end
	end
end
