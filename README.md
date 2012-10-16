Jumper
======

__Jumper__ is a pathfinding library designed for __uniform-cost 2D grid-based__ games featuring [Jump Point Search][] algorithm.<br/>
It is __very__ fast, __lightweight__ and generates almost __no memory overhead while performing a search__.<br/>
As such, it might be an interesting option for __pathfinding computation on 2D maps__.<br/>
It also features a __clean public interface__ with __chaining features__ which makes it __very friendly and easy to use__.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in __any project__ embedding [Lua][] code.

<center><img src="http://ompldr.org/vZjltNQ" alt="" width="500" height="391" border="0" /></center>

##Installation
The current repository can be retrieved locally on your computer running one of the following bash scripts:

###Bash
```bash
git clone git://github.com/Yonaba/Jumper.git --recursive
````

###Download
You may also download these files as an archive : [zip](https://github.com/Yonaba/Jumper/zipball/master) or [tarball](https://github.com/Yonaba/Jumper/tarball/master)

##Examples of Use
Find several examples of use for __Jumper__, made with various Lua-based frameworks and game engines in this separated repository: [Jumper-Examples](https://github.com/Yonaba/Jumper-Examples)

##Usage##
###Calling Jumper###
Clone the repository in a folder named __Jumper__ inside your projet. Use *require* function to call the library.

```lua
local Jumper = require('Jumper.init')
```

**Note** :  You can add __.init.lua__ in your <tt>package path</tt>. As a result, requiring __Jumper__ will become easier.

```lua
package.path = package.path .. ';.\\?\\init.lua'
local Jumper = require ('Jumper')
```
	
**Note** : Some frameworks, like [Löve][] already includes  __.\init.lua__ in their <tt>package.path</tt>. In this case, just use :

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

__Note__: Lua tables starts __indexing at 1__, by default. If you happened to use some dedicated librairies/map designing tools to export your collisions maps to Lua,
the resulting tables might __start indexing at 0__. This is fairly legit in Lua, but not common, though.
__Jumper__ will accomodate such maps without any problems.

###Initializing Jumper###
Now you must now setup a 2D matrix of __integers__ or __strings__ representing your world. Values stored in this matrix
should represent whether or not a cell on the matrix is walkable or not.  If you choose for instance *0* for walkable tiles, 
__any other value__ will be considered as non walkable.

```lua
local map = {
       {0,0,0},
       {0,2,0},
       {0,0,1},
    }
