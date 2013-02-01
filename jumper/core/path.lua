--- <strong>The <code>path</code> class</strong>.
-- The `path` class represents a path from a `start` location to a `goal`.
-- An instance from this class would be a result of a request addressed to `pathfinder:getPath`.
-- A `path` is basically a set of `nodes`, aligned in a specific order, defining a way to follow for moving agents.
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @module jumper.core.path

if (...) then

  -- Internalization
  local abs, max = math.abs, math.max
	local t_insert, t_remove = table.insert, table.remove
	
  -- Depandancies
  local Heuristic = require ((...):gsub('%.path$','.heuristics'))

  --- The `path` class
  -- @class table
  -- @name path
  local Path = {}
  Path.__index = Path

  --- Inits a new `path` object.
  -- @class function
  -- @name path:new
  -- @treturn path a `path` object
  function Path:new()
    return setmetatable({}, Path)
  end

  --- Iterates on each single `node` along a `path`. At each step of iteration,
  -- returns a `node` and plus a count value. Aliased as @{path:nodes}
  -- @class function
  -- @name path:iter
  -- @treturn node a `node`
  -- @treturn int the count for the number of nodes
	-- @see path:nodes
  function Path:iter()
    local i,pathLen = 1,#self
    return function()
      if self[i] then
        i = i+1
        return self[i-1],i-1
      end
    end
  end
  
  --- Iterates on each single `node` along a `path`. At each step of iteration,
  -- returns a `node` and plus a count value. Aliased for @{path:iter}
  -- @class function
  -- @name path:nodes
  -- @treturn node a `node`
  -- @treturn int the count for the number of nodes
	-- @see path:iter	
	Path.nodes = Path.iter
	
  --- Evaluates the `path` length
  -- @class function
  -- @name path:getLength
  -- @treturn number the `path` length
  function Path:getLength()
    local len = 0
    for i = 2,#self do
      local dx = self[i].x - self[i-1].x
      local dy = self[i].y - self[i-1].y
      len = len + Heuristic.EUCLIDIAN(dx, dy)
    end
    return len
  end

  --- Path filling function. Interpolates between non contiguous locations along a `path`
  -- to build a fully continuous `path`. This maybe useful when using `Jump Point Search` finder.
  -- Does the opposite of @{path:filter}
  -- @class function
  -- @name path:fill
  -- @see path:filter
  function Path:fill()
    local i = 2
    local xi,yi,dx,dy
    local N = #self
    local incrX, incrY
    while true do
      xi,yi = self[i].x,self[i].y
      dx,dy = xi-self[i-1].x,yi-self[i-1].y
      if (abs(dx) > 1 or abs(dy) > 1) then
        incrX = dx/max(abs(dx),1)
        incrY = dy/max(abs(dy),1)
        t_insert(self, i, self.grid:getNodeAt(self[i-1].x + incrX, self[i-1].y +incrY))
        N = N+1
      else i=i+1
      end
      if i>N then break end
    end
  end

  --- Path compression. Given a `path`, eliminates useless nodes to return a lighter `path`. Does
  -- the opposite of @{path:fill}
  -- @class function
  -- @name path:filter
  -- @see path:fill
  function Path:filter()
    local i = 2
    local xi,yi,dx,dy, olddx, olddy
    xi,yi = self[i].x, self[i].y
    dx, dy = xi - self[i-1].x, yi-self[i-1].y
    while true do
      olddx, olddy = dx, dy
      if self[i+1] then
        i = i+1
        xi, yi = self[i].x, self[i].y
        dx, dy = xi - self[i-1].x, yi - self[i-1].y
        if olddx == dx and olddy == dy then
          t_remove(self, i-1)
          i = i - 1
        end
      else break end
    end
  end

  return setmetatable(Path,
    {__call = function(self,...)
      return Path:new(...)
    end
  })
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
