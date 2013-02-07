
local Grid = require('jumper.grid')

local grid = {}
grid.__index = grid
grid. min_tiles = 10
grid.max_tiles = 60
grid.n_tiles = grid.min_tiles

function grid:new(env_size, n_tiles, pod)
	local n = setmetatable({}, grid)
	n:set(env_size, n_tiles)
	n:make(pod)
	return n
end

function grid:set(env_size, n)
	self.n_tiles = math.max(self.min_tiles, 
		math.min((n or self.n_tiles), self.max_tiles))
	self.tile_size = env_size/self.n_tiles
end

function grid:make(pod)
	self.cmap = {}
	for i = 1, self.n_tiles do
		self.cmap[i] = {}
		for j = 1, self.n_tiles do
			self.cmap[i][j] = 0
		end
	end
	self.grid = Grid:new(self.cmap, pod)	
end

function grid:getMouseCoordOnHover()
	local mx, my = love.mouse.getPosition()
	local _x = math.floor(mx/self.tile_size)+1
	local _y = math.floor(my/self.tile_size)+1
	if self.cmap[_y] and self.cmap[_y][_x]  then
		return _x, _y
	end
	return nil
end

function grid:drawMouseCoord(draw)
	local x, y = self:getMouseCoordOnHover()
	if draw and x and y then
		love.graphics.setColor(255, 255,0, 255)
		local mx, my = love.mouse.getPosition()
		local flip = (my + 5 > love.graphics.getHeight()-15) and -15 or 0
		love.graphics.print(('[%d,%d]'):format(x, y),mx + 5, my + flip + 10)
	end
end

function grid:draw(len)
	for i = 0, self.n_tiles do
		love.graphics.line(i*self.tile_size, 0, i*self.tile_size, len)	
		love.graphics.line(0, i*self.tile_size, len, i*self.tile_size)	
	end
end


return grid