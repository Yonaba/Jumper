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
			assert_equal(node.x, 1)
			assert_equal(node.y, 3)
		end)
		
		test('Nodes can be compared, if they both have an F-cost', function()
		  local nodeA, nodeB = Node(1,2), Node(1,2)
			nodeA.f, nodeB.f = 1, 2
			assert_less_than(nodeA, nodeB)
			
			nodeA.f = 3
			assert_less_than(nodeB, nodeA)
		end)	
		
  end)

end)