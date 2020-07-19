context('Module Path', function()
	local Path, Node
	
	before(function()
		Path = require ('jumper.core.path')
		Node = require ('jumper.core.node')
  end)
	
  context('The Path Class', function()
	
    test('Path:new() or Path() returns a Path object',function()
			assert_equal(getmetatable(Path:new()),Path)
			assert_equal(getmetatable(Path()),Path)
    end)
		
    test('Path:iter() iterates on nodes forming the path',function()
			local p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,i) end
			
			local i = 0
			for node, count in p:iter() do
				i = i+1
				assert_equal(getmetatable(node), Node)
				assert_equal(node._x, i)
				assert_equal(node._y, i)
				assert_equal(count, i)
			end
    end)		
		
		test('Path:iter() is aliased as Path:nodes()',function()
			assert_equal(Path.iter, Path.nodes)
		end)
		
		test('Path:getLength() returns the length of the path', function()
			local p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,0) end
			assert_equal(p:getLength(),9)
			
			p = Path()
			for j = 1,10 do p._nodes[#p._nodes+1] = Node(0,j) end
			assert_equal(p:getLength(),9)

			p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,i) end
			assert_less_than(p:getLength()-9*math.sqrt(2),1e-6)			
			
			--Test with diagonal distance
			local Heuristics = require ('jumper.core.heuristics')
			p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,i) end
			assert_equal(p:getLength(Heuristics.DIAGONAL), 9)
		end)
		
		test('Path:fill() interpolates a path', function()
			local p = Path()
			for i = 1,9,2 do p._nodes[#p._nodes+1] = Node(i,i) end
			p._grid = {getNodeAt = function(self,x,y) return {_x = x, _y = y} end}
			p:fill()
			
			local i = 0
			for node, count in p:iter() do
				i = i+1
				assert_equal(node._x, i)
				assert_equal(node._y, i)
				assert_equal(count, i)
			end			
			
		end)
		
		test('Interpolation does not affect the total path length', function()
			local p = Path()
			for i = 1,10,3 do p._nodes[#p._nodes+1] = Node(i,i) end
			local len = p:getLength()
			p._grid = {getNodeAt = function(self,x,y) return {_x = x, _y = y} end}			
			p:fill()
			
			assert_less_than(p:getLength()-len,1e-6)			
		end)		

		test('Path:filter() compresses a path', function()
			local p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,i) end
			p:filter()
			
			assert_equal(p._nodes[1]._x,1)
			assert_equal(p._nodes[1]._y,1)
			assert_equal(p._nodes[2]._x,10)
			assert_equal(p._nodes[2]._y,10)
			for i = 3,10 do
				assert_nil(p._nodes[i])
			end
			
		end)

		test('Compression does not affect the total path length', function()
			local p = Path()
			for i = 1,10 do p._nodes[#p._nodes+1] = Node(i,i) end
			local len = p:getLength()
			p:fill()
			
			assert_less_than(p:getLength()-len,1e-6)			
		end)		
		
  end)

end)