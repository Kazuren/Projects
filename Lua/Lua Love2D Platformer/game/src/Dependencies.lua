--[[
    Libraries
]]

-- A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support.
class = require 'lib/middleclass'

-- A collection of functions for Lua, geared towards game development.
lume = require 'lib/lume'

-- A fast, lightweight tweening library for Lua.
flux = require 'lib/flux'

-- push is a simple resolution-handling library that allows you to focus on making your game with a fixed resolution.
push = require 'lib/push'

-- Gives love.run superpowers, including a fixed timestep model and framerate limiting.
tick = require 'lib/tick'

-- Dispatch and handle events.
Event = require 'lib/knife.event'

-- Create timers and tweens.
Timer = require 'lib/knife.Timer'

-- An input module for LÖVE. 
-- Simplifies input handling by abstracting them away to actions, enabling pressed/released checks outside of LÖVE's callbacks and taking care of gamepad input as well. :)
Input = require 'lib/input'

-- A small module which automatically hotswaps changed Lua files in a running LÖVE project.
lurker = require 'lib/lurker'

-- A collection of splash screens for LÖVE.
splashes = require 'lib/splashes'

-- Cargo makes it easy to manage assets in a Love2D project by exposing project directories as Lua tables. 
-- This means you can access your files from a table automatically without needing to load them first. 
-- Assets are lazily loaded, cached, and can be nested arbitrarily.
-- You can also manually preload sets of assets at a specific time to avoid loading hitches.
cargo = require 'lib/cargo'

-- binser is a robust, pure Lua serializer that specializes in serializing Lua data with lots of userdata and custom classes and types. 
-- binser is a binary serializer and does not serialize data into human readable representation or use the Lua parser to read expressions. 
-- This makes it safe and moderately fast, especially on LuaJIT. binser also handles cycles, self-references, and metatables.
binser = require 'lib/binser'

-- Lua collision-detection library for axis-aligned rectangles.
bump = require 'lib/bump'

-- wave is a LÖVE sound manager with advanced audio parsing functionalities.
audio = require 'lib/wave'

-- deep is a tiny library for queuing and executing actions in sequence.
deep = require 'lib/deep'

-- Animation library for LÖVE.
-- In order to build animations more easily, anim8 divides the process in two steps: 
-- first you create a grid, which is capable of creating frames (Quads) easily and quickly. Then you use the grid to create one or more animations.
anim8 = require 'lib/anim8'

-- This is a lua port of the Robert Penner's equations for easing. You can find much more information about it on [http://www.robertpenner.com/easing/](his web site).
easing = require 'lib/easing'

-- STALKER-X is a camera module for LÖVE. It provides basic functionalities that a camera should have and is inspired by hump.camera and FlxCamera. 
-- The goal is to provide enough functions that building something like in this video becomes as easy as possible.
Camera = require 'lib/camera'

require 'helpers/deepcopy'

--[[
    Constants
]]

require 'src/constants'

--[[
    Util
]]

require 'src/Util'

--[[
    Managers
]]


require 'src/managers/ResolutionManager'
require 'src/managers/DebugManager'
require 'src/managers/StateManager'
require 'src/managers/ColorManager'
require 'src/managers/MenuManager'

--[[
    Entities
]]

require 'src/entity/StateMachine'
require 'src/entity/Entity'
require 'src/entity/player/Player'
require 'src/entity/player/Hair'

--[[ 
    Entity States
]]

require 'src/entity/EntityBaseState'
require 'src/entity/player/PlayerIdleState'
require 'src/entity/player/PlayerWalkState'
require 'src/entity/player/PlayerAirState'
require 'src/entity/player/PlayerJumpState'
require 'src/entity/player/PlayerBlinkState'

--[[
    World
]]

require 'src/world/tilesets'
require 'src/world/objects'
require 'src/world/Tile'
require 'src/world/Object'
require 'src/world/Map'
require 'src/world/Chapter'

--[[
    GUI
]]

require 'src/gui/Menu'
require 'src/gui/Mouse'

--[[
    States
]]

require 'src/states/BaseState'
require 'src/states/SplashState'
require 'src/states/MenuState'
require 'src/states/PlayState'
require 'src/states/MapEditorState'

require 'src/states/FadeState'

--[[
    Map Editor
]]

require 'src/mapeditor/Box'
require 'src/mapeditor/MapViewState'
require 'src/mapeditor/MapEditState'
require 'src/mapeditor/MapSelectItemState'