```

To initialize the pathfinder, you will have to pass __five values__. 

```lua
local walkable = 0
local allowDiagonal = true
local pather = Jumper(map,walkable,allowDiagonal,heuristicName,autoFill)
```

Only the first argument is __required__, the __others__ left are __optional__.
* __map__ refers to the matrix representing the 2D world.
* __walkable__ refers to the value representing walkable tiles. Will be considered as *0* if not given.
* __allowDiagonal__ is a boolean saying whether or not diagonal moves are allowed. Will be considered as __true__ if not given.
* __heuristicName__ is a predefined string constant representing the heuristic function to be used for path computation.
* __autoFill__ is a feature for [automatic path filling](https://github.com/Yonaba/Jumper/#automatic-path-filling).

##Distance heuristics##

*Jumper* features 3 types of distance heuristics.

* MANHATTAN Distance : <em>|dx| + |dy|</em>
* EUCLIDIAN Distance : <em>sqrt(dx*dx + dy*dy)</em>
* DIAGONAL Distance : <em>max(|dx|, |dy|)</em>

Each of these distance heuristics are packed inside Jumper's core. By default, when initializing  *Jumper*, __MANHATTAN__ Distance is used if 
no heuristic was specified.<br/>
If you need to use __another distance heuristic__, you will have to pass one of the following predefined strings:

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

You can __alternatively__ use *setHeuristic(Name)* :

```lua
local walkable = 0
local allowDiagonal = true
local Jumper = require('Jumper.init')
local pather = Jumper(map,walkable,allowDiagonal)
pather:setheuristic('EUCLIDIAN')
```

##API##

###Main Pathfinder Class API

Once loaded and initialized properly, you can now used one of the following methods listed below.<br/>
__Assuming *pather* represents an instance of *Jumper* class.__
	
####pather:setHeuristic(NAME)
Will change the heuristic to be used.<br/>
__NAME__ must be passed as a string.<br/>
Possible values are __"MANHATTAN"__,__"EUCLIDIAN"__,__"DIAGONAL"__ (case-sensitive!).
* __Argument NAME__: a string
* __Returns:__ Nothing

####pather:getHeuristic() 
Will return a reference to the __heuristic function__ internally used.<br/>
* __Argument__: Nothing
* __Returns:__ a function

####pather:setDiagonalMoves(Bool)
Argument must be a boolean. __true__ will authorize __diagonal moves__, __false__ will allow __only straight-moves__.<br/>
* __Argument Bool__: a boolean
* __Returns:__ Nothing

####pather:getDiagonalMoves()
Returns __a boolean__ saying whether or not diagonal moves are allowed.
* __Argument__: Nothing
* __Returns:__ a boolean

####pather:getGrid()
Returns a reference to the __internal grid__ used by the pathfinder.
This grid is __not__ the map matrix given on initialization, but a __virtual representation__ used internally.
* __Argument__: Nothing
* __Returns:__ a grid (regular Lua table)

####pather:getPath(startX,startY,endX,endY)
Main function, returns a path from [startX,startY] to [endX,endY] as an __ordered array__ of locations ({x = ...,y = ...}).
Otherwise returns __nil__ if there is __no valid path__.
Also returns a __second value__ representing __total cost of the move__ if a path was found.
* __Argument startX__: The X coordinate of the starting node (positive non zero integer)
* __Argument startY__: The Y coordinate of the starting node (positive non zero integer)
* __Argument endX__: The X coordinate of the goal node (positive non zero integer)
* __Argument endY__: The Y coordinate of the goal node (positive non zero integer)
* __Returns:__ a path (regular Lua table) or nil
* __Returns:__ the path cost (positive number) or nil

####pather:fill(Path)
Polishes a path
* __Argument Path__: a path (regular Lua table)
* __Returns:__ a path (regular Lua table)

####pather:setAutoFill(bool)
Turns on/off the __AutoFill__ feature. When on, paths returned with <tt>pather:getPath()</tt> will always be automatically polished.
* __Argument bool__: a boolean
* __Returns:__ Nothing

####pather:getAutoFill()
Returns the status of the __AutoFill__ feature
* __Argument bool__: Nothing
* __Returns:__ a boolean

###Grid Class API

Using *getGrid()* returns a reference to the internal grid used by the pathfinder.
On this reference, you can use one of the following methods.<br/>
__Assuming *grid* holds the return value from *pather:getGrid()*__

####grid:getNodeAt(x,y)
Returns a reference to the node (X,Y) on the grid.

* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Returns:__ a node (regular Lua table)

####grid:isWalkableAt(x,y)
Returns a boolean saying whether or not the node (X,Y) __exists on the grid and is walkable__.
* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Returns:__ a boolean

####grid:setWalkableAt(x,y,boolean)
Sets the node (X,Y) __walkable or not__ depending on the boolean given.
__true__ makes the node walkable, while __false__ makes it unwalkable.
* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Argument boolean__: a boolean
* __Returns:__ Nothing

####grid:getNeighbours(node,allowDiagonal)
Returns an array list of nodes __neighbouring location (X,Y)__.
The list will include or not adjacent nodes regards to the boolean __allowDiagonal__.
* __Argument node__: a node (regular Lua table)
* __Argument allowDiagonal__: a boolean
* __Returns:__ list of neighbours (regular Lua table)

##Handling paths##

###Using native *getPath()* method###

Using *getPath()* will return a table representing a path from one node to another.<br/>
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
However, this should not cause a serious issue as the move from one step to another along the path is always straight.
You can accomodate of this by yourself, or use the __path filling__ feature.

###Path filling###

__Jumper__ provides a __path filling__ feature that can be used to polish a path early computed, filling the holes it may contain.
As it directly alters the path given, both of these syntax works:

```lua
local walkable = 0
local allowDiagonal = true
local Jumper = require('Jumper.init')
-- Assuming map is defined
local pather = Jumper(map,walkable,allowDiagonal)
local path, length = pather:getPath(1,1,3,3)
-- Capturing the returned value
path = pather:fill(path)
```

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
This feature will trigger <tt>pather:fill()</tt> everytime <tt>pather:getPath()</tt> will be called.<br/>
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
__Jumper's__ setters can be chained.<br/>
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
__Jumper__ uses [30log][] a light-weight object-orientation framework.<br/>
*When loading* Jumper, the path to this third-party library is automatically added to Lua's <tt>package.path</tt>.
So that you can *require* it very easily.

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