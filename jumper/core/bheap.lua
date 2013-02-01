--- <strong>A light implementation of `binary heaps`</strong>.
-- While running a search, some algorithms have to maintains a list of nodes called __open list__.
-- Finding in this list the lowest cost node from the node being processed can be quite slow, 
-- (as it requires to skim through the collection of nodes stored in this list) 
-- especially when dozens of nodes are being processed (large maps). 
--
-- The current module implements a <a href="http://www.policyalmanac.org/games/binaryHeaps.htm">binary heap</a> data structure,
-- from which the internal open list will be instantiated. As such, looking up for lower-cost 
-- node will run faster, and globally makes the search algorithm run faster.
--
-- This module should normally not be used explicitely. The algorithm uses it internally.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module jumper.core.bheap

--[[
  Notes:
  Lighter implementation of binary heaps, based on :
    https://github.com/Yonaba/Binary-Heaps
--]]

local floor = math.floor

-- Lookup for value in a table
local indexOf = function(t,v)
  for i = 1,#t do
    if t[i] == v then return i end
  end
  return nil
end

-- Default comparison function
local function f_min(a,b) 
  return a < b 
end

-- Percolates up
local function percolate_up(heap, index)
  if index == 1 then return end
  local pIndex
  if index <= 1 then return end
  if index%2 == 0 then
    pIndex =  index/2
  else pIndex = (index-1)/2
  end
  if not heap.sort(heap.__heap[pIndex], heap.__heap[index]) then
    heap.__heap[pIndex], heap.__heap[index] = 
      heap.__heap[index], heap.__heap[pIndex]
    percolate_up(heap, pIndex)
  end
end

-- Percolates down
local function percolate_down(heap,index)
  local lfIndex,rtIndex,minIndex
  lfIndex = 2*index
  rtIndex = lfIndex + 1
  if rtIndex > heap.size then
    if lfIndex > heap.size then return
    else minIndex = lfIndex  end
  else
    if heap.sort(heap.__heap[lfIndex],heap.__heap[rtIndex]) then
      minIndex = lfIndex
    else
      minIndex = rtIndex
    end
  end
  if not heap.sort(heap.__heap[index],heap.__heap[minIndex]) then
    heap.__heap[index],heap.__heap[minIndex] = heap.__heap[minIndex],heap.__heap[index]
    percolate_down(heap,minIndex)
  end
end

-- Produces a new heap
local function newHeap(template,comp)
  return setmetatable({__heap = {},
    sort = comp or f_min, size = 0},
  template)
end

--- The `heap` class
-- @class table
-- @name heap
local heap = setmetatable({},
  {__call = function(self,...)
    return newHeap(self,...)
  end})
heap.__index = heap

--- Checks if a `heap` is empty
-- @class function
-- @name heap:empty
-- @treturn bool `true` of no item is queued in the heap, `false` otherwise
function heap:empty()
  return (self.size==0)
end

--- Clears the `heap` (removes all items queued in the heap)
-- @class function
-- @name heap:clear
function heap:clear()
  self.__heap = {}
  self.size = 0
  self.sort = self.sort or f_min
  return self
end

--- Adds a new item in the `heap`
-- @class function
-- @name heap:push
-- @tparam object item a new object to be queued in the heap
function heap:push(item)
	if item then
		self.size = self.size + 1
		self.__heap[self.size] = item
		percolate_up(self, self.size)
	end
  return self
end

--- Pops from the `heap`.
-- Removes and returns the lowest cost item (with respect to the comparison function used) from the `heap`.
-- @class function
-- @name heap:pop
-- @treturn object an object stored in the heap
function heap:pop()
  local root
  if self.size > 0 then
    root = self.__heap[1]
    self.__heap[1] = self.__heap[self.size]
    self.__heap[self.size] = nil
    self.size = self.size-1
    if self.size>1 then
      percolate_down(self, 1)
    end
  end
  return root
end

--- Restores the `heap` property.
-- Reorders the `heap` with respect to the comparison function being used. 
-- When given arg `item`, will sort that very item in the `heap`. 
-- Otherwise, the whole `heap` will be sorted. 
-- @class function
-- @name heap:heapify
-- @tparam[opt] object item the modified object 
function heap:heapify(item)
  if item then
    local i = indexOf(self.__heap,item)
    if i then 
      percolate_down(self, i)
      percolate_up(self, i)
    end
    return
  end
  for i = floor(self.size/2),1,-1 do
    percolate_down(self,i)
  end
  return self
end

return heap

--[[
Copyright (c) 2012-2013 Roland Yonaba
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