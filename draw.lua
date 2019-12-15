

-- draw the actual game 
-- (including the title screen)
function draw_game()
  

  
  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    --draw_level()

  elseif gameState == GAME_STATE.LVL_PLAY then
    -- normal play (level intro/outro/game-over)    
    draw_level()

  else
    -- ??
  end


  
  
end

function draw_level()
  cls(29) --5

  camera(cam.x, cam.y)
  
  pal()
  palt(0, false)
  palt(35,true)

  -- draw platforms
  for i = 1,#platforms do
    -- draw platform (depending on type)
    local platform = platforms[i]
    rectfill(platform.x, platform.y, platform.x+80, platform.y+10, 19)    
  end

  circfill(60,100,12.5,3)

  draw_player(player.x,player.y, 25,25)

  if DEBUG_MODE then
    line(0, player.maxHeight, 50, player.maxHeight, 39)
  end

  draw_ui()

end



function draw_ui()
  camera(0,0)
  
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  printp_color(47, 0, 0, 0)


  --print("HELLO WORLD!",GAME_WIDTH/4,GAME_HEIGHT/2, 6)
  
  if DEBUG_MODE then
    -- show game area
    rect(0,0, GAME_WIDTH-1,GAME_HEIGHT-1, 35)    
  end

  
end


function draw_player(x,y)
  -- draw green blob
  aspr(0, x,y, 0, 1,1, 0.5, 0.5, 1,1)

  -- if surface_exists("photo") then
  --   -- draw bg frame in player's colour
  --   rectfill(x-1, y-1, x+dw, y+dh, 4)
  --   -- draw the actual photo
  --   spritesheet("photo")
  --   local w,h = surface_size("photo")
  --   sspr(0, 0, w, h, x, y, dw, dh)
  -- end

end