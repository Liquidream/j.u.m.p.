--[[
-- J.U.M.P.
-- by Paul Nicholas

## TODO's
  • 
  • 
  
## IDEAS
  • 
  • 

## SFX Needed
  • Checkpoint
  • Hurt (lose life)
  (OPTIONAL - Will they clash with music?)
  • Jump
  • Land (platform progression)
  • Boost jump (spring bounce)
  • 
  • 
  
## DONE  
  • 

## ACKNOWLEDGEMENTS
  • Goma ShinGogono for "Cocoa Mochi Font"
    https://www.dafont.com/gogono-cocoa-mochi.font

  • @somepx for AweMono font
    https://www.patreon.com/posts/free-font-and-34049548

  • The FontStruction “GAMEPLAY 1987”
    (http://fontstruct.com/fontstructions/show/1073507) by “GeronimoFonts” is
    licensed under a Creative Commons Attribution Share Alike license
    (http://creativecommons.org/licenses/by-sa/3.0/).
  

]]

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    "sugarcoat/sugarcoat.lua",
    "lib/classic.lua",
    "lib/tween.lua",
    "lib/sound.lua",
    "objects/platforms.lua",
    "common.lua",
    "init.lua",
    "update.lua",
    "draw.lua",
    "assets/spritesheet.png",
    "assets/gomarice_gogono_cocoa_mochi.ttf",
    "assets/AweMono.ttf",
    "assets/GAMEPLAY-1987.ttf",
    "assets/snd/Jump Music Title Music Loop.ogg",
    "assets/snd/Jump Music Level 1 Intro Loop.ogg",
    "assets/snd/Jump Music Level 1 Game Loop.ogg",
    "assets/snd/Jump Music Level 1-2 Transition.ogg",
    "assets/snd/Jump Music Level 2 Intro Loop.ogg",
    "assets/snd/Jump Music Level 2 Game Loop.ogg",
    "assets/snd/Jump Music Level 2-3 Transition.ogg",
    "assets/snd/Jump Music Level 3 Intro Loop.ogg",
    "assets/snd/Jump Music Level 3 Game Loop.ogg",
    "assets/snd/Jump Music Level 3-4 Transition.ogg",
    "assets/snd/Jump Music Level 4 Intro Loop.ogg",
    "assets/snd/Jump Music Level 4 Game Loop.ogg",
    "assets/snd/Jump Music Level 4-5 Transition.ogg",
    "assets/snd/Jump Music Level 5 Intro Loop.ogg",
    "assets/snd/Jump Music Level 5 Game Loop.ogg",
    "assets/snd/Jump Music Game Over Level 1.ogg",
    "assets/snd/Jump Music Game Over Level 2.ogg",
    "assets/snd/Jump Music Game Over Level 3.ogg",
    "assets/snd/Jump Music Game Over Level 4-5.ogg",
    "assets/snd/Jump SFX Checkpoint1.ogg",
    "assets/snd/Jump SFX Checkpoint2.ogg",
    "assets/snd/Jump SFX Checkpoint3.ogg",    
    "assets/snd/Jump SFX Checkpoint4.ogg",    
    "assets/snd/Jump SFX Checkpoint5.ogg",    
    "assets/snd/Jump SFX Ouch1.ogg",
    "assets/snd/Jump SFX Ouch2.ogg",
    "assets/snd/Jump SFX Ouch3.ogg",
    "assets/snd/Jump SFX Ouch4.ogg",
    "assets/snd/Jump SFX Ouch5.ogg",
    "assets/snd/JUMP SFX Breaking.ogg",
    "assets/snd/JUMP SFX Boing1.ogg",
    "assets/snd/JUMP SFX Boing2.ogg",
  })
end

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
tween = require 'lib/tween'
Sound = require("lib/sound")
Object = require("lib/classic")
require("objects/platforms")
require("objects/buttons")
require("common")
require("init")
require("update")
require("draw")
--require("sprinklez")

MusicManager = require("lib/musicmanager")


 
function love.load()
  -- only perform core init once
  init_sugarcoat()  
  init_assets()
  init_input()
  on_resize()

  _initialized = true

  -- start at title screen
  init_title()
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

  if DEBUG_MODE then
    local currLevel = blob and blob.levelNum or 1
    if key=="up" then
      -- reset to level above      
      init_game(currLevel + 1)

    elseif key=="down" then
      -- reset to level below
      init_game(max(currLevel - 1, 1))
    end
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