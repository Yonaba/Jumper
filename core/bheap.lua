-- Copyright (c) 2012 Roland Yonaba

--[[
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

--[[
  Notes:
  Lighter implementation of binary heaps, based on :
    https://github.com/Yonaba/Binary-Heaps
--]]

local floor = math.floor


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

-- Heap template
local heap = setmetatable({},
  {__call = function(self,...)
    return newHeap(self,...)
  end})
heap.__index = heap

-- Checks if a heap is empty
function heap:empty()
  return (self.size==0)
end

-- Clears the heap
function heap:clear()
  self.__heap = {}
  self.size = 0
  self.sort = self.sort or f_min
  return self
end

-- Pushes a new value into the heap
function heap:push(value)
  self.size = self.size + 1
  self.__heap[self.size] = value
  percolate_up(self, self.size)
  return self
end

-- Pops the root value
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

-- Restores the heap property
function heap:heapify()
  for i = floor(self.size/2),1,-1 do
    percolate_down(self,i)
  end
  return self
end

return heap
