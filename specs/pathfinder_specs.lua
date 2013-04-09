context('Module Pathfinder', function()
	local PF, H, Grid, Path, map, grid
	
	before(function()
		PF = require ('jumper.pathfinder')
		Grid = require ('jumper.grid')
		H = require ('jumper.core.heuristics')
		Path = require ('jumper.core.path')
		map = {{0,0,0},{0,0,0},{0,0,0}}
		grid = Grid(map)
  end)
	
  context('Pathfinder:new() or Pathfinder()', function()
		
		test('Inits a new Pathfinder object', function()
			assert_equal(getmetatable(PF(grid, 'ASTAR')), PF)
			assert_equal(getmetatable(PF:new(grid, 'ASTAR')), PF)
		end)
		
		test('First arg is a grid object', function()
			assert_error(pcall(PF, PF))
			assert_error(pcall(PF, PF, map))
			assert_equal(getmetatable(PF(grid)), PF)
		end)
		
		test('Second arg, when given must be a valid finderName', function()
			assert_error(pcall(PF, PF, grid, 'finder'))
			for i, finder in ipairs(PF:getFinders()) do
				assert_equal(getmetatable(PF(grid, finder)), PF)
			end
		end)
		
		test('Defaults to \'ASTAR\' when not given', function()
			local pf = PF(grid)
			assert_equal(getmetatable(pf), PF)
			assert_equal(pf:getFinder(), 'ASTAR')
		end)
		
		test('Third arg walkable can be a string, function, int or nil', function()
			assert_equal(getmetatable(PF(grid, 'ASTAR', 'A')), PF)
			assert_equal(getmetatable(PF(grid, 'ASTAR', function() end)), PF)
			assert_equal(getmetatable(PF(grid, 'ASTAR', 1)), PF)
			assert_equal(getmetatable(PF(grid, 'ASTAR', nil)), PF)
			assert_error(pcall(PF, PF, grid, 'ASTAR', 2.2))
			assert_error(pcall(PF, PF, grid, 'ASTAR', {}))
		end)
		
	end)
	
	context('Pathfinder:getGrid()', function()
		
		test('returns the grid object used by the Pathfinder', function()
			local pf = PF(grid)
			assert_equal(pf:getGrid(), grid)
		end)
		
	end)
	
	context('Pathfinder:setGrid()', function()
	
		test('Sets the grid object on which the Pathfinder performs', function()
			local pf = PF(grid)
			local newGrid = Grid('00000\n00000')
			
			assert_equal(pf:getGrid(), grid)
			pf:setGrid(newGrid)
			assert_equal(pf:getGrid(), newGrid)
		end)
		
		test('passing nil raises an error', function()
			local pf = PF(grid)
			assert_error(pcall(pf.setGrid, pf, nil))
		end)
		
	end)
	
	context('Pathfinder:getWalkable()', function()
	
		test('returns the walkable parameter', function()
			local pf = PF(grid, 'ASTAR', 1)
			assert_equal(pf:getWalkable(), 1)
		end)
		
		test('is nil when not given', function()
			local pf = PF(grid)
			assert_nil(pf:getWalkable())		
		end)
		
	end)
	
	context('Pathfinder:setWalkable()', function()
	
		test('sets the string, function, nil or int walkable value', function()
			local pf = PF(grid, 'ASTAR')
			assert_nil(pf:getWalkable())
			
			pf:setWalkable('A')
			assert_equal(pf:getWalkable(), 'A')
			
			pf:setWalkable(2)
			assert_equal(pf:getWalkable(), 2)
			
			local f = function() end
			pf:setWalkable(f)
			assert_equal(pf:getWalkable(), f)
		end)
		
		test('is nil when not given', function()
			local pf = PF(grid)
			assert_nil(pf:getWalkable())		
		end)
		
		test('raises an error when passed-in value is not a string, int, nil or function', function()
			local pf = PF(grid)			
			assert_error(pcall(pf.setWalkable, pf, {}))
			assert_error(pcall(pf.setWalkable, pf, 0.4))
		end)
		
	end)	
	
	context('Pathfinder:getFinder()', function()
		
		test('returns the finder name used', function()
			local pf = PF(grid, 'JPS')
			assert_equal(pf:getFinder(), 'JPS')
		end)
		
	end)
	
	context('Pathfinder:setFinder()', function()

		test('sets the finder to be used', function()
			local pf = PF(grid)
			pf:setFinder('DFS')
			assert_equal(pf:getFinder(), 'DFS')
		end)
		
		test('Upon init, the default finder, when not given, is \'ASTAR\'', function()
			local pf = PF(grid)
			assert_equal(pf:getFinder(), 'ASTAR')
		end)

		test('Passing nil sets \'ASTAR\` as the finder if no previous finder was set, is \'ASTAR\'', function()
			local pf = PF(grid)
			pf:setFinder()
			assert_equal(pf:getFinder(), 'ASTAR')
		end)
		
		test('Passing nil has no effect if a finder was set previously', function()
			local pf = PF(grid, 'JPS')
			pf:setFinder()
			assert_equal(pf:getFinder(), 'JPS')
		end)			
	
	end)
	
	context('Pathfinder:getFinders()', function()
		
		test('returns the list of all existing finders', function()
			local fs = PF:getFinders()
			local pf = PF(grid)
			
			assert_greater_than(#fs, 0)
			for i,finder in ipairs(fs) do
				pf:setFinder(finder)
				assert_equal(pf:getFinder(), finder)
			end
		end)
		
	end)
	
	context('Pathfinder:getHeuristic()', function()
		
		test('returns the heuristic function used', function()
			local pf = PF(grid)
			assert_not_nil(pf:getHeuristic())
		end)
		
		test('default heuristic is \'MANHATTAN\'', function()
			local pf = PF(grid)
			assert_equal(pf:getHeuristic(), H.MANHATTAN)
		end)
		
	end)
	
	context('Pathfinder:setHeuristic()', function()
		
		test('sets the heuristic function to be used', function()
			local pf = PF(grid)
			pf:setHeuristic('MANHATTAN')
			assert_equal(pf:getHeuristic(), H.MANHATTAN)
		end)
		
		test('handles custom heuristic functions', function()
			local pf = PF(grid)
			local f = function() end
			pf:setHeuristic(f)
			assert_equal(pf:getHeuristic(),f)
		end)
		
		test('passing nil produces an error',function()
			local pf = PF(grid)
			assert_error(pcall(pf.setHeuristic, pf))
		end)
		
	end)

	context('Pathfinder:getHeuristics()', function()
		
		test('returns all available heuristics', function()
			local hs = PF:getHeuristics()
			assert_greater_than(#hs, 0)
			local pf = PF(grid)
			for i, heur in ipairs(hs) do
				pf:setHeuristic(heur)
				assert_equal(pf:getHeuristic(), H[heur])
			end
		end)
		
	end)
	
	context('Pathfinder:getMode()', function()
	
		test('returns the actual search mode', function()
			local pf = PF(grid)
			pf:setMode('DIAGONAL')
			assert_equal(pf:getMode(),'DIAGONAL')
		end)

		test('default search mode is  \'DIAGONAL\'', function()
			local pf = PF(grid)
			assert_equal(pf:getMode(),'DIAGONAL')
		end)
		
	end)
	
	context('Pathfinder:setMode()', function()
		
		test('sets the search mode', function()
			local pf = PF(grid)		
			pf:setMode('ORTHOGONAL')
			assert_equal(pf:getMode(), 'ORTHOGONAL')
			pf:setMode('DIAGONAL')
			assert_equal(pf:getMode(), 'DIAGONAL')	
		end)
		
		test('passing nil or any other invalid arg causes an error', function()
			local pf = PF(grid)		
			
			assert_error(pcall(pf.setMode, pf))		
			assert_error(pcall(pf.setMode, pf, 'ORTHO'))		
			assert_error(pcall(pf.setMode, pf, function() end))	
		end)
		
	end)
	
	context('Pathfinder:getModes()', function()
		
		test('returns all available modes', function()
			local ms = PF:getModes()
			assert_equal(#ms, 2)
			local pf = PF(grid)
			
			for i, mode in ipairs(ms) do
				pf:setMode(mode)
				assert_equal(pf:getMode(),mode)
			end
		end)
		
	end)
		
	context('Pathfinder:setTunnelling()', function()
		
		test('Enables or disables tunnelling feature', function()
			PF:setTunnelling(true)
			assert_true(PF:getTunnelling())
			PF:setTunnelling(false)
			assert_false(PF:getTunnelling())
		end)
		
		test('Enables or disables tunnelling feature', function()
			PF:setTunnelling(true)
			assert_true(PF:getTunnelling())
			PF:setTunnelling(false)
			assert_false(PF:getTunnelling())
		end)
		
		test('When on, finder goes through walls heading diagonally', function()
			local map = {{0,0,0},{1,0,0},{0,2,0}}
			local grid = Grid(map)
			local finder = PF(grid, 'ASTAR',0)
			finder:setTunnelling(true)
			local path = finder:getPath(1,3,3,1)
			assert_equal(path._nodes[1]._x,1)
			assert_equal(path._nodes[1]._y,3)
			assert_equal(path._nodes[2]._x,2)
			assert_equal(path._nodes[2]._y,2)
			assert_equal(path._nodes[3]._x,3)
			assert_equal(path._nodes[3]._y,1)			
		end)
		
	end)
	
	context('Pathfinder:getTunnelling()', function()
		
		test('Returns the actual state of tunnelling feature', function()
			assert_false(PF:getTunnelling())
		end)
		
	end)

	context('Pathfinder:annotateGrid()', function()
		
		test('Calculates clearance for the entire grid', function()
			local map = {
			{0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,1,0},
			{0,0,0,0,0,0,0,0,0,0},
			{0,0,0,1,0,0,0,0,0,0},
			{0,0,1,0,0,0,0,0,2,0},
			{0,0,1,1,1,0,0,2,0,0},
			{0,0,0,1,1,0,2,0,0,2},
			{0,0,0,0,1,0,0,0,0,2},
			{0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0}
		}
		local clearances = {
			{6,6,5,5,4,4,4,3,2,1},
			{6,5,5,4,4,3,3,3,2,1},
			{6,5,4,4,3,3,2,2,2,1},
			{6,5,4,3,3,2,2,1,1,1},
			{6,5,4,3,2,2,1,1,0,1},
			{5,5,4,3,2,1,1,0,1,1},
			{4,4,4,3,2,1,0,2,1,0},
			{3,3,3,3,3,3,3,2,1,0},
			{2,2,2,2,2,2,2,2,2,1},
			{1,1,1,1,1,1,1,1,1,1}
		}
		local grid = Grid(map)
		local walkable = function(v) return v~=2 end
		local finder = PF(grid, 'ASTAR', walkable)
		finder:annotateGrid()
		for node in grid:iter() do
			assert_equal(node:getClearance(walkable), clearances[node._y][node._x])
		end			
		end)
		
	end)

	context('Pathfinder:clearAnnotations()', function()
		
		test('Clears cached clearance values for the entire grid', function()
			local map = {{0,1,0},{0,0,0},{1,1,0}}
			local grid = Grid(map)
			local walkable = 0
			local finder = PF(grid, 'ASTAR', walkable)
			finder:annotateGrid()
			finder:clearAnnotations()
			for node in grid:iter() do
				assert_nil(node:getClearance(walkable))
			end			
		end)
		
	end)
	
	context('Pathfinder:getPath()', function()
		
		test('returns a path', function()
			local pf = PF(grid, 'ASTAR', 0)
			local path = pf:getPath(1,1,3,3)
			assert_equal(getmetatable(path), Path)
		end)
		
		test('start and end locations must exist on the map', function()
			local pf = PF(grid, 'ASTAR', 0)
			assert_error(pcall(pf.getPath, pf, 0,0, 3, 3))
			assert_error(pcall(pf.getPath, pf, 1, 1, 4, 4))
			assert_error(pcall(pf.getPath, pf, 0,0, 4, 4))
		end)
		
		test('goal location must be walkable', function()
			local pf = PF(grid, 'ASTAR', 0)
			map[3][3] = 1
			assert_error(pcall(pf.getPath, pf, 0,0, 3, 3))
		end)
		
	end)	
	
end)