Jumper
======

__Jumper__ is a pathfinding library designed for __uniform-cost 2D grid-based__ games featuring [Jump Point Search][] algorithm.<br/>
It is __very__ fast, __lightweight__ and generates almost __no memory overhead while performing a search__.<br/>
As such, it might be an interesting option for __pathfinding computation on 2D maps__.<br/>
It also features a __clean public interface__ with __chaining features__ which makes it __very friendly and easy to use__.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in __any project__ embedding [Lua][] code.

<center><img src="http://ompldr.org/vZjltNQ" alt="" width="500" height="391" border="0" /></center>

##Installation
The current repository can be retrieved locally on your computer via:

###Bash
```bash
git clone git://github.com/Yonaba/Jumper.git --recursive
````

###Download
You can also download these files as an archive : [zip](https://github.com/Yonaba/Jumper/zipball/master) or [tarball](https://github.com/Yonaba/Jumper/tarball/master).<br/>
Therefore, in this case, you will to add manually all submodules ([30log](https://github.com/Yonaba/30log) and [Binary-Heaps](https://github.com/Yonaba/Binary-Heaps)).

##Examples of Use
Find several examples of use for __Jumper__, made with various Lua-based frameworks and game engines in this separated repository: [Jumper-Examples](https://github.com/Yonaba/Jumper-Examples)

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
	
**Note** : Some frameworks, like [Löve][] already includes  __.\init.lua__ in their <tt>package.path</tt>. In this case, you can just use :

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

__Note__: Lua array lists starts __indexing at 1__, by default. If you happened to use some dedicated *librairies/map designing tools* to export your collisions maps to Lua,
the resulting tables might __start indexing at 0__ or whatever else integer. This is fairly legit in Lua, but not common, though.
__Jumper__ will accomodate such maps without any problems.


###Initializing Jumper###
Once your collision map is set, you must specify what value in this collision map matches a __walkable__ tile. If you choose for instance *0* for *walkable tiles*, 
__any other value__ will be considered as *non walkable*.

```lua
local map = {
       {0,0,0},
       {0,2,0},
       {0,0,1},
    }
