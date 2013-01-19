--- <strong>The init hook file</strong>.
-- The default way to import Jumper in your project is the following:
-- <ul>
-- <pre class="example">
-- local Jumper = require (&quot;Jumper.init&quot;)
-- </pre></ul>
--
-- The call to `init.lua` was meant for package self-containment purposes. 
-- On some Lua distributions, the package of modules contains the pattern `init.lua`.
-- In this case, to import the library in your project, you can just write the following:
-- <ul>
-- <pre class="example">
-- local Jumper = require (&quot;Jumper&quot;)
-- </pre></ul>
--
-- Optionnally, you can also add the pattern `init.lua` in your package of modules. 
-- Therefore, the syntax can be shortened:
-- <ul>
-- <pre class="example">
-- package.path = package.path .. (&quot;;.\\\?\\\init.lua&quot;)
-- local Jumper = require (&quot;Jumper&quot;)
-- </pre></ul>
--
-- @author Roland Yonaba
-- @copyright 2012-2013
-- @license <a href="http://www.opensource.org/licenses/mit-license.php">MIT</a>
-- @script init



if (...) then
  local _path = (...):gsub('%.init$', '')
  return require(_path..'.jumper')
end

--[[
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
--]]