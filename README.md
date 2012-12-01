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

###Download
You can also download these files as an archive : [zip](https://github.com/Yonaba/Jumper/zipball/master) or [tarball](https://github.com/Yonaba/Jumper/tarball/master).<br/>

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
	
**Note** : Some frameworks, like [Löve2d][] already have  this feature. Using them, you can just write :

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


###Initializing Jumper###
Once your collision map is set, you must specify what value in this collision map matches a __walkable__ tile. If you choose for instance *0* for *walkable tiles*, 
__any other value__ will be considered as *non walkable*.<br/>

To initialize the pathfinder, you will have to pass __three arguments__ to Jumper.

```lua
local pather = Jumper(map,walkable,postProcess)
```

Only the first argument is __mandatory__. The __two others__ left are __optional__.
* __map__ refers to the collision map representing the 2D world.
* __walkable__ (optional) refers to the value representing walkable tiles. Will be considered as __0__ if not given.
* __postProcess__ (optional) is a boolean to __enable or not__ [post processing for the internal grid](https://github.com/Yonaba/Jumper/#grid-processing).

###Distance heuristics###

####Built-in heuristics
*Jumper* features four (3) distance heuristics.

* MANHATTAN distance : *|dx| + |dy|*
* EUCLIDIAN distance : *sqrt(dx*dx + dy*dy)*
* DIAGONAL distance : *max(|dx|, |dy|)*
* CARDINAL/INTERCARDINAL distance: *min(|dx|,|dy|)* sqrt(2) + max(|dx|,|dy|) - min(|dx|,|dy|)*

By default, when you init  *Jumper*, __MANHATTAN__ will be used.<br/>
If you want to use __another distance heuristic__, you will have to pass one of the following predefined strings to <tt>pather:setHeuristic(Name)</tt>:

```lua
"MANHATTAN" -- for MANHATTAN Distance
"EUCLIDIAN" -- for EUCLIDIAN Distance
"DIAGONAL" -- for DIAGONAL Distance
"CARDINTCARD" -- for CARDINAL/INTERCARDINAL Distance
```

As an example :

```lua
local Jumper = require('Jumper.init')
local pather = Jumper(map)
pather:setHeuristic('CARDINTCARD')
```

####Custom heuristics
You can also use __your own heuristic__ to perform pathfinding. This custom heuristic should be passed to <tt>pather:setHeuristic(Name)</tt> as a function 
prototyped for two parameters, to be *dx* and *dy* (being respecitvely the distance *in tile units* from a location to the target on x and y axis).<br/>
__Note__: When writing *your own heuristic*, take into account that values passed as *dx* and *dy* __are not absolute values, they can be negative__.

As an example:

```lua
local function distance(dx, dy)
  return (dx + 1.4 * dy)
end
local Jumper = require('Jumper.init')
local pather = Jumper(map)
pather:setHeuristic(distance)
````

##Public interface##
###Pathfinder class interface

Once Jumper was loaded and initialized properly, you can now used one of the following methods listed below.<br/>
__Assuming <tt>pather</tt> represents an instance of <tt>Jumper</tt> class.__
	
#####pather:setHeuristic(NAME)
Will change the *distance heuristic* used.<br/>
__NAME__ must be passed as a string or a custom function. Possible string values are *MANHATTAN, EUCLIDIAN, DIAGONAL, CARDINTCARD* (case-sensitive!).<br/>
By default, *MANHATTAN* is the value being used by the pathfinder.
* Argument __NAME__: *string* or *function*
* Returns: *self*

#####pather:getHeuristic() 
Will return a reference to the *distance heuristic function* internally used.<br/>

* Argument: *nil*
* Returns: *function*

#####pather:setMode(searchMode)
Argument must be a *string*. Possible values are *DIAGONAL* to allow __8-directions moves__ or *ORTHOGONAL* to allow only __4-directions moves__ (case-sensitive!)<br/>
By default *DIAGONAL* is the value being used by the pathfinder.

* Argument __searchMode__: the search mode.
* Returns: *self*

#####pather:getMode()
Returns a *string* representing the search mode currently used.

* Argument: *nil*
* Returns: *string*

#####pather:getGrid()
Returns a reference to the *internal grid* used by the pathfinder.
This grid is __not__ the collision map given on initialization, but a __virtual representation__ used internally.

* Argument: *nil*
* Returns: *grid* (regular Lua table)

#####pather:getPath(startX,startY,endX,endY)
Main function, returns a path from location *[startX,startY]* to location *[endX,endY]* as an __ordered array__ of tables (*{x = ...,y = ...}*).<br/>
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
Turns *on/off* the __autoFilling__ feature. When *on*, paths returned with <tt>pather:getPath()</tt> will always be automatically polished with <tt>pather:fill()</tt>.
By default, this feature is not enabled.
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
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local walkable = 0
local postProcess = true
local pather = Jumper(map,walkable,postProcess)
````

In this case, the internal grid will consume __0 kB (no memory) at initialization__. But later on, this is likely to grow, as __Jumper__ will automatically create and keep caching new nodes __on demand__.
This *might be a better approach* if you are facing to tight constraints in terms of available memory, working with huge maps. But it *also* has a little inconvenience : 
pathfinding requests __will take a bit longer__ (about 10-30 extra-milliseconds on huge maps).<br/>
Therefore, consider this a __tuning parameter__, and choose what suits the best to your needs.

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
However, this __will not cause any issue__ as a move from one step to another along this path is __always straight__.<br/>
You can accomodate of this by yourself, or use the __path filling__ feature.

###Path filling###

__Jumper__ provides a __path filling__ feature that can be used to polish a path early computed, filling the holes it may contain.

```lua
local Jumper = require('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pather = Jumper(map)
local path, length = pather:getPath(1,1,3,3)
-- Just pass the path to pather:fill().
pather:fill(path)
```

###Automatic path filling###
This feature will trigger the <tt>pather:fill()</tt> everytime <tt>pather:getPath()</tt> will be called.<br/>

```lua  
local Jumper = require('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pather = Jumper(map)
pather:setAutoFill(true)
local path, length = pather:getPath(1,1,3,3)
-- No need to use path:fill() now !
```

##Chaining##
All setters can be chained.<br/>
This is convenient if you need to __quickly reconfigure__ the pathfinder instance__.

```lua 
local Jumper = require ('Jumper.init')
local map = {
  {0,0,0},
  {0,0,0},
  {0,0,0},
}
local pather = Jumper(map)
-- some code
-- calls the pather, reconfigures it and requests a new path
local path,length = pather:setAutoFilltrue)
				   :setHeuristic('EUCLIDIAN')
				   :setMode('ORTHOGONAL')
				   :getPath(1,1,3,3)
-- That's it!				   
```

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [the algorithm and the technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their [JavaScript port][] <br/>

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