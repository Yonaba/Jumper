
local Grid = require('jumper.grid')
local measure = require ('utils').measure

local grid = {}
grid.__index = grid
grid. min_tiles = 10
grid.max_tiles = 60
grid.n_tiles = grid.min_tiles
grid.snode = false
grid.enode = false
grid.path = false

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
	return measure(function(g)
		g.grid = Grid:new(g.cmap, pod)
	end, self)
end

function grid:getMouseCoordOnHover(x, y)
	local mx, my = x, y
	if not mx or not my then 
		mx, my = love.mouse.getPosition() 
	end
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

function grid:getPath(finder)
	if self.enode and self.snode then
		return measure(function(g, finder)
		print('Request', g.snode.x, g.snode.y, g.enode.x, g.enode.y)
		print('finder.grid', finder.grid==g.grid, finder.grid.map == g.cmap)
			local path = finder:getPath(g.snode.x, g.snode.y, g.enode.x, g.enode.y)
			print('Request', path)
			g.path = path or false
		end, self, finder)
	end
end

function grid:draw(len, blockColor, defColor, sNodeColor, eNodeColor)
	love.graphics.setColor(defColor)
	for i = 0, self.n_tiles do
		love.graphics.line(i*self.tile_size, 0, i*self.tile_size, len)	
		love.graphics.line(0, i*self.tile_size, len, i*self.tile_size)	
	end
	for y = 1,self.grid.height do
		for x = 1,self.grid.width do
			if self.cmap[y][x] == 1 then
				love.graphics.setColor(blockColor)
				love.graphics.rectangle('fill', (x-1)*self.tile_size+1, (y-1)*self.tile_size+1, self.tile_size-2, self.tile_size-2)
			end
			if self.enode and x == self.enode.x and y == self.enode.y then
				love.graphics.setColor(eNodeColor)
				love.graphics.rectangle('fill', (x-1)*self.tile_size+1, (y-1)*self.tile_size+1, self.tile_size-2, self.tile_size-2)			
			elseif self.snode and x == self.snode.x and y == self.snode.y then
				love.graphics.setColor(sNodeColor)
				love.graphics.rectangle('fill', (x-1)*self.tile_size+1, (y-1)*self.tile_size+1, self.tile_size-2, self.tile_size-2)			
			end			
		end
	end
	if self.path then
		for node, count in (self.path:iter()) do
			love.graphics.setColor(230, 230, 30, 255)
			love.graphics.setPoint(5, 'smooth')
			love.graphics.point(node.x * self.tile_size - self.tile_size/2, node.y * self.tile_size - self.tile_size/2)
			if count > 1 then
				love.graphics.setColor(200, 60, 250, 255)
				love.graphics.line(node.x * self.tile_size - self.tile_size/2, node.y * self.tile_size - self.tile_size/2,
					self.path[count-1].x * self.tile_size - self.tile_size/2, self.path[count-1].y * self.tile_size - self.tile_size/2)
			end
		end
	end
end



return grid