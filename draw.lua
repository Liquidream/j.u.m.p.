

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
  cls(0) 

  -- clip to game bounds?
  --clip(0,0, GAME_WIDTH-1,GAME_HEIGHT-1)

  draw_background()

  camera(cam.x, cam.y)
  
  pal()
  palt(0, false)
  palt(35,true)

  -- draw platforms
  for i = 1,#platforms do
    -- draw platform (depending on type)
    local platform = platforms[i]
    platform:draw()
    -- spr(platform.spr, platform.x, platform.y, platform.spr_w, spr_h)
  end

  --circfill(60,100,12.5,3)

  draw_blob(blob.x,blob.y, 25,25)

  if DEBUG_MODE then
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

function draw_background()
  --cls(0) --29
  camera(0,0)
  for y=-2,14 do
    for x=-1,5 do
      spr(31,x*32-8,y*32 -(cam.y/2)%32)
    end
  end
end

function draw_hitbox(obj, col)
  rect(obj.x, obj.y, obj.x+obj.hitbox_w, obj.y+obj.hitbox_h, col)
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

  for i=0,blob.lives-1 do
    spr(30,i*22,-4)
  end

  pprint( string.format("%02d",blob.score) ,GAME_WIDTH-38,-2, 47)
  --print("HELLO WORLD!",GAME_WIDTH/4,GAME_HEIGHT/2, 6)
  
  if DEBUG_MODE then
    -- show game area
    rect(0,0, GAME_WIDTH-1,GAME_HEIGHT-1, 35)
    line(GAME_WIDTH/2,0,GAME_WIDTH/2,GAME_HEIGHT,12)
  end

  
end


function draw_blob(x,y)
  local spr = 0
  -- update anims
  if blob.onGround then
    if blob.jumpCounter < 10 
     or blob.jumpCounter > blob.jumpFreq-10 then 
      spr = 1
    else
      spr = 0
    end
  else
    -- jumping
    spr=2
  end 

  -- draw green blob
  aspr(spr, x,y, 0, 1,1, 0, 0, 1,1)

  -- if surface_exists("photo") then
  --   -- draw bg frame in player's colour
  --   rectfill(x-1, y-1, x+dw, y+dh, 4)
  --   -- draw the actual photo
  --   spritesheet("photo")
  --   local w,h = surface_size("photo")
  --   sspr(0, 0, w, h, x, y, dw, dh)
  -- end

end