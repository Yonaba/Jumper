#Version history#

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
			
