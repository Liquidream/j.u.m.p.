

-- draw the actual game 
-- (including the title screen)
function draw_game()
  
  if gameState == GAME_STATE.SPLASH then
    
    -- TODO: splash screen

  elseif gameState == GAME_STATE.TITLE then

    -- TODO: title screen
    draw_level()

  elseif gameState == GAME_STATE.LVL_INTRO 
      or gameState == GAME_STATE.LVL_INTRO2
      or gameState == GAME_STATE.LVL_PLAY 
      or gameState == GAME_STATE.LVL_END 
      or gameState == GAME_STATE.GAME_OVER 
   then
    -- normal play (level intro/outro/game-over)    
    draw_level()

  else
    -- ??
  end
end

function draw_level()
  cls(0) 

  -- clip to game bounds?
  --clip(0,0, GAME_WIDTH-1,GAME_HEIGHT-1)

  draw_background()

  draw_far()

  -- calc shake amount
  shake_x = rnd(32) * shake
  shake_y = rnd(32) * shake

  -- set camera pos for level draw
  camera(cam.x+shake_x, cam.y+shake_y)

  -- finally, fade out the shake
 shake = shake * 0.95
 -- reset to 0 when very low
 if shake < 0.05 then  shake = 0 end
  
  -- reset palette
  pal()
  palt()
  palt(0, false)
  palt(35,true)

  -- platforms
  draw_platforms()

  --circfill(60,100,12.5,3)

  draw_blob(blob.x,blob.y, 25,25)

  draw_mid()

  draw_near()


  if DEBUG_MODE then
    camera(cam.x+shake_x, cam.y+shake_y)
    -- draw max height line (camera focus)
    line(0, blob.maxHeight, 50, blob.maxHeight, 39)
    -- draw collision hitboxes
    draw_hitbox(blob ,39)
    for i = 1,#platforms do
      local platform = platforms[i]
      draw_hitbox(platform ,39)
    end
  end

  draw_ui()

end

function draw_platforms()
  for i = 1,#platforms do
    -- draw platform (depending on type)
    local platform = platforms[i]
    if platform then 
      platform:draw()
    end
  end
end

function draw_background()
  camera(shake_x,shake_y)
  local d=1.5
  for y=-2,14 do
    for x=-1,5 do      
      spr(31,x*32-8,y*32 -(cam.y/d)%32)
    end
  end
end

function draw_far()
  camera(shake_x,shake_y)
  local d=1.25
  for y=-2,14 do    
    spr(4,-80,y*32 -(cam.y/d)%32, 2,1)
    spr(4,GAME_WIDTH+16,y*32 -(cam.y/d)%32, 2,1, true)
  end
end

function draw_mid()
  camera(shake_x,shake_y)
  local d=1
  for y=-2,7 do    
    spr(6,-92,y*64 -(cam.y/d)%64, 2,2)
    spr(6,GAME_WIDTH+28,y*64 -(cam.y/d)%64, 2,2, true)
  end
end

function draw_near()
  camera(shake_x,shake_y)
  local d=0.75
  for y=-2,5 do    
    spr(40,-140,y*96 -(cam.y/d)%96, 3,3)
    spr(40,GAME_WIDTH+44,y*96 -(cam.y/d)%96, 3,3, true)
  end

  -- two rects to complete the edges
  rectfill(-SCREEN_X-1,-SCREEN_Y, -140, scrh, 36)
  local r = SCREEN_X + GAME_WIDTH +10
  rectfill(r,-SCREEN_Y, r-SCREEN_X+130, scrh, 36)
end

function draw_hitbox(obj, col)
  rect(obj.x, obj.y, obj.x+obj.hitbox_w, obj.y+obj.hitbox_h, col)
end

