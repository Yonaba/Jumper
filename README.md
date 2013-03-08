Jumper
======

This is a modified version of the library pathfinding Jumper. 
The current changes manages the pathfinding of multiple agents with straw spreading behavior in the paths returned.
This allows more realistic movement for grouped units, avoiding  them to stack along the same path.

I wrote it upon a request of a user of Jumper.
Find more details on this very post on [Corona forums thread](http://developer.coronalabs.com/code/jumper-fast-2d-pathfinder-grid-based-games?page=1#comment-144584).

##Implementation notes
The solution I came up with might not be the best. Simulating a "spread-like" behaviour with multiple agents pathing at the same time was easily doable with the way 
Jumper was implemented.<br/>
Let's condider that pathfinding is all about *finding the minimum-cost route to a given goal, from a given starting point*.
On the top of that, we use some heuristic functions to estimate the distance to the goal, and from the starting point at each step of search, 
so that we won't spend time looking in the wrong direction.<br/>
When multiple agents are asked to move to a given location from the same starting point, 
they tend to line-up along the same exact path, and that's fairly normal.
To avoid that "odd", when calculating a first path (for the first unit), we can artificially *add some penalty* (like an extra weight) to each single node (tiles) that lies along 
this path, so that on the next (the second, third, fourth,...n-th) path request, the pathfinder will look for alternatives routes, avoiding nodes (or tiles) being crossed 
by the previous paths.

The current version of Jumper implements such behaviour, yet it remains very simple to use.
You will just have to implement a field `onPathFound` in the finder __as a function__ that will be called internally right after a path was found.
That function __must take a path as a single argument__, and is supposed to increase the `weight` property of each single node along the passed-in path.

```lua
local Grid = require 'jumper.grid'
local PF = require 'jumper.pathfinder'

local map = {...}    -- placeholder!
local walkable = ... -- placeholder!

local grid = Grid(map) -- Assumap a 2d map array was defined
local myFinder = PF(grid, 'ASTAR', walkable) -- Assuming walkable was earlier defined

function myFinder.onPathFound(path)
	for node in path:nodes() do
		node.weight = node.weight + 1
	end
end
````

You can now use the `finder:getPath` function for a group of agents.
In the case units have the same destination (and neighbouring starting locations in the worst case), the finder will try (at best) to return distincts optimal paths
so that the whole set of units will no longer stack along the same line.

```lua
for i = 1, n_agents do
	local agent = agents[i]
  local path = agents[i]myFinder:getPath(agent.startx, agent.starty, agent.destx, agent.desty)
end
````

Right after, it is very important to reset each node `weight` property back to __zero__. 
This can be actually accomplished very easily using `grid:each` iterator.

```lua
grid:each(function(node) 
	node.weight = 0 
end)
````

In case the grid is really huge, one can save some time only keeping track of all nodes involved 
in the set of paths returned and then clear their `weight` property.

See [this example](https://github.com/Yonaba/Jumper/blob/node-weight/multi-agents-example.lua) for more details.

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