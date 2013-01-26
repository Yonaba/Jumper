#Version history#

##1.8.0 (01/26/2013)
* Moved the internal `Grid` module at the top level
* Separated path handling logic from the pathfinder class
* Added a new `Path` class
* Moved <tt>Pathfinder:filter</tt> and <tt>Pathfinder:fill</tt> to <tt>Path:filter</tt> and <tt>Path:fill</tt> 
* Changed <tt>Pathfinder:new</tt> args, to handle the explicit choice of a finder.
* Added <tt>Pathfinder:setGrid</tt> 
* Added <tt>Pathfinder:getGrid</tt> 
* Added <tt>Pathfinder:setWalkable</tt> 
* Added <tt>Pathfinder:getWalkable</tt>
* Changed <tt>Grid:isWalkableAt</tt> to handle a third-parameter for node walkability testing
* Added <tt>Grid:getWidth</tt>
* Added <tt>Grid:getHeight</tt>
* Added <tt>Grid:getMap</tt>
* Added <tt>Grid:getNodes</tt>
* Added <tt>Grid:getNodes</tt>
* Added <tt>Path:getLength</tt> for the `Path` class, for path length self-evaluation, as it fails with finders not handling heuristics.
* Added Dijkstra algorithm
* Added Breadth-First search algorithm
* Added Depth-First search algorithm
* Updated README and documentation

##1.7.0 (01/22/13)
* Added Astar search algorithm, along with Jump Point Search
* Implemented a common interface for the <tt>Pathfinder</tt> object
* Added argument type checking on pathfinder initialization
* Added <tt>Pathfinder:setFinder</tt>
* Added <tt>Pathfinder:getFinder</tt>
* Added <tt>Pathfinder:getFinders</tt>
* Added <tt>Pathfinder:getHeuristics</tt>
* Added <tt>Pathfinder:getModes</tt>
* Added <tt>Pathfinder:filter</tt> for path compression
* Removed <tt>autoFill</tt> feature (<tt>setAutoFill</tt>, <tt>getAutoFill</tt>)
* Faster heapify method in binary heaps module
* Updated docs, README, rockspecs

## 1.6.3 (01/19/13)
* Added <tt>Grid:iter</tt>
* Added <tt>Grid:each</tt>
* Added <tt>Grid:eachRange</tt>
* Added <tt>Grid:imap</tt>
* Added <tt>Grid:imapRange</tt>
* Added <tt>Grid:__call</tt>
* Added <tt>Pathfinder:version</tt>
* Added path iterator
* Improved node passability handling
* Added support for string maps
* Various code improvements
* Hardcoded documentation, generation with LDoc
* Updated README, rockspecs

## 1.6.2 (12/01/12)
* Third-party lib 30log replaced by an hardocded class system
* Third-party lib binary-heaps replaced by a lighter implementation
* Changed initialization pattern : three-args are needed, only the first one is mandatory.
* Added support for custom heuristics
* Removed <tt>getDiagonalMoves()</tt> and <tt>setDiagonalMoves()</tt>, replaced by <tt>getMode()</tt> and <tt>setMode()</tt>
* Internal improvements, reuse data.
* Updated Readme

## 1.6.1 (11/22/12)
* Added Cardinal/Intercardinal heuristic

## 1.6.0 (11/05/12)
* Added specialized grids : preprocessed/postprocessed grids
* Nodes walkability is no longer stored as an attribute, but computed on the fly with respect to the map passed to init Jumper

##1.5.2.2 (11/02/12)
* Bugfix on resetting nodes properties (Thanks to Srdjan Marković)
* Bugfix on path cost return

##1.5.2.1 (10/27/12)
* Bugfix (Thanks to Srdjan Marković)

##1.5.2 (10/25/12)
* Fixed "tunneling" issue in diagonal-mode

##1.5.1.3 (10/18/12)
* Third-party 30log requiring enhanced
* Huge documentation update (See Readme)

##1.5.1.2 (10/17/12) - Fix 
* Bugfix with the previous commit (requiring third-party would not work with L�ve2D, now fixed)

##1.5.1.2 (10/16/12)
* Fix on internal grid width calculation
* Added path to 30log in package.path
* Some code cleaning


##1.5.1.1 (10/15/12)
* Smoothing renamed to filling, self-explanatory (See Readme for public interface changes)

##1.5.1 (10/09/12)
* Fix for pathfinding with no diagonal moves allowed : paths returned looks more "natural".

##1.5.0 (10/06/12)
* Added support for collision maps starting at locations different than (1,1).
* Heuristic name CHEBYSHEV was removed, now on will use DIAGONAL instead.
* Changes in Jumper's initialization arguments
* Various improvements
* Updated Readme

##1.4.1 (10/04/12)
* Third-parties are now git submodules.
* Bugfix with grid reset process
* Optimized the grid reset process. Successive calls to <tt>pather:getPath()</tt> yield faster.
* Removed <tt>grid:reset()</tt>

##1.3.3 (10/01/12)
* Removed useless lines of code

##1.3.2 (09/26/12)
* Compatibility issue with Gideros : Jumper couldn't be required, due to the way Gideros run projects.
* Updated Readme

##1.3.1 (09/25/12)
* Jumper no longer uses internally Lua's <tt>module</tt> function.
* Global env pollution bugfix

##1.3 (09/25/12)
* added autoSmooth feature : returned paths can now be automatically smoothered on return
* <tt>searchPath</tt> renamed to <tt>getPath</tt>
* Added chaining
* Slight enhancements in code, making profit of Lua's multiple return values ability
* Updated Readme
* Updated demos

##1.2 (08/28/12)
* Jumper now uses [30log](http://github.com/Yonaba/30log) as its object orientation library
* Global env pollution when requiring jumper now fixed (See init.lua)
* Updated Readme

##1.1.1 (08/27/12)
* Third party updated (Binary_Heaps v1.5)
* Code cleaning, Fixed indentation

##1.1 (08/01/12)
* Updated with third-party (with Binary_Heaps ported to 1.4)

##1.0 (06/14/12)
* Added Path smoother
* Better handling of straight moves
* Code cleaning

##0.3 (06/01/12)
* Bugfix with internal paths calls to third-parties.

##0.2 (05/28/12)
* Updated third-party libraries (Lua Class System, Binary Heaps)
* Added version_history.md

##0.1 (05/26/12)
* Initial release
			
