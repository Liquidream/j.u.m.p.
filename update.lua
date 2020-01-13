
function update_game(dt)
  _t=_t+1

  -- temp fix for "falling" bug?
  if _t<10 then 
    return
  end

  -- Update all tween animations
  for key, tween in pairs(tweens) do
    local complete = tween:update(dt)
    -- purge completed tweens
    if complete then
      table.remove(tweens, key)
    end
  end

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen    

  -- normal play (level intro/outro/game-over)    
  elseif gameState == GAME_STATE.LVL_PLAY then
    -- player interactions
    update_player_input()

    -- jumping "blob"
    update_blob(dt)

    -- platforms
    update_platforms(dt)

    -- collisions
    update_collisions()

    -- update camera
    update_camera(dt)

  -- normal play (level intro/outro/game-over)    
  elseif gameState == GAME_STATE.LVL_END then
    
    -- TODO: tally up score, then wait for user to start next round
    gameCounter = gameCounter + 1
    if gameCounter > 100 then
      -- level up
      blob.levelNum = blob.levelNum + 1
      init_level()
    end
    -- update camera
    update_camera(dt)
  
  else
    -- ??
  end    
end

function update_platforms(dt)
  for i = 1,#platforms do
    local platform = platforms[i]
    platform:update(dt)
  end
end

function update_player_input()
  -- check whether touch/button pressed
  -- and update the world accordingly
  local mousePressed = btn(7)
  local mainKeyPressed = btn(4)
  local currPressedState = mousePressed or mainKeyPressed  

  if currPressedState ~= lastPressedState then
    for key,platform in pairs(platforms) do
      -- update platform state
      -- (if either input method used)
      platform:setPressedState(currPressedState)
    end
  end

  -- remember...
  lastPressedState = currPressedState
end

function update_blob(dt)
  local gravity = 500
  local jumpAmountY = -450
  local speedFactor = 2
  -- apply speed
  -- jumpAmountY = jumpAmountY * speedFactor
  -- gravity = gravity * speedFactor

  
  if blob.onGround then
    local jumpAmountX = 0
    local morePlatforms = platforms[blob.onPlatformNum+1] ~= nil
    if morePlatforms then      
      jumpAmountX = (platforms[blob.onPlatformNum+1].x - blob.x)/1.4
    end
    blob.jumpCounter = blob.jumpCounter + 1   
    -- jump?   
    if blob.jumpCounter == blob.jumpFreq and morePlatforms then
      blob.vy = jumpAmountY
      blob.vx = jumpAmountX
      blob.onGround = false
      blob.jumpCounter = 0
      --log("jump!")
    end

    -- check for level end
    if not morePlatforms and blob.jumpCounter >= blob.jumpFreq-10 then
      -- end of level
      gameState = GAME_STATE.LVL_END      
      gameCounter = 0
    end

  else  
    -- jumping/fallings
    blob.vy = blob.vy + gravity *dt
    blob.y = blob.y + blob.vy *dt
    blob.x = blob.x + blob.vx *dt
    -- note only when height increases (and going UP)
    if blob.y < blob.maxHeight 
     and blob.vy < 0 then
      blob.maxHeight = blob.y
    end

    -- check for off screen
    if blob.y > blob.maxHeight +50
     and blob.maxHeight < blob.y 
     then 
      --blob:loseLife()
      -- allow camera to follow again
      blob.maxHeight = blob.y-- + GAME_HEIGHT/2
    end
  end  
end

function update_collisions()
  -- player > platforms
  for i = 1,#platforms do
    local platform = platforms[i]    
    -- if collide with platform while falling...
    if platform:hasLanded(blob) then
      -- then land!
      --log("landed!")
      blob.onGround = true
      blob.vy = 0
      if blob.onPlatformNum ~= i
       and blob.onPlatform ~= platform then
        blob.score = blob.score + 1
        blob.onPlatformNum = i
        blob.onPlatform = platform
       end
      blob.x = platform.x + (platform.spr_w*32/2) - 16
      blob.y = platform.y - 32
    end
  end
end

function update_camera(dt)
  -- make camera follow blob's highest height
  cam.y = lerp(cam.y, blob.maxHeight-cam.trap_y, 2*dt)
end


function lerp(a, b, t)
   return a + t * (b - a)
end