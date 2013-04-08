--[[
void floodFillScanlineStack(int x, int y, int newColor, int oldColor)
{
    if(oldColor == newColor) return;
    emptyStack();
    
    int y1; 
    bool spanLeft, spanRight;
    
    if(!push(x, y)) return;
    
    while(pop(x, y))
    {    
        y1 = y;
        while(y1 >= 0 && screenBuffer[x][y1] == oldColor) y1--;
        y1++;
        spanLeft = spanRight = 0;
        while(y1 < h && screenBuffer[x][y1] == oldColor )
        {
            screenBuffer[x][y1] = newColor;
            if(!spanLeft && x > 0 && screenBuffer[x - 1][y1] == oldColor) 
            {
                if(!push(x - 1, y1)) return;
                spanLeft = 1;
            }
            else if(spanLeft && x > 0 && screenBuffer[x - 1][y1] != oldColor)
            {
                spanLeft = 0;
            }
            if(!spanRight && x < w - 1 && screenBuffer[x + 1][y1] == oldColor) 
            {
                if(!push(x + 1, y1)) return;
                spanRight = 1;
            }
            else if(spanRight && x < w - 1 && screenBuffer[x + 1][y1] != oldColor)
            {
                spanRight = 0;
            } 
            y1++;
        }
    }
}
--]]

local t_remove = table.remove()
local function wasVisited(x,y, finder)
	local node = finder._grid:getNodeAt(x,y, finder._walkable)
	if node then
		return node._floodfill[finder._walkable]
	end
	return nil
end

local function setStamp(x, y, finder, stamp)
	local node = finder._grid:getNodeAt(x, y, finder._walkable)
	if node then
		node._floodfill[finder._walkable] = stamp
		return node
	end
end
local function floodfill(finder, seed)
	local grid = finder._grid
	local x, y = seed._x, seed._y
	local spanLeft, spanRight
	local stack = {}
	local n_items = 0
	local stamp = 1
	
	while (n_items>0) do
		local node = stack[n_items]
		t_remove(stack)
		n_items = n_items - 1
		
		local y1 = y
		while (y1>= grid._min_y and not wasVisited(x, y1, finder) do
			y1 = y1 - 1
		end
		y1 = y1 + 1
		spanLeft, spanRight = false, false
		while y1 < grid._max_y and not wasVisited(x, y1, finder) do
			local node = setStamp(x, y1, finder, stamp)
			if node then
				stack[n_items+1] =  node
				spanLeft = true
			else return
			end
			
		end
	
	end

end