--- <strong>The <code>node</code> class</strong>.
-- The `node` class represents a cell on a collision map. Basically, for each single cell
-- in the collision map passed-in upon initialization, a `node` object would be generated
-- and then stored within the `grid` object.
--
-- In the following implementation, nodes can be compared using the `<` operator. The comparison is
-- made on the basis of their `f` cost. From a processed node, the `pathfinder` would expand the search 
-- to the next neighbouring node having the lowest `f` cost. This comparison is internally used within the
-- *open list* `heap` to quickly sort all nodes queued inside the heap.
-- 
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module jumper.core.node

if (...) then

	local assert = assert
	
  --- Internal `node` Class
  -- @class table
  -- @name node
  -- @field x the x-coordinate of the node on the collision map
  -- @field y the y-coordinate of the node on the collision map
  local Node = {}
  Node.__index = Node

  --- Inits a new `node` object
  -- @class function
  -- @name node:new
  -- @tparam int x the x-coordinate of the node on the collision map
  -- @tparam int y the y-coordinate of the node on the collision map
  -- @treturn node a new `node` object
  function Node:new(x,y)
    return setmetatable({x = x, y = y}, Node)
  end

  -- Enables the use of operator '<' to compare nodes.
  -- Will be used to sort a collection of nodes in a binary heap on the basis of their F-cost
  function Node.__lt(A,B) return (A.f < B.f) end

  return setmetatable(Node,
		{__call = function(self,...) 
			return Node:new(...) 
		end}
	)
end


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
