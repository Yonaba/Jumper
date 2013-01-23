package = "jumper"
version = "1.7.0-1"
source = {
   url = "https://github.com/Yonaba/Jumper/archive/jumper-1.7.0-1.tar.gz",
   dir = "Jumper-jumper-1.7.0-1"
}
description = {
   summary = "Fast and easy-to-use pathfinding library for 2D grid-based games",
   detailed = [[
      Jumper is a pathfinding library designed for 2D grid-based games.
      It aims to be fast and lightweight. It also features a clean public interface with chaining features 
      which makes it very friendly and easy to use.
   ]],
   homepage = "http://github.com/Yonaba/Jumper",
   license = "MIT <http://www.opensource.org/licenses/mit-license.php>",
   maintainer = "Roland Yonaba <roland.yonaba@gmail.com>",
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["jumper.init"] = "jumper/init.lua",
      ["jumper.pathfinder"] = "jumper/pathfinder.lua",
      ["jumper.core.bheap"] = "jumper/core/bheap.lua",
      ["jumper.core.grid"] = "jumper/core/grid.lua",
      ["jumper.core.heuristics"] = "jumper/core/heuristics.lua",
      ["jumper.core.node"] = "jumper/core/node.lua",
      ["jumper.search.astar"] = "jumper/search/astar.lua",
      ["jumper.search.jps"] = "jumper/search/jps.lua",
   },
   copy_directories = {"docs"}
}
