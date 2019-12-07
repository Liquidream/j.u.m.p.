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
  
  • @egordorichev for input icons
    https://egordorichev.itch.io/key-set

]]

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    "sugarcoat/sugarcoat.lua",
    "common.lua",
    "init.lua",
    "draw.lua",
    "update.lua",
    --"spritesheet.png",   
  })
end

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
--tween = require 'lib/tween'
require("common")
require("init")
require("update")
require("draw")
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

function on_resize()
  local winw, winh = window_size()
  
  local scale = max(min(flr(winw/GAME_WIDTH), flr(winh/GAME_HEIGHT)), 1)
  
  screen_resizeable(true, scale, on_resize)
end