context('Module Grid', function()
	local Grid, Node
	
	before(function()
		Grid = require ('jumper.grid')
		Node = require ('jumper.core.node')
  end)
	
  context('Grid:new() or Grid() returns a new Grid object', function()
		
		test('Grid:new() or Grid() returns a new Grid object', function()
			assert_equal(getmetatable(getmetatable(Grid:new({{0}}))),Grid)
			assert_equal(getmetatable(getmetatable(Grid({{0}}))),Grid)
		end)
			
		test('Grid:new() requires a collision map upon initialization', function()
			local map = {{0,0},{0,0}}
			assert_not_nil(Grid:new(map))
		end)
			
		test('The passed-in map can be a string', function()
			local map = '00\n00'
			assert_not_nil(Grid:new(map))
		end)
			
		test('passing nil to Grid:new() or Grid() causes an error', function()
			assert_error(pcall(Grid, Grid))
			assert_error(pcall(Grid.new, Grid))
		end)			
			
		test('Grid and map should have the same width', function()
			local map = '00\n00'
			local map = {{0,0},{0,0}}
			local grid = Grid(map)
			local grid2 = Grid(map)
			assert_equal(grid.width, 2)
			assert_equal(grid2.width, 2)	
		end)	
		
		test('Grid and map should have the same height', function()
			local map = '00\n00\n00'
			local map2 = {{0,0},{0,0},{0,0},{0,0}}
			local grid = Grid(map)
			local grid2 = Grid(map2)
			assert_equal(grid.height, 3)
			assert_equal(grid2.height, 4)	
		end)
		
		test('Each value on the map matches a node on the grid', function()
			local map = {{0,0},{0,0},{0,0},{0,0}}
			local grid = Grid(map)
			
			for y in pairs(map) do
				for x in pairs(map[y]) do
					local node = grid:getNodeAt(x,y)
					assert_not_nil(node)
					assert_equal(getmetatable(node), Node)
				end
			end
		end)
		
		test('the passed-in map should have a width greather than 0',function()
			assert_error(pcall(Grid, Grid, {{},{}}))
			assert_error(pcall(Grid, Grid, '\n\n'))
		end)

		test('the passed-in map should have a height greather than 0',function()
			assert_error(pcall(Grid, Grid, {}))
			assert_error(pcall(Grid, Grid, ''))
		end)
		
		test('the passed-in map should have rows with the same width',function()
			assert_error(pcall(Grid, Grid, {{0},{0,0}}))
			assert_error(pcall(Grid, Grid, '00\n000'))
		end)

		test('values in the map should only be integers or strings',function()
			assert_error(pcall(Grid, Grid, {{0.1,0,0},{0,0,0}}))
			assert_error(pcall(Grid, Grid, {{0,function() end,0},{0,0,0}}))
		end)
		
	end)
	
	context('Grid types', function()
		
		test('passing a 2nd arg to Grid:new() or Grid() returns a postprocessed grid', function()
			local grid = Grid({{0}})
			local pgrid = Grid({{0}},true)
			assert_not_equal(getmetatable(grid), getmetatable(pgrid))
			assert_equal(getmetatable(getmetatable(grid)), getmetatable(getmetatable(pgrid)))
		end)
		
		test('postprocessed grids are memory safe, as nodes are cached on purpose', function()
			local map = {{0,0,0},{0,0,0},{0,0,0}}
			local pgrid = Grid(map, true)
			
			assert_equal(#pgrid:getNodes(), 0)
			local count = 0
			for node in pgrid:iter() do
				assert_equal(getmetatable(node), Node)
				count = count+1
			end
			assert_equal(count, pgrid.width*pgrid.height)
		end)
		
	end)
	
	context('Grid:isWalkablkeAt', function()
		
			test('returns whether or not a node is walkable',function()
				local map = {{0,0},{0,0},{0,1},{0,0}}
				local grid = Grid(map)			
				local walkable = 1
				
				for y in pairs(map) do
					for x in pairs(map[y]) do
						if map[y][x] == walkable then
							assert_true(grid:isWalkableAt(x,y,walkable))
						else
							assert_false(grid:isWalkableAt(x,y,walkable))
						end
					end
				end
				
				map = 'WXW\nWWW\n'
				grid = Grid(map)			
				walkable = 'W'
				
				for y = 1,2 do
					for x = 1,3 do
						if x==2 and y==1 then
							assert_false(grid:isWalkableAt(x,y,walkable))
						else
							assert_true(grid:isWalkableAt(x,y,walkable))
						end
					end
				end
				
			end)

			test('All nodes are walkable when no walkability rule was set', function()
				local map = {{0,0},{0,0}}
				local grid = Grid(map)
				
				for y in pairs(map) do
					for x in pairs(map[y]) do
						assert_true(grid:isWalkableAt(x,y,walkable))
					end
				end
			end)
		
	end)
		
	context('Grid:getMap()', function()
		
			test('returns the collision map',function()
				local map = {{0,0},{0,0}}
				local grid = Grid(map)
				assert_equal(grid:getMap(), map)
			end)
		
			test('returns the array parsed from a given that string',function()
				local map = '00\n00'
				local grid = Grid(map)
				assert_equal(type(grid:getMap()), 'table')
				assert_not_equal(grid:getMap(), map)
			end)
		
	end)
	
	context('Grid:getNodeAt()', function()
			local map, grid
			before(function()
				map = {
					{0,0,0,0},
					{0,0,0,0},
				}
				grid = Grid(map)
      end)
			
			test('returns the node at a given position', function()
				local node = grid:getNodeAt(1,1)
				assert_equal(getmetatable(node),Node)
				assert_equal(node.x,1)
				assert_equal(node.y,1)
			end)
			
			test('returns nil if the node does not exist', function()
				assert_nil(grid:getNodeAt(0,0))
				assert_nil(grid:getNodeAt(5,1))
			end)

			test('returns nil if one of its args is missing', function()
				assert_nil(grid:getNodeAt(0))
				assert_nil(grid:getNodeAt())
			end)			
		
	end)
		
	context('Grid:getNodes()', function()
	
		test('returns the array of nodes', function()
			local map = {{0,0},{0,0}}
			local grid = Grid(map)
			local nodes = grid:getNodes()
			
			assert_equal(type(nodes), 'table')	
			for y in pairs(nodes) do
				for x in pairs(nodes[y]) do
					assert_equal(getmetatable(nodes[y][x]),Node)
				end
			end 
		end)
	
	end)
	
	context('grid:getNeighbours()', function()
		
			test('returns neighbours of a given node', function()
				local map = {{0,0},{0,0},}
				local grid = Grid(map)
				local walkable = 0
				local node = grid:getNodeAt(1,1)
				local nb = grid:getNeighbours(node, walkable)
				
				assert_equal(type(nb), 'table')
				assert_equal(#nb, 2)
				assert_equal(nb[1], grid:getNodeAt(2,1))
				assert_equal(nb[2], grid:getNodeAt(1,2))
			end)
			
			test('passing a true as a third arg includes ajacent nodes', function()
				local map = {{0,0},{0,0},}
				local grid = Grid(map)
				local walkable, allowDiag = 0, true
				
				local node = grid:getNodeAt(1,1)
				local nb = grid:getNeighbours(node, walkable, allowDiag)
				
				assert_equal(type(nb), 'table')
				assert_equal(#nb, 3)
				assert_equal(nb[1], grid:getNodeAt(2,1))
				assert_equal(nb[2], grid:getNodeAt(1,2))
				assert_equal(nb[3], grid:getNodeAt(2,2))
			end)		
			
	end)
		
	context('Grid:iter()', function()
			
			test('iterates on all nodes in a grid', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}
				for n in grid:iter() do
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])
					assert_nil(record[n])
					record[n] = true
				end
			end)
			
			test('can iterate only on a rectangle of nodes', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}
				for n in grid:iter(2,2,3,3) do
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])					
					assert_gte(n.x, 2)
					assert_gte(n.y, 2)
					assert_lte(n.x, 3)
					assert_lte(n.y, 3)
					assert_nil(record[n])
					record[n] = true
				end
			end)			
		
	end)
		
	context('Grid:each()', function()
			
			test('calls a given function on each node in a grid', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}
				local function f(node,i) node.value = i end
				grid:each(f, 3)
				for n in grid:iter() do
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])
					assert_equal(n.value,3)
					assert_nil(record[n])
					record[n] = true
				end
			end)
		
	end)
		
	context('Grid:eachRange()', function()
			
			test('calls a given function on each node in a range', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}
				local function f(node,i) node.value = i end
				grid:eachRange(1,1,2,2,f,3)
				for n in grid:iter() do
					if n.x <= 2 and n.y <= 2 then
						assert_equal(n.value,3)
					else
						assert_nil(n.value)
					end
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])
					assert_nil(record[n])
					record[n] = true
				end
			end)
		
	end)		
		
	context('Grid:imap()', function()
			
			test('Maps a given function on each node in a grid', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}
				local function f(node,i) 
					node.v = i
					return node
				end
				grid:imap(f, 5)
				for n in grid:iter() do
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])
					assert_equal(n.v,5)
					assert_nil(record[n])
					record[n] = true
				end
			end)
		
	end)

	context('Grid:imapRange()', function()
			
			test('calls a given function on each node in a range', function()
				local map = {
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
					{0,0,0,0},
				}
				local grid = Grid(map)
				local record = {}				
				local function f(node,i) 
					node.v = i
					return node
				end
				grid:imapRange(3,3,4,4,f,7)
				for n in grid:iter() do
					if n.x >= 3 and n.y >= 3 then
						assert_equal(n.v,7)
					else
						assert_nil(n.v)
					end
					assert_equal(getmetatable(n), Node)
					assert_not_nil(map[n.y] and map[n.y][n.x])
					assert_nil(record[n])
					record[n] = true
				end
			end)
		
	end)		
		
end)