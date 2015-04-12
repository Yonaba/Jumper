Jumper
======

[![Join the chat at https://gitter.im/Yonaba/Jumper](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Yonaba/Jumper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://secure.travis-ci.org/Yonaba/Jumper.png)](http://travis-ci.org/Yonaba/Jumper)

__Jumper__ is a pathfinding library designed for grid-based games. It aims to be __fast__ and __lightweight__.
It features a wide range of search algorithms, built within a clean interface with 
chaining features which makes it __very friendly and easy to use__.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in any project embedding [Lua][] code.

##Installation
The current repository can be retrieved locally on your computer via:

###Bash
```bash
git clone git://github.com/Yonaba/Jumper.git
````

###Download (latest)
* __Development version__: [zip](http://github.com/Yonaba/Jumper/zipball/master) | [tar.gz](http://github.com/Yonaba/Jumper/tarball/master) ( __please do not use this!__ )
* __Latest stable release (1.8.1)__: [zip](http://github.com/Yonaba/Jumper/archive/jumper-1.8.1-1.zip) | [tar.gz](http://github.com/Yonaba/Jumper/archive/jumper-1.8.1-1.tar.gz) ( __Recommended!__ )
* __All stable releases__: [tags](http://github.com/Yonaba/Jumper/tags)


###LuaRocks
```bash
luarocks install jumper
````

###MoonRocks
```bash
luarocks install --server=http://rocks.moonscript.org/manifests/Yonaba jumper
````

##Installing Jumper##
Copy the contents of the folder named [jumper](http://github.com/Yonaba/Jumper/blob/master/jumper) and its contents and place it inside your projet. Use *require* function to import any module of the library.

##A Simple Example of Use
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
local path = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(path:getLength()))
	for node, count in path:nodes() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
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

##Specs
Specs tests have been included.<br/>
You can run them using [Telescope](http://github.com/norman/telescope) with the following command 
from the [root](http://github.com/Yonaba/Jumper/blob/master/jumper) folder:

```
tsc -f specs/*
```

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for the [Jump Point Search](http://harablog.wordpress.com/2011/09/07/jump-point-search/) algorithm.<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for the [JavaScript port][] of the algorithm.<br/>
* [Steve Donovan](http://github.com/stevedonovan): for the awesome documentation generator tool [LDoc](http://github.com/stevedonovan/ldoc/).
* [Srdjan Markovic](http://github.com/srdjan-m), for his tremendous feedback.

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
[L�ve]: http://love2d.org
[L�ve2d]: http://love2d.org
[L�ve 0.8.0 Framework]: http://love2d.org
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

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Yonaba/jumper/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/5165385288dcb27776c96dce1a82e33d "githalytics.com")](http://githalytics.com/Yonaba/Jumper)
