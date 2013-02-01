context('Module Heuristics', function()
	local H
	
	before(function()
		H = require ('jumper.core.heuristics')
  end)
	
  context('MANHATTAN distance', function()
	
    test('is a function',function()
			assert_type(H.MANHATTAN, 'function')
    end)
	
		test('evaluates as |dx|+|dy|', function()
			assert_equal(H.MANHATTAN(0,0), 0)
			assert_equal(H.MANHATTAN(1,1), 2)
			assert_equal(H.MANHATTAN(-1,-2), 3)
			assert_equal(H.MANHATTAN(10,-2), 12)
			assert_equal(H.MANHATTAN(-5,8), 13)		
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.MANHATTAN,1))	
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
			assert_equal(H.EUCLIDIAN(0,0), 0)
			assert_equal(H.EUCLIDIAN(2,2), math.sqrt(8))
			assert_equal(H.EUCLIDIAN(-1,-2), math.sqrt(5))
			assert_equal(H.EUCLIDIAN(-3,1), math.sqrt(10))
			assert_equal(H.EUCLIDIAN(-5,3), math.sqrt(34))		
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.EUCLIDIAN,1))	
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
			assert_equal(H.DIAGONAL(0,0), 0)
			assert_equal(H.DIAGONAL(2,2), 2)
			assert_equal(H.DIAGONAL(-1,-2), 2)
			assert_equal(H.DIAGONAL(-3,1), 3)
			assert_equal(H.DIAGONAL(-5,3), 5)		
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.DIAGONAL,1))	
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
			assert_equal(H.CARDINTCARD(0,0), 0)
			assert_less_than(H.CARDINTCARD(1,1)-(math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(-1,-2)-(1+math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(-3,1)-(2+math.sqrt(2)),1e-6)
			assert_less_than(H.CARDINTCARD(2,2)-(2*math.sqrt(2)),1e-6)
		end)
		
		test('calling the function with one arg raises an error', function()
			assert_error(pcall(H.CARDINTCARD,1))	
		end)	
		
		test('calling the function with no args raises an error', function()
			assert_error(pcall(H.CARDINTCARD))
		end)		
		
  end)
	
end)