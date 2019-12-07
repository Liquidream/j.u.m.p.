

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


  circfill(0,0,40,3)

  print("HELLO WORLD!",GAME_WIDTH/4,GAME_HEIGHT/2, 6)
  
  if DEBUG_MODE then
    -- show game area
    rect(0,0,GAME_WIDTH-1,GAME_HEIGHT-1, 35)
  end

end