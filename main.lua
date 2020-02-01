--[[
-- J.U.M.P.
-- by Paul Nicholas

## TODO's
  • 
  • 
  
## IDEAS
  • 
  • 
  
## DONE  
  • 

## ACKNOWLEDGEMENTS
  • @somepx for Hungry font
    https://www.patreon.com/posts/new-free-font-27405348
  

]]

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    "sugarcoat/sugarcoat.lua",
    "common.lua",
    "init.lua",
    "draw.lua",
    "update.lua",
    "assets/spritesheet.png",
    "assets/gomarice_gogono_cocoa_mochi.ttf",
    "lib/classic.lua",
    "objects/platforms.lua",
    "lib/tween.lua",
  })
end

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
tween = require 'lib/tween'
require("common")
require("init")
require("update")
require("draw")
Object = require("lib/classic")
require("objects/platforms")
--require("sprinklez")


 
function love.load()
  init_game()
end

function love.update(dt)
  if not _initialized then return end

  update_game(dt)
end

function love.draw()
  if not _initialized then return end

  draw_game()
end

function love.keypressed( key, scancode, isrepeat )
  -- Debug switch
  if key=="d" and love.keyboard.isDown('lctrl') then
      DEBUG_MODE = not DEBUG_MODE
      log("Debug mode: "..(DEBUG_MODE and "Enabled" or "Disabled"))
      return
  end
end

function on_resize()
  local winw, winh = window_size()  
  -- auto-set game rotation (landscape/portait)
  -- if winw > winh then    
  --   GAME_WIDTH = GAME_WIDTH_LANDSCAPE     -- landscape
  --   GAME_HEIGHT = GAME_HEIGHT_LANDSCAPE 
  -- else
  --   GAME_WIDTH = GAME_WIDTH_PORTRAIT     -- portrait/mobile
  --   GAME_HEIGHT = GAME_HEIGHT_PORTRAIT 
  -- end

  -- update game scale (integer snap)
  local scale = max(min(flr(winw/GAME_WIDTH), flr(winh/GAME_HEIGHT)), 1)  
  screen_resizeable(true, scale, on_resize)  
end

-- TRASEVOL_DOG's "Centered" Camera()
local _camera = camera
SCREEN_X, SCREEN_Y = 0, 0
function camera(x,y)
 scrw, scrh = screen_size()
 
 if ON_MOBILE and scrh > scrw then
  SCREEN_X = scrw/2 - GAME_WIDTH/2
  SCREEN_Y = max(scrh/4 - GAME_HEIGHT/2, SCREEN_X)
 else
  SCREEN_X = scrw/2 - GAME_WIDTH/2
  SCREEN_Y = scrh/2 - GAME_HEIGHT/2
 end
 
 _camera(-SCREEN_X+x, -SCREEN_Y+y)

end
rcamera = _camera