context('Module Node', function()
	local Node
	
	before(function()
		Node = require ('jumper.core.node')
  end)
	
  context('The Node Class', function()
	
    test('Node:new() or Node() returns a Node object',function()
			assert_equal(getmetatable(Node:new(0,0)),Node)
			assert_equal(getmetatable(Node(0,0)),Node)
    end)
	
		test('A Node has x and y attributes', function()
			local node = Node:new(1,3)
			assert_equal(node._x, 1)
			assert_equal(node._y, 3)
		end)
		
		test('x and y attributes can be retrieved through methods', function()
			local node = Node:new(5,6)
			assert_equal(node:getX(), 5)
			assert_equal(node:getY(), 6)
			
			local x, y = node:getPos()
			assert_equal(x, 5)
			assert_equal(y, 6)
		end)		
		
		test('Nodes can be compared, if they both have an F-cost', function()
		  local nodeA, nodeB = Node(1,2), Node(1,2)
			nodeA._f, nodeB._f = 1, 2
			assert_less_than(nodeA, nodeB)
			
			nodeA._f = 3
			assert_less_than(nodeB, nodeA)
		end)	
		
  end)

end)