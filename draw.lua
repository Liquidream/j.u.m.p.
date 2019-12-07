

-- draw the actual game 
-- (including the title screen)
function draw_game()
  cls() --5

  camera(0,0)
  
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  printp_color(47, 0, 0, 0)

  -- show game area
  rect(0,0,GAME_WIDTH-1,GAME_HEIGHT-1, 35)
  

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    --draw_level()

  else
    -- normal play (level intro/outro/game-over)    
    --draw_level()
  end


end