--[[
Copyright (c) 2012 Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local tinsert = table.insert
local ipairs = ipairs


----------------------------------------------------------------------------------------------------------------------
-- Private Helper for mouse hovering detection
local function mouseIsOn(object)
	local x,y = love.mouse.getPosition()
	if (x > object.x and x < object.x+object.w) and (y > object.y and y < object.y+object.h) then return true end
	return false
end
----------------------------------------------------------------------------------------------------------------------

-- Local register
local buttons = {}

-- Button Template
local Button = {
	x = nil, y = nil,
	w = 100,h = 50,
	label = '',
	callback = nil,
	backColor = {0,0,175},
	borderColor = {255,255,0},
  _hide = false,
}

Button.__index = Button

-- Custom Initializer
function Button:new(x,y,w,h,color,label)
	local newButton = {}
	newButton.x,newButton.y = x,y
	newButton.w,newButton.h = w,h
	newButton.label = label
  newButton.backColor = color
  newButton._hide = false
	tinsert(buttons,newButton)
  return setmetatable(newButton, Button)
end

-- Hides a button
function Button:hide() self._hide = true end

-- Unhides a Button
function Button:show() self._hide = false end

-- Attachs a callback function to a button
function Button:setCallback(f)
	self.f = f
end

-- Sets a label for a button
function Button:setLabel(str) self.label = str end

-- Sets the back color
function Button:setBackColor(color) self.backColor = color end

-- Runs the attached callback
function Button:callback()
	if self.f then self.f() end
end

-- Draws a rect border when hovering the button
function Button:drawBorder()
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line",self.x-1,self.y-1,self.w+2,self.h+2)
end

-- Tests if mouse is houvering the button
function Button:mouseIsOn() return mouseIsOn(self) end

-- Draws the button
function Button:draw()	
  if not self._hide then
		local font = love.graphics.getFont()	
    love.graphics.setColor(self.backColor)
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(self.label,self.x,self.y+(self.h/2)-(font:getHeight()/2),self.w,"center")
    
    if self:mouseIsOn() then 
    self:drawBorder() 
      if love.mouse.isDown("l") and not(self.setPause) then
        self:callback()
        self.setPause = true
      elseif not love.mouse.isDown("l") then
        self.setPause = false
      end
    end
  end
end

-- Returns wrapped Gui functions
return {
	addButton = function(...) return Button:new(...) end,
	draw = function() 
		for i,element in ipairs(buttons) do 
			element:draw() 
		end 
	end
}
