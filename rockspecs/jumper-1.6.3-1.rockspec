package = "jumper"
version = "1.6.3-1"
source = {
   url = "https://github.com/Yonaba/Jumper/archive/jumper-1.6.3-1.tar.gz",
   dir = "Jumper-jumper-1.6.3-1"
}
description = {
   summary = "Fast and easy-to-use pathfinding library for 2D grid-bases games",
   detailed = [[
      Jumper is a pathfinding library designed for uniform-cost 2D grid-based games. It features a mix of A-Star, Jump Point Search
	  and Binary-Heaps. It aims to be fast and lightweight. It also features a clean public interface with chaining features 
	  which makes it very friendly and easy to use.
   ]],
   homepage = "http://github.com/Yonaba/Jumper",
   license = "MIT <http://www.opensource.org/licenses/mit-license.php>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["init"] = "init.lua",
    ["jumper"] = "jumper.lua",
    ["core.bheap"] = "core/bheap.lua",
    ["core.grid"] = "core/grid.lua",
    ["core.heuristics"] = "core/heuristics.lua",
    ["core.node"] = "core/node.lua"
  }
}