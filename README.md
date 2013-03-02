Jumper
======

[![Build Status](http://travis-ci.org/Yonaba/Jumper.png)](http://travis-ci.org/Yonaba/Jumper)

__Jumper__ is a pathfinding library designed for grid-based games. It aims to be __fast__ and __lightweight__.
It features a wide range of search algorithms, built within a clean interface with 
chaining features which makes it __very friendly and easy to use__.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in any project embedding [Lua][] code.

<center><img src="http://ompldr.org/vZjltNQ" alt="" width="500" height="391" border="0" /></center>

###Contents
* [Installation](http://github.com/Yonaba/Jumper#installation)
* [Example of Use](http://github.com/Yonaba/Jumper#example-of-use)
* [API & Docs](http://github.com/Yonaba/Jumper#api--docs)
* [Usage](http://github.com/Yonaba/Jumper#usage)
* [The Grid](http://github.com/Yonaba/Jumper#the-grid)
* [Handling paths](http://github.com/Yonaba/Jumper#handling-paths)
* [Chaining](http://github.com/Yonaba/Jumper#chaining)
* [Specs](http://github.com/Yonaba/Jumper#specs)
* [Credits and Thanks](http://github.com/Yonaba/Jumper#credits-and-thanks)
* [License](http://github.com/Yonaba/Jumper#license)

##Installation
The current repository can be retrieved locally on your computer via:

###Bash
```bash
git clone git://github.com/Yonaba/Jumper.git
````

###Download (latest)
* __Development release__: [zip](http://github.com/Yonaba/Jumper/zipball/master) | [tar.gz](http://github.com/Yonaba/Jumper/tarball/master)
* __Stable release (1.8.1)__: [zip](http://github.com/Yonaba/Jumper/archive/jumper-1.8.1-1.zip) | [tar.gz](http://github.com/Yonaba/Jumper/archive/jumper-1.8.1-1.tar.gz)
* __All releases__: [tags](http://github.com/Yonaba/Jumper/tags)


###LuaRocks
```bash
luarocks install jumper
````

###MoonRocks
```bash
luarocks install --server=http://rocks.moonscript.org/manifests/Yonaba jumper
````

##Example of Use
Here is a simple example explaining how to use Jumper:

```lua
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
local Grid = require ("jumper.grid") -- The grid class
local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass

-- Creates a grid object
local grid = Grid(map) 
-- Creates a pathfinder object using Jump Point Search
local myFinder = Pathfinder(grid, 'JPS', walkable) 

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path, length = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(length))
	for node, count in path:iter() do
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

Find some other examples of use for __Jumper__, made with various Lua-based frameworks and game engines in this separated repository: [Jumper-Examples](http://github.com/Yonaba/Jumper-Examples)

##API & Docs##
Find a complete documentation and API description online here: [docs](http://yonaba.github.com/Jumper)

##Usage##
###Adding Jumper to your project###
Copy the contents of the folder named [jumper](http://github.com/Yonaba/Jumper/blob/master/jumper) and its contents and place it inside your projet. Use *require* function to import any module of the library.

###Setting your collision map
The collision map is a regular Lua table where each cell holds a value, representing whether or not the corresponding tile in the 2D world is walkable
or not.<br/>
__Caution__ : *All cells in your collision maps must be indexed with consecutive integers* __starting at 0__ or __1__.

```lua
local map = {
  {0,0,0,0,0,0},
  {0,1,2,3,4,0},
  {0,0,0,0,5,0},
  {0,1,2,3,6,0},
  {0,0,0,0,0,0},
}
```

__Note__: Lua array lists starts __indexing at 1__, by default. Using some dedicated *librairies/map designing tools* to export your collisions maps to Lua,
the resulting tables might __start indexing at 0__ or whatever else integer. This is fairly legit in Lua, but not common, though.
__Jumper__ will accomodate such maps without any problem.

Jumper also supports string maps. Therefore, you can also use a string to define your collision map. Line break characters ('\n' or '\r') will be used to delimit rows,
as shown below:

```lua
local stringMap = "xxxxxxxxxxxxxx\n"..
				  "x  r         x\n"..
				  "x       .... x\n"..
				  "x            x\n"..
				  "x   J  $$$   x\n"..
				  "x            x\n"..
				  "xxxxxxxxxxxxxx\n"
]]
```

Optionally, you can also use *square brackets* :

```lua
local stringMap = [[
xxxxxxxxxxxxxx
x  r         x
x       .... x
x            x
x   J  $$$   x
x            x
xxxxxxxxxxxxxx
]]
```

###Initializing Jumper###
Once your collision map is set, you have to init a `grid` object.
This is fairly simple, you just have to require the [grid](http://github.com/Yonaba/Jumper/blob/master/jumper/grid.lua) module, and then pass it two arguments.

```lua
local Grid = require 'jumper.grid'
local grid = Grid(map,processOnDemand)
```

Only the first arg `map` is __mandatory__. It refers to the [collision map](http://github.com/Yonaba/Jumper#setting-your-collision-map) previously defined.
The second arg `processOnDemand` is optional. See [here](http://github.com/Yonaba/Jumper#the-grid-object) for more details.<br/>
 
Next, to init a `pathfinder`, you have specify what value in this collision map matches a __walkable__ tile. If you choose for instance *0* for *walkable tiles*, 
and you happen to assign that value to the `pathfinder`, it will consider __any other value__ as *non walkable*.<br/>
To initialize a `pathfinder`, you will have to require the [pathfinder](http://github.com/Yonaba/Jumper/blob/master/jumper/pathfinder.lua) module, and then pass it __three arguments__.

```lua
local myFinder = Pathfinder(grid, finderName, walkable)
```

The first arg is __mandatory__. The others are optional.
* `grid` refers to the grid object.
* `finderName` refers to the search algorithm to be used by the pathfinder. See [finders](http://github.com/Yonaba/Jumper#finders) for more details.
* `walkable` (optional) refers to the value representing walkable tiles. If not given, any tile will be considered *fully walkable* on the grid.

You might want to have __multiple values designing a walkable tile__. 
In this case, argument <tt>walkable</tt> can be a function, prototyped as <tt>f(value)</tt>, returning a boolean.

```lua
local map = {
  {0,0,0,0,0,0},
  {0,1,2,3,4,0},
  {0,0,0,0,5,0},
  {0,1,2,3,6,0},
  {0,0,0,0,0,0},
}
-- We want all values greater than 0 to be walkable
local function walkable(value)
  if value > 0 then return true end
  return false
end

local Grid = require ('jumper.grid')
local Pathfinder = require('jumper.pathfinder')
local myFinder = Pathfinder(Grid(map), 'ASTAR', walkable)
```

###Finders
Jumper uses search algorithm to perform a path search from one location to another.
Actually, there are dozens of search algorithms, each one having its strengths and weaknesses, and this library implements some of these algorithms.
[Since v1.8.0](http://github.com/Yonaba/Jumper/blob/master/version_history.md#180-01262013), Jumper implements a wide range of search algorithms: 
* [A-star](http://en.wikipedia.org/wiki/A-star)
* [Dijkstra](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
* [Breadth-First search](http://en.wikipedia.org/wiki/Breadth-first_search)
* [Depth First search](http://en.wikipedia.org/wiki/Depth-first_search)
* [Jump Point Search](http://harablog.wordpress.com/2011/09/07/jump-point-search/) (which is one of the fastest available for grid maps).

```lua
local Grid = require ('jumper.grid')
local Pathfinder = require ('jumper.pathfinder')
local myFinder = Pathfinder(Grid(map), 'JPS', 0)
print(myFinder:getFinder()) --> 'JPS'
````

Use `pathfinder:getFinders` to get the list of all available finders, and `pathfinder:setFinder` to switch to another search algorithm.
See the [`pathfinder` class documentation](http://yonaba.github.com/Jumper/modules/jumper.pathfinder.html) for more details.

###Distance heuristics###
`Heuristics` are functions used by the search algorithm to evaluate the optimal path while processing.

####Built-in heuristics
Jumper features four (4) types of distance heuristics.

* MANHATTAN distance : *|dx| + |dy|*
* EUCLIDIAN distance : *sqrt(dx*dx + dy*dy)*
* DIAGONAL distance : *max(|dx|, |dy|)*
* CARDINAL/INTERCARDINAL distance: *min(|dx|,|dy|)*sqrt(2) + max(|dx|,|dy|) - min(|dx|,|dy|)*

By default, when you init Jumper, __MANHATTAN__ distance will be used.<br/>
If you want to use __another heuristic__, you just have to pass one of the following predefined strings to <tt>pathfinder:setHeuristic(Name)</tt>:

```lua
"MANHATTAN" -- for MANHATTAN Distance
"EUCLIDIAN" -- for EUCLIDIAN Distance
"DIAGONAL" -- for DIAGONAL Distance
"CARDINTCARD" -- for CARDINAL/INTERCARDINAL Distance
```

As an example :

```lua
local Grid = require ('jumper.grid')
local Pathfinder = require('jumper.pathfinder')
local myFinder = Pathfinder(Grid(map),'ASTAR')
myFinder:setHeuristic('CARDINTCARD')
```
See [docs](http://yonaba.github.com/Jumper/modules/jumper.core.heuristics.html) for more details on how to deal with distance heuristics.

####Custom heuristics
You can also cook __your own heuristic__. This custom heuristic should be passed to <tt>Pathfinder:setHeuristic()</tt> as a function 
prototyped for two parameters, to be *dx* and *dy* (being respecitvely the distance *in tile units* from a target location to the current on x and y axis).<br/>
__Note__: When writing *your own heuristic*, take into account that values passed as *dx* and *dy* __can be negative__.

As an example:

```lua
-- A custom heuristic
local function myDistance(dx, dy)
  return (math.abs(dx) + 1.4 * math.abs(dy))
end
local Grid = require ('jumper.grid')
local Pathfinder = require('jumper.pathfinder')
local myFinder = Pathfinder(Grid(map), 'ASTAR')
myFinder:setHeuristic(myDistance)
````

##The Grid
###Map access
When you init a `grid` object, passing it a 2D map (2-dimensional array), __Jumper__ keeps track of this map.<br/>
Therefore, you can access it via <tt>(Grid()):getMap()</tt>

###The Grid Object
When creating the `grid` object, the map passed as argument is __pre-preprocessed by default__. It just means that __Jumper__ caches all nodes and create some internal data needed for pathfinding operations.
This will make further pathfinding requests being answered faster, but will __have a drawback in terms of memory consumed__.<br/>
*As an example, a __500 x 650__ sized map will consume around __55 Mb__ of memory right after initializing Jumper, when using the pre-preprocesed mode.*

You can __optionally__ choose to __process nodes on-demand__, setting the relevant argument to <tt>true</tt> when initializing __Jumper__.

```lua

local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local Grid = require 'jumper.grid'
local Pathfinder = require 'jumper.pathfinder'

local processOnDemand = true
local grid = Grid(map, processOnDemand)
local walkable = 0
local myFinder = Pathfinder(grid, 'DFS', walkable)
````

In this case, the internal grid will consume __0 kB (no memory) at initialization__. But later on, this is likely to grow, as __Jumper__ will automatically create and keep caching new nodes __on purpose__.
This *might be a better approach* if you are facing to tightening constraints in terms of available memory, working with huge maps. But it *also* has a little inconvenience : 
pathfinding requests __will take a little tiny bit longer__ (about 10-30 extra-milliseconds on huge maps), because of the extra work, that is, creating the new required nodes.<br/>
Therefore, consider this a __tuning parameter__, and choose what suits the best to your needs.

##Handling paths##
###Using native <tt>Pathfinder:getPath()</tt>###

Calling <tt>Pathfinder:getPath()</tt> will return a `path`.<br/>
The `path` is always represented as follows :

```lua
path = {
	node1,
	node2,
	...
	nodeN
}
```

Each [node](http://yonaba.github.com/Jumper/modules/jumper.core.node.html) has `x` and `y` attributes, corresponding to its location on the grid. That is, a set of nodes makes a complete path.

You can iterate on nodes along a `path` using <tt>path:iter</tt>
```lua
for node,step in path:iter() do
  -- ...
end
````

###Path filling###
Depending on the search algorithm being used, the set of nodes composing a `path` may not be contiguous.
For instance, in the path given below, you can notice node `{x = 1,y = 3}` was skipped.

```lua
local path = {{x = 1, y = 1},{x = 1,y = 2},{x = 1,y = 4}}
````

This is actually not a problem, as the way from `{x = 1,y = 2}` to `{x = 1,y = 4}` is straight. Anyway, __Jumper__ provides a __path filling__ feature 
that can be used to polish (interpolate) a path early computed, filling such holes.

```lua
-- Assuming: path = {{x = 1,y = 1},{x = 4,y = 4}}
path:fill() -- Returns {{x = 1,y = 1},{x = 2,y = 2},{x = 3,y = 3},{x = 4,y = 4}}
```

###Path filtering###
This feature does the opposite work of `Pathfinder:fill`.
Given a path, it removes some unecessary nodes to leave a path made of turning points. The path to follow would be the straight line between all those nodes.

```lua
-- Assuming: path = {{x = 1,y = 1},{x = 1,y = 2},{x = 1,y = 3},{x = 1,y = 4},{x = 1,y = 5}}
path:filter() -- Returns {{x = 1,y = 1},{x = 1,y = 5}}
````

See [`path` class documentation](http://yonaba.github.com/Jumper/modules/jumper.core.path.html) for more details.

### Tunnelling
Normally, the pathfinder should returns paths avoiding walls, obstacles. But, you can also authorize it to `tunnel through` walls, 
that is, to cross them deading diagonally.

Let's set an example:

```
local map = {
 {1,1,0},
 {1,0,1},
 {0,1,1},
}
```
`0` refers to walkable tiles, and `1` for unwalkable tiles.
Let's assume we want to move from location `[x: 1, y:3]` to `[x: 3, y:1]`. Calling `getPath()` would fail, because it can't normally cross
from `[x: 1, y:3]` to `[x: 2, y:2]` (because tiles `[x: 1, y:2]` and `[x: 2, y:3]` are unwalkable), nor from `[x: 2, y:2]` to `[x: 3, y:1]` (because tiles `[x: 2, y:1]` and `[x: 3, y:2]` are unwalkable).

[Passing a fifth argument](http://yonaba.github.com/Jumper/modules/jumper.pathfinder.html#pathfinder:getPath) `tunnel` will override this behaviour, and cause the pathfinder to *tunnel though* those walls.

```
local map = {
 {1,1,0},
 {1,0,1},
 {0,1,1},
}
local tunnel = true
local path = myFinder:getPath(1,3,3,1,tunnel)
print(path~=nil) --> true
```

A __side note__ though, that feature works perfectly with all the available [finders](http://github.com/Yonaba/Jumper#finders) built-in Jumper, __except Jump Point Search algorithm__, as of now.

##Chaining##
All setters can be chained.<br/>
This is convenient if you need to __quickly reconfigure__ the `pathfinder` object.

```lua 
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}

local Grid = require ('jumper.grid')
local Pathfinder = require ('jumper.pathfinder')

local grid = Grid(map)
local myFinder = Pathfinder(grid, 'BFS', 0)
-- some code
-- calls the finder, reconfigures it and requests a new path
local path,length = myFinder:setFinder('ASTAR')
				   :setHeuristic('EUCLIDIAN')
				   :setMode('ORTHOGONAL')
				   :getPath(1,1,3,3)
-- That's it!				   
```

##Specs
Specs tests have been included.<br/>
You can run them using [Telescope](http://github.com/norman/telescope) with the following command 
from the [root](http://github.com/Yonaba/Jumper/blob/master/jumper) folder:

```
tsc -f specs/*
```

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [the algorithm and the technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their [JavaScript port][] <br/>
* [Steve Donovan](http://github.com/stevedonovan): for the awesome documentation generator tool [LDoc](http://github.com/stevedonovan/ldoc/).
* [Srdjan Markovic](http://github.com/srdjan-m), who reported various bugs and feedbacks.

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