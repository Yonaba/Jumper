context('Module Heuristics', function()
	local H, Node
	
	before(function()
		H = require ('jumper.core.heuristics')
		Node = require ('jumper.core.node')
  end)
	
  context('MANHATTAN distance', function()
	
    test('is a function',function()
			assert_type(H.MANHATTAN, 'function')
    end)
	
		test('evaluates as |dx|+|dy|', function()
			assert_equal(H.MANHATTAN(Node(0,0), Node(0,0)), 0)
			assert_equal(H.MANHATTAN(Node(1,1), Node(1,3)), 2)
			assert_equal(H.MANHATTAN(Node(0,0), Node(2,1)), 3)
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.MANHATTAN,Node(0,0)))	
		end)	
		
		test('calling the function with no args raises an error', function()
			assert_error(pcall(H.MANHATTAN))
		end)		
		
  end)

  context('EUCLIDIAN distance', function()
	
    test('is a function',function()
			assert_type(H.EUCLIDIAN, 'function')
    end)
	
		test('evaluates as SQUAREROOT(dx*dx + dy*dy)', function()
			assert_equal(H.EUCLIDIAN(Node(0,0), Node(0,0)), 0)
			assert_equal(H.EUCLIDIAN(Node(0,0), Node(2,2)), math.sqrt(8))
			assert_equal(H.EUCLIDIAN(Node(0,0), Node(5,3)), math.sqrt(34))		
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.EUCLIDIAN,Node(0,0)))	
		end)	
		
		test('calling the function with no args raises an error', function()
			assert_error(pcall(H.EUCLIDIAN))
		end)		
		
  end)
  
	context('DIAGONAL distance', function()
	
    test('is a function',function()
			assert_type(H.DIAGONAL, 'function')
    end)
	
		test('evaluates as MAX(|dx|+|dy|)', function()
			assert_equal(H.DIAGONAL(Node(0,0), Node(0,0)), 0)
			assert_equal(H.DIAGONAL(Node(0,0), Node(2,2)), 2)
			assert_equal(H.DIAGONAL(Node(0,0), Node(1,2)), 2)
			assert_equal(H.DIAGONAL(Node(0,0), Node(3,1)), 3)	
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.DIAGONAL,Node(0,0)))	
		end)	
		
		test('calling the function with no args raises an error', function()
			assert_error(pcall(H.DIAGONAL))
		end)		
		
  end)

	context('CARDINTCARD distance', function()
	
    test('is a function',function()
			assert_type(H.CARDINTCARD, 'function')
    end)
		
		test('evaluates as (SQRT(2)-1)*MIN(|dx|+|dy|)+MAX(|dx|+|dy|)', function()
			assert_equal(H.CARDINTCARD(Node(0,0), Node(0,0)), 0)
			assert_less_than(H.CARDINTCARD(Node(0,0), Node(1,1))-(math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(Node(0,0), Node(1,2))-(1+math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(Node(0,0), Node(-3,1))-(2+math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(Node(0,0), Node(2,2))-(2*math.sqrt(2)),1e-6)
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.CARDINTCARD,Node(0,0)))	
		end)	
		
		test('calling the function with no args raises an error', function()
			assert_error(pcall(H.CARDINTCARD))
		end)		
		
  end)
	
end)