```

To initialize the pathfinder, you will have to pass __six values__ to Jumper.

```lua
local pather = Jumper(map,walkable,allowDiagonal,heuristicName,autoFill,postProcess)
```

Only the first argument is __required__, the __others__ left are __optional__.
* __map__ refers to the matrix representing the 2D world.
* __walkable__ refers to the value representing walkable tiles. Will be considered as __0__ if not given.
* __allowDiagonal__ is a boolean saying whether or not *diagonal moves* are allowed. Will be considered as __true__ if not given.
* __heuristicName__ is a predefined string constant representing the *distance heuristic function* to be used for path computation.
* __autoFill__ is a boolean to __enable or not__ for [automatic path filling](https://github.com/Yonaba/Jumper/#automatic-path-filling).
* __postProcess__ is a boolean to __enable or not__ [post processing for the internal grid](https://github.com/Yonaba/Jumper/#grid-processing).

###Distance heuristics###

*Jumper* features three (3) distance heuristics.

* MANHATTAN Distance : *|dx| + |dy|*
* EUCLIDIAN Distance : *sqrt(dx*dx + dy*dy)*
* DIAGONAL Distance : *max(|dx|, |dy|)*

By default, when you init  *Jumper*, __MANHATTAN__ will be used by default if 
no heuristic was specified.<br/>
If you want to use __another distance heuristic__, you will have to pass one of the following predefined strings:

```lua
"MANHATTAN" -- for MANHATTAN Distance
"EUCLIDIAN" -- for EUCLIDIAN Distance
"DIAGONAL" -- for DIAGONAL Distance
```

As an example :

```lua
local walkable = 0
local allowDiagonal = true
local Heuristics. = require 'Jumper.core.heuristics'
local Jumper = require('Jumper.init')
local pather = Jumper(map,walkable,allowDiagonal,'EUCLIDIAN')
```

You can __alternatively__ use <tt>pather:setHeuristic(Name)</tt>:

```lua
local walkable = 0
local allowDiagonal = true
local Jumper = require('Jumper.init')
local pather = Jumper(map,walkable,allowDiagonal)
pather:setHeuristic('EUCLIDIAN')
```

##Public interface##

###Pathfinder class interface

Once Jumper was loaded and initialized properly, you can now used one of the following methods listed below.<br/>
__Assuming <tt>pather</tt> represents an instance of <tt>Jumper</tt> class.__
	
#####pather:setHeuristic(NAME)
Will change the *distance heuristic* used.<br/>
__NAME__ must be passed as a string. Possible values are *MANHATTAN, EUCLIDIAN, DIAGONAL* (case-sensitive!).

* Argument __NAME__: *string*
* Returns: *nil*

#####pather:getHeuristic() 
Will return a reference to the *distance heuristic function* internally used.<br/>

* Argument: *nil*
* Returns: *function*

#####pather:setDiagonalMoves(Bool)
Argument must be a *boolean*. *True* will allow diagonal moves, *false* will allow *only straight-moves*.<br/>

* Argument __Bool__: *boolean*
* Returns: *nil*

#####pather:getDiagonalMoves()
Returns a *boolean* saying whether or not diagonal moves are allowed.

* Argument: *nil*
* Returns: *boolean*

#####pather:getGrid()
Returns a reference to the *internal grid* used by the pathfinder.
This grid is __not__ the map matrix given on initialization, but a __virtual representation__ used internally.

* Argument: *nil*
* Returns: *grid* (regular Lua table)

#####pather:getPath(startX,startY,endX,endY)
Main function, returns a path from location *[startX,startY]* to location*[endX,endY]* as an __ordered array__ of tables (*{x = ...,y = ...}*).<br/>
Otherwise returns *nil* if there is __no valid path__.<br/>
Also returns a __second value__ representing the __total cost of the move__ when a path was found.

* Argument __startX__: *integer*
* Argument __startY__: *integer*
* Argument __endX__: *integer*
* Argument __endY__: *integer*
* Returns: *path* (regular Lua table) or *nil*
* Returns: *cost* or *nil*

#####pather:fill(Path)
Polishes a path

* Argument __Path__: *path* (regular Lua table)
* Returns: *path* (regular Lua table)

#####pather:setAutoFill(bool)
Turns *on/off* the __autoFilling__ feature. When *on*, paths returned with <tt>pather:getPath()</tt> will always be automatically polished with <tt>pather:fill()</tt>

* Argument __bool__: *boolean*
* Returns: *nil*

#####pather:getAutoFill()
Returns the status of the __autoFilling__ feature

* Argument __bool__: *nil*
* Returns: *boolean*

###Grid class interface

<tt>pather:getGrid()</tt> returns a reference to the *internal grid* used by the pathfinder.
On this reference, you can use one of the following methods.<br/>
__Assuming *grid* holds the returned value from <tt>pather:getGrid()</tt>__

#####grid:getNodeAt(x,y)
Returns a reference to *node (X,Y)* on the grid.

* Argument __x__: *integer*
* Argument __y__: *integer*
* Returns: *node* (regular Lua table)

####grid:isWalkableAt(x,y)
Returns a boolean saying whether or not *node (X,Y)* __exists__ on the grid and __is walkable__.

* Argument __x__: *integer*
* Argument __y__: *integer*
* Returns: *boolean*

####grid:setWalkableAt(x,y,walkable)
Sets *node (X,Y)* __walkable or not__ depending on the boolean *walkable* given as argument:
__true__ makes the node walkable, while __false__ makes it unwalkable.

* Argument __x__: *integer*
* Argument __y__: *integer*
* Argument __walkable__: *boolean*
* Returns: *nil*

#####grid:getNeighbours(node,allowDiagonal)
Returns an array list of *nodes neighbouring node (X,Y)*. 
This list will include or not adjacent nodes regards to the boolean *allowDiagonal*.

* Argument __node__: *node* (regular Lua table)
* Argument __allowDiagonal__: *boolean*
* Returns: *neighbours* (regular Lua table)

##Grid processing
###Map access
When you init __Jumper__, passing it a 2D map (2-dimensional array), __Jumper__ keeps track of this map.<br/>
Therefore, you can access it via <tt>(pather:getGrid()).map</tt>

```lua
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}

local Jumper = require 'Jumper.init'
local pather = Jumper(map)
local internalGrid = pather:getGrid()
print(internalGrid.map == map) --> true
````

###Processing
Besides this, __Jumper__ creates an *internal grid* (which is also a 2D dimensional array) that will be used __later on__ to answer your pathfinding calls. This
internal array of nodes is accessible via <tt>pather:getGrid().nodes</tt>.<br/>
__When initializing Jumper__, the map passed as an argument is __pre-preprocessed by default__. It just means that __Jumper__ caches all nodes with respect to the map passed at first and create some internal data needed for pathfinding operations.
This will __faster__ a little further all pathfinding requests, but will __have a drawback in terms of memory consumed__.<br/>
*As an example, a __500 x 650__ sized map will consume around __55 Mb__ of memory right after initializing Jumper, when using the pre-preprocesed mode.*

