Jumper
======

__Jumper__ is a pathfinding library designed for __uniform-cost 2D grid-based__ games featuring [Jump Point Search][] algorithm.<br/>
It aims to be __fast__ and __lightweight__. As such, it is an interesting option for __pathfinding computation on 2D maps__.<br/>
It also features a __clean public interface__ with __chaining features__ which makes it __very friendly and easy to use__.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in __any project__ embedding [Lua][] code.

<center><img src="http://ompldr.org/vZjltNQ" alt="" width="500" height="391" border="0" /></center>

##Installation
The current repository can be retrieved locally on your computer via:

###Bash
```bash
git clone git://github.com/Yonaba/Jumper.git
````

###Download (latest)
* __Archive:__ [zip](https://github.com/Yonaba/Jumper/zipball/master) 
* __Tarball:__ [tarball](https://github.com/Yonaba/Jumper/tarball/master)

###LuaRocks
```bash
luarocks install jumper
````

###MoonRocks
```bash
luarocks install --server=http://rocks.moonscript.org/manifests/Yonaba jumper
````

##Examples of Use
Here is a basic usage example for Jumper:

```lua
local Jumper = require ("Jumper.init") -- Imports the library
local walkable = 0 -- Sets the value for walkable tiles
local map = { -- The 2D collision map
 {0,1,0,1,0 },
 {0,1,0,1,0 },
 {0,1,1,1,0 },
 {0,0,0,0,0 },
}

local pathfinder = Jumper(map,walkable) -- Inits a pathfinder
local startx, starty = 1,1 -- The start location 
local endx, endy = 5,1 -- The goal location 
local path, pathLen = pathfinder:getPath(startx, starty, endx, endy) -- Gets the path

if path then -- if a path was found
  print(('Path from [%d,%d] to [%d,%d] found! Length: %.2f')
	:format(startx, starty,endx,endy, pathLen))
  for x,y,step in path:iter() do -- iterates through the path, printing x, y coordinates
    print(('Step: %d - x: %d - y: %d'):format(step,x,y))
  end
end
````

