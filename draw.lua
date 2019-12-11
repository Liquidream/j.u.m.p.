

-- draw the actual game 
-- (including the title screen)
function draw_game()
  cls(2) --5

  camera(0,0)
  
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  printp_color(47, 0, 0, 0)

  
  

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    --draw_level()

  elseif gameState == GAME_STATE.LVL_PLAY then
    -- normal play (level intro/outro/game-over)    
    --draw_level()

  else
    -- ??
  end


  --circfill(0,0,40,3)

  print("HELLO WORLD!",GAME_WIDTH/4,GAME_HEIGHT/2, 6)

  circfill(60,100,12.5,3)
  --draw_player(60,100, 25,25)
  
  if DEBUG_MODE then
    -- show game area
    rect(0,0,GAME_WIDTH-1,GAME_HEIGHT-1, 35)
  end

end

function draw_player(x,y,dw,dh)
  pal()
  palt(0, false)

  if surface_exists("photo") then
    -- draw bg frame in player's colour
    rectfill(x-1, y-1, x+dw, y+dh, 4)
    -- draw the actual photo
    spritesheet("photo")
    local w,h = surface_size("photo")
    sspr(0, 0, w, h, x, y, dw, dh)
  end

  palt()
end