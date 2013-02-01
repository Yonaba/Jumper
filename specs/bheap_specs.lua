context('Module BHeap', function()	
	local BHeap 
	
	before(function()
		BHeap = require ('jumper.core.bheap')
	end)
	
	context('BHeap class', function()
	
		test('BHeap() instantiates a new heap object', function()
			assert_equal(getmetatable(BHeap()), BHeap)
		end)
		
		test('the new heap is empty', function()
			assert_true((BHeap()):empty())
		end)
		
		test('items can be pushed inside', function()
			local h = BHeap()
			h:push(1):push(2):push(3)
			assert_equal(h.size, 3)
		end)
		
		test('popping returns the lowest element by default (< operator)', function()
			local h = BHeap()
			h:push(1):push(2):push(0)
			
			assert_equal(h:pop(),0)
			assert_equal(h:pop(),1)
			assert_equal(h:pop(),2)
			assert_nil(h:pop())
		end)
		
		test('a heap can be cleared', function()
			local h = BHeap()
			assert_true(h:empty())
			
			h:push(1):push(2):push(3)
			assert_false(h:empty())
			
			h:clear()
			assert_true(h:empty())			
		end)
		
		test('one can define a custom sort function', function()
			local sort = function(a,b) return a>b end
			local h = BHeap(sort)
			h:push(1):push(2):push(3)
			
			assert_equal(h:pop(),3)
			assert_equal(h:pop(),2)
			assert_equal(h:pop(),1)
			assert_nil(h:pop())
		end)		

		test('items pushed can be objects, with a custom sort function', function()
			local sortNode = function(a, b) return a.cost < b.cost end
			local makeObj = function(cost) return {cost = cost} end
			local h = BHeap(sortNode)
			h:push(makeObj(1)):push(makeObj(2)):push(makeObj(3))
			
			assert_equal(h:pop().cost,1)
			assert_equal(h:pop().cost,2)
			assert_equal(h:pop().cost,3)
			assert_nil(h:pop())					
		end)
		
		test('pushing a alue that cannot be compared to the previous ones raises an error', function()
			local h = BHeap()
			h:push(false)
			assert_error(pcall(h.push, h, false))
			assert_error(pcall(h.push, h, true))		
			assert_error(pcall(h.push, h, {}))		
			assert_error(pcall(h.push, h, function() end))		
		end)
		
		test('pushing nil does nothing', function()
			local h = BHeap()
			h:push()
			
			assert_true(h:empty())
			h:push(1):push()
			
			assert_false(h:empty())
			assert_equal(h.size,1)
		end)
		
		test('popping an empty heap returns nil', function()
			local h = BHeap()
			assert_nil(h:pop())		
		end)
		
		test('BHeap:heapify() forces a sort of the heap', function()
		
			local h = BHeap()
			local sort = function(a,b) return a.value < b.value end
			local function makeObj(v) return {value = v} end
			local h = BHeap(sort)
			local A, B, C = makeObj(1), makeObj(2), makeObj(3)
			
			h:push(A):push(B):push(C)
			C.value = 0
			h:heapify(C)
			
			local ret = h:pop()
			assert_true(ret == C)
			assert_equal(ret.value,0)
			
			local ret = h:pop()
			assert_true(ret == A)
			assert_equal(ret.value,1)

			local ret = h:pop()
			assert_true(ret == B)
			assert_equal(ret.value,2)
			
			h:push(A):push(B):push(C)
			C.value, B.value, A.value = 3, 2, 100
			h:heapify()

			local ret = h:pop()
			assert_true(ret == B)
			assert_equal(ret.value,2)
			
			local ret = h:pop()
			assert_true(ret == C)
			assert_equal(ret.value,3)

			local ret = h:pop()
			assert_true(ret == A)
			assert_equal(ret.value,100)
		
		end)
		
		
	end)
	
end)