Find some other examples of use for __Jumper__, made with various Lua-based frameworks and game engines in this separated repository: [Jumper-Examples](https://github.com/Yonaba/Jumper-Examples)

##API & Docs##
Find a complete documentation and API description here: [docs](https://github.com/Yonaba/Jumper/blob/master/Jumper/docs)

##Usage##
###Adding Jumper to your project###
Copy this repository contents in a folder named __Jumper__ and put it inside your projet. Use *require* function to call the library.

```lua
local Jumper = require('Jumper.init')
```

**Note** :  You can add __.init.lua__ in your <tt>package path</tt>. As a result, requiring __Jumper__ will become easier.

```lua
package.path = package.path .. ';.\\?\\init.lua'
local Jumper = require ('Jumper')
```
	
**Note** : Some frameworks, like [Löve2d][] already have this feature. Using them, you can just write :

```lua
local Jumper = require('Jumper')
```

###Setting your collision map
The collision map is a regular Lua table where each cell holds a value, representing whether or not the corresponding tile in the 2D world is walkable
or not.<br/>
__Caution__ : *All cells in your collision maps must be indexed with consecutive integers*.

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

Optionally, you can also use square brackets :

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
Once your collision map is set, you must specify what value in this collision map matches a __walkable__ tile. If you choose for instance *0* for *walkable tiles*, 
__any other value__ will be considered as *non walkable*.<br/>

To initialize the pathfinder, you will have to pass __three arguments__ to Jumper.

```lua
local map = {
  {0,0,0,0,0,0},
  {0,1,2,3,4,0},
  {0,0,0,0,5,0},
  {0,1,2,3,6,0},
  {0,0,0,0,0,0},
}
local pathfinder = Jumper(map,walkable,processOnDemand)
```

Only the first argument is __mandatory__. The __two others__ left are __optional__.
* __map__ refers to the collision map representing the 2D world.
* __walkable__ (optional) refers to the value representing walkable tiles. Will be considered as __0__ if not given.
* __processOnDemand__ (optional) is a boolean to __enable or not__ [on-demand processing for the internal grid](https://github.com/Yonaba/Jumper/#grid-processing).

You might want to have multiple values designing a walkable tile. 
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
local pathfinder = Jumper(map,walkable)
```

###Distance heuristics###
Heuristics are functions used by the search algorithm to evaluate the optimal path while processing.

####Built-in heuristics
*Jumper* features four (4) types of distance heuristics.

* MANHATTAN distance : *|dx| + |dy|*
* EUCLIDIAN distance : *sqrt(dx*dx + dy*dy)*
* DIAGONAL distance : *max(|dx|, |dy|)*
* CARDINAL/INTERCARDINAL distance: *min(|dx|,|dy|)*sqrt(2) + max(|dx|,|dy|) - min(|dx|,|dy|)*

By default, when you init  *Jumper*, __MANHATTAN__ will be used.<br/>
If you want to use __another distance heuristic__, you just have to pass one of the following predefined strings to <tt>pathfinder:setHeuristic(Name)</tt>:

```lua
"MANHATTAN" -- for MANHATTAN Distance
"EUCLIDIAN" -- for EUCLIDIAN Distance
"DIAGONAL" -- for DIAGONAL Distance
"CARDINTCARD" -- for CARDINAL/INTERCARDINAL Distance
```

As an example :

```lua
local Jumper = require('Jumper.init')
local pathfinder = Jumper(map)
pathfinder:setHeuristic('CARDINTCARD')
```

####Custom heuristics
You can also cook __your own heuristic__. This custom heuristic should be passed to <tt>pathfinder:setHeuristic()</tt> as a function 
prototyped for two parameters, to be *dx* and *dy* (being respecitvely the distance *in tile units* from a target location to the current on x and y axis).<br/>
__Note__: When writing *your own heuristic*, take into account that values passed as *dx* and *dy* __can be negative__.

As an example:

```lua
-- A custom heuristic
local function distance(dx, dy)
  return (math.abs(dx) + 1.4 * math.abs(dy))
end
local Jumper = require('Jumper.init')
local pathfinder = Jumper(map)
pathfinder:setHeuristic(distance)
````

##The Grid
###Map access
When you init __Jumper__, passing it a 2D map (2-dimensional array), __Jumper__ keeps track of this map.<br/>
Therefore, you can access it via <tt>(pathfinder:getGrid()).map</tt>

```lua
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}

local Jumper = require 'Jumper.init'
local pathfinder = Jumper(map)
local internalGrid = pathfinder:getGrid()
print(internalGrid.map == map) --> true
````

###The Grid Object
__Jumper__ creates an *internal grid* (which is also a 2D dimensional array) that will be used __later on__ to answer your pathfinding calls. This
internal array of nodes is accessible via <tt>pathfinder:getGrid().nodes</tt>.<br/>
__When initializing Jumper__, the map passed as an argument is __pre-preprocessed by default__. It just means that __Jumper__ caches all nodes with respect to the map passed at first and create some internal data needed for pathfinding operations.
This will make further pathfinding requests being answered faster, but will __have a drawback in terms of memory consumed__.<br/>
*As an example, a __500 x 650__ sized map will consume around __55 Mb__ of memory right after initializing Jumper, when using the pre-preprocesed mode.*

You can __optionally__ choose to __process nodes on-demand__, setting the relevant argument to <tt>true</tt> when initializing __Jumper__.

```lua
local Jumper = require 'Jumper.init'
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local walkable = 0
local processOnDemand = true
local pathfinder = Jumper(map,walkable,processOnDemand)
````

In this case, the internal grid will consume __0 kB (no memory) at initialization__. But later on, this is likely to grow, as __Jumper__ will automatically create and keep caching new nodes __on purpose__.
This *might be a better approach* if you are facing to tightening constraints in terms of available memory, working with huge maps. But it *also* has a little inconvenience : 
pathfinding requests __will take a little tiny bit longer__ (about 10-30 extra-milliseconds on huge maps), because of the extra work, that is, creating the new required nodes.<br/>
Therefore, consider this a __tuning parameter__, and choose what suits the best to your needs.

##Handling paths##
###Using native <tt>pathfinder:getPath()</tt>###

Calling <tt>pathfinder:getPath()</tt> will return a table representing a path from one node to another.<br/>
The path is always represented as follows :

```lua
path = {
          {x = 1,y = 1},
          {x = 2,y = 2},
          {x = 3,y = 3},
          ...
          {x = n,y = n},
        }
```

You can iterate on nodes along the path using <tt>path:iter</tt>
```lua
for x,y,step in path:iter() do
  -- ...
end
````
You will have to make your own use of the returned path to __route your entities__ on the map.<br/>
Note that the path could contains some *holes* because of the algorithm used.<br/>
However, this __will not cause any issue__ as a move from one step to another along this path is __always straight__.<br/>
You can accomodate of this by yourself, or use the __path filling__ feature.

###Path filling###

__Jumper__ provides a __path filling__ feature that can be used to polish (interpolate) a path early computed, filling the holes it may contain.

```lua
local Jumper = require('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pathfinder = Jumper(map)
local path, length = pathfinder:getPath(1,1,3,3)
-- Just pass the path to pathfinder:fill().
pathfinder:fill(path)
```

###Automatic path filling###
This feature will trigger <tt>pathfinder:fill()</tt> right after any call to <tt>pathfinder:getPath()</tt>.<br/>

```lua  
local Jumper = require('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pathfinder = Jumper(map)
pathfinder:setAutoFill(true)
local path, length = pathfinder:getPath(1,1,3,3)
-- path is already filled
```

##Chaining##
All setters methods can be chained.<br/>
This is convenient if you need to __quickly reconfigure__ the pathfinder instance__.

```lua 
local Jumper = require ('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pathfinder = Jumper(map)
-- some code
-- calls the pathfinder, reconfigures it and requests a new path
local path,length = pathfinder:setAutoFilltrue)
				   :setHeuristic('EUCLIDIAN')
				   :setMode('ORTHOGONAL')
				   :getPath(1,1,3,3)
-- That's it!				   
```

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [the algorithm and the technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their [JavaScript port][] <br/>
* [Steve Donovan](https://github.com/stevedonovan) for the documentation generator [LDoc](https://github.com/stevedonovan/ldoc/).

##License##

This work is under [MIT-LICENSE][]<br/>
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

[Jump Point Search]: http://harablog.wordpress.com/2011/09/07/jump-point-search/
[Lua]: http://lua.org
[Löve]: https://love2d.org
[Löve2d]: https://love2d.org
[Löve 0.8.0 Framework]: https://love2d.org
[Dragon Age : Origins]: http://dragonage.bioware.com
[Moving AI]: http://movingai.com
[Nathan Witmer]: https://github.com/aniero
[XueXiao Xu]: https://github.com/qiao
[JavaScript port]: https://github.com/qiao/PathFinding.js
[Alban Grastien]: http://www.grastien.net/ban/
[Daniel Harabor]: http://users.cecs.anu.edu.au/~dharabor/home.html
[the algorithm and the technical papers]: http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
[MIT-LICENSE]: http://www.opensource.org/licenses/mit-license.php
[heuristics.lua]: https://github.com/Yonaba/Jumper/blob/master/Jumper/core/heuristics.lua