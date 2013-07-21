Jumper
======

__Jumper__ is a pathfinding library designed for grid-based games. It aims to be __fast__ and __lightweight__.
It features a wide range of search algorithms, built within a clean interface with 
chaining features which makes it __very friendly and easy to use__.<br/>

This is a modified version of Jumper, based on the latest stable ([1.8.1](https://github.com/Yonaba/Jumper/tree/jumper-1.8.1-1)). 
It is actually an attempt to bundle the whole source of Jumper into a single file, returning 
the whole module into the global environment for an easier embedding (in sandboxed environment, for instance).

##Installing Jumper##
Put this single file named [jumper.lua](https://raw.github.com/Yonaba/Jumper/global/jumper.lua) inside your projet.
Use `require` function (or `dofile`) to import the library.
It will add a global namespace named `Jumper`  into the global environment.

## The Jumper namespace
It is actually a simple Lua table with references to all submodules of the Jumper library.

* `Jumper.Node` refers to the `Node` submodule
* `Jumper.Heuristics` refers to the `Heuristics` submodule
* `Jumper.Path refers` to the `Path` submodule
* `Jumper.Grid refers` to the `Grid` submodule
* `Jumper.Pathfinder` refers to the `Pathfinder` submodule

##A Simple Example of Use
Here is a simple example explaining how to use Jumper:

```lua
require ('jumper') -- or dofile('jumper.lua')

-- Simple check to assert if Jumper was successfully imported
assert(Jumper and type(Jumper) == 'table', 'Error loading the Jumper module')

-- Usage Example
-- First, set a collision map
local map = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
local Grid = Jumper.Grid -- Alias to the Grid submodule
local Pathfinder = Jumper.Pathfinder -- Alias to the Pathfinder submodule

-- Creates a grid object
local grid = Grid(map) 
-- Creates a pathfinder object using Jump Point Search
local myFinder = Pathfinder(grid, 'JPS', walkable) 

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(path:getLength()))
	for node, count in path:nodes() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node.x, node.y))
	end
end

--> Output:
--> Path found! Length: 8.83
--> Step: 1 - x: 1 - y: 1
--> Step: 2 - x: 1 - y: 3
--> Step: 3 - x: 2 - y: 4
--> Step: 4 - x: 4 - y: 4
--> Step: 5 - x: 5 - y: 3
--> Step: 6 - x: 5 - y: 1
````

##License##
This work is under [MIT-LICENSE][]<br/>
Copyright (c) 2012-2013 Roland Yonaba.

> Permission is hereby granted, free of charge, to any person obtaining a copy<br/>
> of this software and associated documentation files (the "Software"), to deal<br/>
> in the Software without restriction, including without limitation the rights<br/>
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell<br/>
> copies of the Software, and to permit persons to whom the Software is<br/>
> furnished to do so, subject to the following conditions:<br/>
><br/>
> The above copyright notice and this permission notice shall be included in<br/>
> all copies or substantial portions of the Software.<br/>
><br/>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR<br/>
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,<br/>
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE<br/>
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER<br/>
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,<br/>
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN<br/>
> THE SOFTWARE.

[Jump Point Search]: http://harablog.wordpress.com/2011/09/07/jump-point-search/
[Lua]: http://lua.org
[Löve]: http://love2d.org
[Löve2d]: http://love2d.org
[Löve 0.8.0 Framework]: http://love2d.org
[Dragon Age : Origins]: http://dragonage.bioware.com
[Moving AI]: http://movingai.com
[Nathan Witmer]: http://github.com/aniero
[XueXiao Xu]: http://github.com/qiao
[JavaScript port]: http://github.com/qiao/PathFinding.js
[Alban Grastien]: http://www.grastien.net/ban/
[Daniel Harabor]: http://users.cecs.anu.edu.au/~dharabor/home.html
[the algorithm and the technical papers]: http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
[MIT-LICENSE]: http://www.opensource.org/licenses/mit-license.php
[heuristics.lua]: http://github.com/Yonaba/Jumper/blob/master/Jumper/core/heuristics.lua