function draw_ui()
  camera(shake_x,shake_y)
  
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  printp_color(47, 0, 0, 0)

  

  
  if gameState == GAME_STATE.TITLE then
    use_font("big-font")
    pprint("J.U.M.P.", (GAME_WIDTH/2)-74, (GAME_HEIGHT/2)-134, 9, 6)
    use_font ("small-font")
    pprint("JUMPING\n   UNDER\n      MASSIVE\n         PRESSURE", 
    (GAME_WIDTH/2)-70, (GAME_HEIGHT/2)-90, 3,0)
    pprint("J\n   U\n      M\n         P", 
    (GAME_WIDTH/2)-70, (GAME_HEIGHT/2)-90, 9)
    
    if #buttons > 0 then
      -- dark overlay
      local menu_x = (GAME_WIDTH/2)-72
      local menu_y = (GAME_HEIGHT/2)-28
      for x=menu_x,menu_x+(7*16),16 do
        for y=menu_y,menu_y+(4*16),16 do
          aspr(43, x,y, 0, 1,1, 0, 0)
        end  
      end  
      pprint("CHOOSE DIFFICULTY:", menu_x, menu_y, 19)
      
      -- credits
      if flr(t())%6 < 3 then
        pprint('   MUSIC + SFX', 0, GAME_HEIGHT-26, 20)
        pprint('  CHRIS DONNELLY', 0, GAME_HEIGHT-13, 47)        
      else
        pprint('    CODE + ART', 0, GAME_HEIGHT-26, 20)
        pprint('   PAUL NICHOLAS', 0, GAME_HEIGHT-13, 47)
      end
    end

  end
  
  use_font("main-font")

  -- draw blobby's lives
  if gameState ~= GAME_STATE.TITLE then    
    for i=0,blob.lives-1 do
      spr(30,i*22,-4)
    end
  end

  if gameState == GAME_STATE.LVL_INTRO 
  and popup then
    draw_popup()
  end
  
  if gameState == GAME_STATE.LVL_INTRO2 then
    if gameCounter > 25 then 
      pprint("LEVEL "..blob.levelNum, (GAME_WIDTH/2)-47, (GAME_HEIGHT/2)-56, 47)
      use_font("small-font")
      pprint(blob.numPlatforms.." PLATFORMS", (GAME_WIDTH/2)-47, (GAME_HEIGHT/2)-26, 47)
      use_font("main-font")
    end
    
  end
  
  if gameState == GAME_STATE.LVL_PLAY then
    local progress = (blob.onPlatformNum-1).."/"..blob.numPlatforms
    pprint(progress, GAME_WIDTH-(14*#progress),-2, 47)
    --pprint( string.format("%02d",blob.score) ,GAME_WIDTH-38,-2, 47)
  end
  
  if gameState == GAME_STATE.LVL_END then
    pprint("CHECKPOINT", (GAME_WIDTH/2)-72, (GAME_HEIGHT/2)-56, 47)
    -- pprint("LEVEL", (GAME_WIDTH/2)-38, (GAME_HEIGHT/2)-56, 47)
    -- pprint("COMPLETE", (GAME_WIDTH/2)-64, (GAME_HEIGHT/2)-32, 47)
  end

  if gameState == GAME_STATE.GAME_OVER then
    if #buttons > 0 then
      use_font("big-font")
      pprint("GAME OVER", (GAME_WIDTH/2)-94, (GAME_HEIGHT/2)-86, 36)
      use_font("small-font")
      -- dark overlay
      local menu_x = (GAME_WIDTH/2)-72
      local menu_y = (GAME_HEIGHT/2)-28
      for x=menu_x,menu_x+(7*16),16 do
        for y=menu_y,menu_y+(4*16),16 do
          aspr(43, x,y, 0, 1,1, 0, 0)
        end  
      end  
      pprint("CONTINUE..?", menu_x, menu_y, 19)
    end
  end

  -- regardless of state, draw buttons
  for k, button in pairs(buttons) do
    button:draw(dt)
  end

  if DEBUG_MODE then
    -- show game area
    rect(0,0, GAME_WIDTH-1,GAME_HEIGHT-1, 35)
    line(GAME_WIDTH/2,0,GAME_WIDTH/2,GAME_HEIGHT,12)

    use_font ("small-font")
    pprint('FPS:' .. love.timer.getFPS(), 92, 32, 49)
  end
  


end


function draw_popup()
  --43 (3x3) bg  
  rcamera(0,0)
  -- dark overlay
  for x=0,scrw+96,96 do
    for y=0,scrh+96,96 do
      aspr(43, x,y, 0, 3,3, 0, 0)
    end  
  end  
  
  camera(shake_x,shake_y)
  -- pop-up
  spritesheet("popups")

  local spr = (popup.info_value+(7*popup.info_type)) * 4
  aspr(spr, GAME_WIDTH/2, GAME_HEIGHT/2, 0, 4,4, 0.5, 0.5, popup.sx, popup.sy)

  -- "hint" to skip popup
  if gameCounter > 50 and flr(t())%2==1 and not hiding_popup then
    use_font ("small-font")
    pprint('PRESS TO CLOSE', 14, GAME_HEIGHT-55, 45)
  end

  -- restore normal drawing
  spritesheet("spritesheet")
end


function draw_blob(x,y)
  local spr = 0
  -- update anims
  if blob.onGround then
    if blob.jumpCounter < 9 
     or blob.jumpCounter > blob.jumpFreq then 
      spr = 1
    else
      spr = 0
    end
  else    
    -- jumping
    --debug_log("blob.vy:"..blob.vy)
    if blob.vy < -25 then
      spr=2   -- squished
    else
      spr=0   -- normal
    end
  end 
  
  -- draw green blob
  aspr(spr, x,y, 0, 1,1, 0, 0, 1,1)

end