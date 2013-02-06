
local W = love.graphics.getWidth()
local H = love.graphics.getHeight()

local Grid = require 'grid'
local demoGrid

function love.load()
	love._openConsole()
	demoGrid = Grid:new(H, 10, false)

end


function love.draw()
	demoGrid:draw(H)
	demoGrid:drawMouseCoord(true)
end