You can __optionally__ choose to __post-process__ the grid, setting the relevant argument to <tt>true</tt> when initializing __Jumper__.

```lua
local Jumper = require 'Jumper.init'
local walkable = 0
local allowDiagonal = false
local heuristicName = 'MANHATTAN'
local autoFill = false
local postProcess = true
local pather = Jumper(map,walkable,allowDiagonal,heuristicName,autoFill,postProcess)
````

In this case, the internal grid will consume __0 kB (no memory) at initialization__. But later on, this is likely to grow, as __Jumper__ will create and keep caching new nodes __on demand__.
This *might be a better approach* if you are working with huge maps and running out of memory resources. But it *also* has a little inconvenience : 
pathfinding requests __will take a bit longer being anwsered__ (about 10-30 extra-milliseconds on huge maps).

Therefore, consider this a __tuning parameter__, and choose what suits the best.

##Handling paths##

###Using native <tt>pather:getPath()</tt>###

Using <tt>pather:getPath()</tt> will return a table representing a path from one node to another.<br/>
The path is stored in a table using the form given below:

```lua
path = {
          {x = 1,y = 1},
          {x = 2,y = 2},
          {x = 3,y = 3},
          ...
          {x = n,y = n},
        }
```

You will have to make your own use of this to __route your entities__ on the 2D map along this path.<br/>
Note that the path could contains some *holes* because of the algorithm used.<br/>
However, this __will not cause any issue__ as the move from one step to another along this path is __always straight__.<br/>
You can accomodate of this by yourself, or use the __path filling__ feature.

###Path filling###

__Jumper__ provides a __path filling__ feature that can be used to polish a path early computed, filling the holes it may contain.

```lua  
local walkable = 0
local allowDiagonal = true
local Jumper = require('Jumper.init')
-- Assuming map is defined
local pather = Jumper(map,walkable,allowDiagonal)
local path, length = pather:getPath(1,1,3,3)
-- Just pass the path to pather:fill().
pather:fill(path)
```

###Automatic path filling###
This feature will trigger the <tt>pather:fill()</tt> everytime <tt>pather:getPath()</tt> will be called.<br/>
Yet, it is very simple to use:

```lua  
local walkable = 0
local allowDiagonal = true
local Jumper = require('Jumper.init')
-- Assuming map is defined
local pather = Jumper(map,walkable,allowDiagonal)
pather:setAutoFill(true)
local path, length = pather:getPath(1,1,3,3)
-- No need to use path:fill() now !
```

##Chaining##
All setters can be chained.<br/>
This is convenient if you need to __reconfigure__ the pather instance in a __quick and elegant manner__.

```lua 
local Jumper = require ('Jumper.init')
-- Assuming map is defined
local pather = Jumper(map,0)
-- some code
-- calling the pather, reconfiguring it and yielding a new path
local path,length = pather:setAutoFilltrue)
				   :setHeuristic('EUCLIDIAN')
				   :setDiagonalMoves(true)
				   :getPath(1,1,4,3)
-- That's it!				   
```

##Object-orientation
__Jumper__ uses [30log][] as a lightweight *object-orientation* framework.<br/>
*When loading* Jumper, the path to this third-party library is automatically added, so that you can *require* this third-party very easily if you need it.


```lua
local Jumper = require 'Jumper.init'
local Class = require '30log'
```

##Participating Libraries##

* [30log][]
* [Binary heaps][]

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for the JavaScript [port][] or Jump Point Search.<br/>

##License##

This work is under [MIT-LICENSE][]<br/>
Copyright (c) 2012 Roland Yonaba

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
[30log]: http://yonaba.github.com/30log
[Lua]: http://lua.org
[Binary heaps]: http://yonaba.github.com/Binary-Heaps/
[Löve]: https://love2d.org
[Löve 0.8.0 Framework]: https://love2d.org
[Dragon Age : Origins]: http://dragonage.bioware.com
[Moving AI]: http://movingai.com
[Nathan Witmer]: https://github.com/aniero
[XueXiao Xu]: https://github.com/qiao
[port]: https://github.com/qiao/PathFinding.js
[Alban Grastien]: http://www.grastien.net/ban/
[Daniel Harabor]: http://users.cecs.anu.edu.au/~dharabor/home.html
[technical papers]: http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
[MIT-LICENSE]: http://www.opensource.org/licenses/mit-license.php
[heuristics.lua]: https://github.com/Yonaba/Jumper/blob/master/Jumper/core/heuristics.lua