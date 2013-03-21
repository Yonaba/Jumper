--- The Node class.
-- The `node` represents a cell (or a tile) on a collision map. Basically, for each single cell (tile)
-- in the collision map passed-in upon initialization, a `node` object will be generated
-- and then cached within the `grid`.
--
-- In the following implementation, nodes can be compared using the `<` operator. The comparison is
-- made with regards of their `f` cost. From a given node being examined, the `pathfinder` will expand the search 
-- to the next neighbouring node having the lowest `f` cost. See `core.bheap` for more details.
-- 

if (...) then

	local assert = assert
	
	--- The `Node` class.<br/>
	-- This class is callable.
	-- Therefore,_ <code>Node(...)</code> _acts as a shortcut to_ <code>Node:new(...)</code>.
	-- @type Node
  local Node = {}
  Node.__index = Node

  --- Inits a new `node`
  -- @class function
  -- @tparam int x the x-coordinate of the node on the collision map
  -- @tparam int y the y-coordinate of the node on the collision map
  -- @treturn node a new `node`
	-- @usage local node = Node(3,4)
  function Node:new(x,y)
    return setmetatable({_x = x, _y = y, _clearance = {}}, Node)
  end

  -- Enables the use of operator '<' to compare nodes.
  -- Will be used to sort a collection of nodes in a binary heap on the basis of their F-cost
  function Node.__lt(A,B) return (A._f < B._f) end

  --- Returns x-coordinate of a `node`
  -- @class function
  -- @treturn number the x-coordinate of the `node`
	-- @usage local x = node:getX()	
	function Node:getX() return self._x end
	
  --- Returns y-coordinate of a `node`
  -- @class function
  -- @treturn number the y-coordinate of the `node`	
	-- @usage local y = node:getY()		
	function Node:getY() return self._y end
	
  --- Returns x and y coordinates of a `node`
  -- @class function
  -- @treturn number the x-coordinate of the `node`
  -- @treturn number the y-coordinate of the `node`
	-- @usage local x, y = node:getPos()		
	function Node:getPos() return self._x, self._y end
	
  --- Returns the amount of [clearance](http://aigamedev.com/open/tutorial/clearance-based-pathfinding/#TheTrueClearanceMetric) 
	-- for a given `node`
  -- @class function
  -- @tparam string|int|func walkable the value for walkable locations in the collision map array.
  -- @treturn int the clearance of the `node`
	-- @usage
	--  -- Assuming walkable was 0	
	-- local clearance = node:getClearance(0)		
	function Node:getClearance(walkable)
		return self._clearance[walkable]
	end
	
  return setmetatable(Node,
		{__call = function(self,...) 
			return Node:new(...) 
		end}
	)
end