30log
=====

__30log__, in extenso *30 Lines Of Goodness* is a minified library for [pseudo object-orientation](http://lua-users.org/wiki/ObjectOrientedProgramming) in Lua.
It features __class creation__, __object instantiation__, __class inheritance__ and __method overload__ through inheritance.<br/>
And yes, it makes __30 lignes__ length. No less, no more.

##Installation
Copy the file [30log.lua](https://github.com/Yonaba/30log/blob/master/Lib/30log.lua) inside your project folder, call it using [require](http://pgl.yoyo.org/luai/i/require) function.<br/>
When loaded, __30log__ returns its main function .

##Quicktour
###Creating a class
Making a new class is fairly simple. Just call the returned function, then add some properties to this class :

```lua
class = require '30log'
Window = class ()
Window.x, Window.y = 10, 10
Window.width, Window.height = 100,100
```

You can also shortcut it, passing the default properties as a table to <tt>class</tt> :

```lua
class = require '30log'
Window = class { width = 100, height = 100, x = 10, y = 10}
```

###Instances

Once a class is set, you can easily create new __instances__ from the class.

```lua
appFrame = Window:new()
print(appFrame.x,appFrame.y) --> 10, 10
print(appFrame.width,appFrame.height) --> 100, 100
```

You can also use a shortcut, calling the class __as a function__ :

```lua
appFrame = Window()
print(appFrame.x,appFrame.y) --> 10, 10
print(appFrame.width,appFrame.height) --> 100, 100
```

From the two examples above, you might have noticed that once an instance is created from a class, its properties takes __by default__ the class properties.
But, you can init objects from a class with your own specific properties. To accomplish that, you must have implemented a method named <tt>**__init**</tt> inside the base class.<br/>
In a nutshell, <tt>**__init**</tt> is the __default method__ to be used as a __class constructor__.

```lua
Window = class { width = 100, height = 100, x = 10, y = 10}
function Window:__init(x,y,width,height)
  self.x,self.y = x,y
  self.width,self.height = width,height
end

appFrame = Window:new(50,60,800,600)
   -- or appFrame = Window(50,60,800,600)
print(appFrame.x,appFrame.y) --> 50, 60
print(appFrame.width,appFrame.height) --> 800, 600
```

###Methods
__Methods__ are supported. Obviously.

```lua
Window = class { width = 100, height = 100, w = 10, y = 10}
function Window:__init(x,y,width,height)
  self.x,self.y = x,y
  self.width,self.height = width,height
end

function Window:set(x,y)
  self.x, self.y = x, y
end

function Window:resize(width, height)
  self.width, self.height = width, height
end

appFrame = Window()
appFrame:set(50,60)
print(appFrame.x,appFrame.y) --> 50, 60
appFrame:resize(800,600)
print(appFrame.width,appFrame.height) --> 800, 600
```

###Inheritance
A class can __derive__ from a base class using a default method named <tt>:extends</tt>.
The new class will inherit his mother class default __members__ and __methods__.

```lua
Window = class { width = 100, height = 100, x = 10, y = 10}
Frame = Window:extends { color = 'black' }
print(Frame.x, Frame.y) --> 10, 10

appFrame = Frame()
print(appFrame.x,appFrame.y) --> 10, 10
```

A derived class can __overload any method__ defined in its base class (or mother class). Therefore, the derived class still has access to his mother class methods via a special key named <tt>super</tt>.<br/>
Let's use this feature to build a class constructor for our <tt>Frame</tt> class.

```lua
-- The base class "Window"
Window = class { width = 100, height = 100, x = 10, y = 10}
function Window:__init(x,y,width,height)
  self.x,self.y = x,y
  self.width,self.height = width,height
end

function Window:set(x,y)
  self.x, self.y = x, y
end

-- A derived class named "Frame"
Frame = Window:extends { color = 'black' }
function Frame:__init(x,y,width,height,color)
  -- Calling the superclass constructor
  self.super.__init(self,x,y,width,height)
  -- Setting the extra class member
  self.color = color
end

-- Overloading Window:set()
function Frame:set(x,y)
  self.x = x - self.width/2
  self.y = y - self.height/2
end

-- A appFrame from "Frame" class
appFrame = Frame(100,100,800,600,'red')
print(appFrame.x,appFrame.y) --> 100, 100

appFrame:set(400,400)
print(appFrame.x,appFrame.y) --> 0, 100

appFrame.super.set(appFrame,400,300)
print(appFrame.x,appFrame.y) --> 400, 300
```

##License
This work is under [MIT-LICENSE](http://www.opensource.org/licenses/mit-license.php)<br/>
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
