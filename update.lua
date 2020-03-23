
function update_game(dt)
  _t=_t+1

  -- temp fix for "falling" bug?
  if _t<5 then 
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
  
  -- player interactions (always capture latest state)
  update_player_input()
  -- update all buttons
  for k, button in pairs(buttons) do
    button:update(dt)
  end

  MusicManager:update(dt)

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen

  elseif gameState == GAME_STATE.TITLE then    
    -- anything??

    -- intro pt.1 (popup)
  elseif gameState == GAME_STATE.LVL_INTRO then    

    --TODO: wait for user to start next round?
    if popup then 
      gameCounter = gameCounter + 1
      if gameCounter > 500 or somethingPressed then
        -- start section        
        if not hiding_popup then
          hide_popup()
        end        
      end
    else
      -- move to intro pt.2 ("get ready")
      init_level_intro2()
    end

    -- intro pt.2 ("get ready")
  elseif gameState == GAME_STATE.LVL_INTRO2 then    

    --TODO: wait for user to start next round?
    gameCounter = gameCounter + 1
    if gameCounter > 150 or somethingPressed then  
      -- start section
      gameState = GAME_STATE.LVL_PLAY        
      blob.jumpCounter = 0
    end
    -- update camera
    update_camera(dt)

  -- normal play
  elseif gameState == GAME_STATE.LVL_PLAY then
    -- speed factor
    speed_dt = dt * blob.speedFactor


    -- jumping "blob"
    update_blob(speed_dt)

    -- platforms
    update_platforms(dt)

    -- collisions
    update_collisions()

    -- update camera
    update_camera(speed_dt)

  -- level/section end ("checkpoint")
  elseif gameState == GAME_STATE.LVL_END then
    
    -- update blob to stand
    if blob.jumpCounter < 10 then 
      blob.jumpCounter = blob.jumpCounter + 1
    end

    --TODO: wait for user to start next round?
    gameCounter = gameCounter + 1
    if gameCounter > 100 then  
      -- level up
      init_section(blob.levelNum + 1)
    end
    -- update camera
    update_camera(dt)

  elseif gameState == GAME_STATE.GAME_OVER then
    
    -- TODO: tally up score, then wait for user to decide (continue/exit)
 
    -- update camera
    update_camera(dt)
 
    -- show CONTINUE option yet?
    gameCounter = gameCounter + 1
    if gameCounter > 100 
     and #buttons==0 then    
      -- init mouse/touch controls
      init_cursor()

      -- init menu buttons
      buttons = {}
      local menu_xpos = 50
      local menu_ypos = GAME_HEIGHT/2 - 5

      local continueButton = BaseButtonObject(menu_xpos, menu_ypos+10, "YES", function()
        -- continue game
        init_game(blob.last_level_full_lives)
        -- stop game over sfx
        sounds.gameover[speedUpNum==0 and 1 or speedUpNum]:stop()
        -- play starting music playlist (for correct speed)
        MusicManager:playMusic(SPEEDUP_PLAYLISTS[speedUpNum])
      end,nil,nil)
      local titleButton = BaseButtonObject(menu_xpos, menu_ypos+35, "NO", function()
        -- stop game over sfx
        sounds.gameover[speedUpNum==0 and 1 or speedUpNum]:stop()
        -- exit to title
        init_title()
      end,nil,nil)
      table.insert(buttons, continueButton)
      table.insert(buttons, titleButton)
    end
  
  else
    -- ??
  end
  
end

function update_player_input()
  -- check whether touch/button pressed
  -- and update the world accordingly
  local mousePressed = btn(7)
  local mainKeyPressed = btn(4)
  local mx = flr(btnv(5)) - SCREEN_X
  local my = flr(btnv(6)) - SCREEN_Y

  cursor.x = mx
  cursor.y = my
  currPressedState = mousePressed or mainKeyPressed

  -- something pressed (this frame)
  somethingPressed = currPressedState and (currPressedState ~= lastPressedState)
  -- keep a tab of # of clicks (down & up)
  if somethingPressed 
   and gameState == GAME_STATE.LVL_PLAY 
  then
    pressedCount = pressedCount + 1
    --log("pressedCount:"..tostring(pressedCount))
  end


  pressedStateChanged = currPressedState ~= lastPressedState

  -- remember...
  lastPressedState = currPressedState
end


function update_platforms(dt)
  for i = 1,#platforms do
    local platform = platforms[i]
    if platform then
      -- something changed in pressed state (this frame)?
      if pressedStateChanged 
       and (currPressedState or pressedCount>0) then 
        -- update platform state
        -- (if either input method used)
        platform:setPressedState(currPressedState)
      end
      platform:update(dt)
    end
  end
end

function jump_blob(jumpPlatformCount)
  debug_log("in jump_blob()...")
  local jumpYAmounts = {
    -450, -- one platform
    -600, -- two platforms
    -670  -- three platforms?
  }
  local jumpXAmountAdjust = {
    1.4, -- one platform
    1.6, -- two platforms
    1.4  -- three platforms?
  }
  local jumpAmountY = jumpYAmounts[jumpPlatformCount]
  local jumpAmountX = 0  
  local nextPlat = platforms[blob.onPlatformNum+jumpPlatformCount]
  
  jumpAmountX = (nextPlat.x +(nextPlat.spr_w*32/2) -16 - blob.x)/jumpXAmountAdjust[jumpPlatformCount]

  blob.vy = jumpAmountY
  blob.vx = jumpAmountX
  blob.onGround = false
  blob.jumpCounter = 0
  blob.lastJumpPlatformCount = jumpPlatformCount
  debug_log("jump!")
  debug_log("jumpPlatformCount="..tostring(jumpPlatformCount))
  debug_log("blob.onPlatformNum+jumpPlatformCount="..tostring(blob.onPlatformNum+jumpPlatformCount))
  
end


function update_blob(dt)
  local gravity = 500
  
  if blob.onGround then
    local morePlatforms = true -- endless??
    local jumpPlatformCount = 1
    -- jump more for blocker platforms
    -- need to ensure the last platform is not a "blocker"
    if platforms[min(blob.onPlatformNum+1,#platforms)].type == PLATFORM_TYPE.BLOCKER then
      jumpPlatformCount = 2
    end
    blob.jumpCounter = blob.jumpCounter + 1
    -- jump?   
    if blob.jumpCounter >= blob.jumpFreq and morePlatforms then

      jump_blob(jumpPlatformCount)

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
      -- allow camera to follow again
      blob.maxHeight = blob.y
    end

    -- make sure blobby stays on screen
    if blob.x < -16 or blob.x > GAME_WIDTH-16 then
      -- bounce back in
      blob.vx = -blob.vx
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
      blob.onGround = true
      -- were we hurt?
      if blob.vy > 500 then
        blob:loseLife()
      end
      blob.vy = 0
      blob.x = platform.x + (platform.spr_w*32/2) - 16
      blob.y = platform.y - 32    

      if blob.onPlatform ~= platform
      --blob.onPlatformNum ~= platform.num       
       --and blob.onPlatformNum 
       then
        blob.onPlatformNum = i
        blob.onPlatform = platform
        if not blob.onPlatform.completed then
          blob.score = blob.score + 1
          blob.onPlatform:setCompleted(true)
          --blob.onPlatform.completed = true
        end
        debug_log("blob.onPlatformNum = "..blob.onPlatformNum)
        debug_log("#platforms = "..#platforms)

        -- is this a checkpoint?
        if blob.onPlatform.isCheckpoint 
         and not blob.onPlatform.checkpointReached then
          blob.onPlatform.checkpointReached = true
          blob.lastCheckpointPlatNum = blob.onPlatform.num
          blob.startPlatformNum = blob.onPlatform.num
          -- clear old ones platforms
          prune_platforms(i-1)
          --log("CHECKPOINT!")          
          debug_log("#platforms = "..#platforms)

          sounds.checkpoints[speedUpNum+1]:play()
          --pick(sounds.checkpoints):play()


          -- DEBUG:
          for k,p in pairs(platforms) do
            debug_log(" - ["..k.."]="..p.num)
          end

          -- end of section
          init_level_end()

          -- bail out now
          return
        end
       end
       
      -- generate new platforms (and clear old ones)
      generate_platforms()
    end
  end
end

-- generate new platforms (and clear old ones)
function generate_platforms()
  debug_log("blob.onPlatformNum = "..tostring(blob.onPlatformNum))
  debug_log("blob.lastCheckpointPlatNum = "..tostring(blob.lastCheckpointPlatNum))
  debug_log("#platforms "..tostring(#platforms))
  
  -- create any missing platforms (so there's always enough ahead)
  while #platforms < blob.onPlatformNum + 5 do
    -- auto-increase the platform count
    blob.platformCounter = blob.platformCounter + 1 
    local newPlatform = createNewPlatform(blob.platformCounter)
    newPlatform.num = blob.platformCounter --platforms[#platforms].num + 1
    --blob.platformCounter
    --newPlatform.num
    newPlatform.sectionNum = (newPlatform.num < blob.startPlatformNum + blob.numPlatforms) 
                                  and blob.levelNum or blob.levelNum + 1
    platforms[#platforms + 1] = newPlatform
  end

  -- TODO: Remove old platforms e.g. everything below last checkpoint
  --      (probably best to do it at the last checkpoint)

end

-- clear old ones platforms
function prune_platforms(numTodeleteTo)
  debug_log("in prune_platforms("..numTodeleteTo..")...")
  -- remove all platforms prior to last checkpoint
  for i=1,numTodeleteTo do
    --platforms[i] = nil
    --platforms[i]="nil"
    table.remove(platforms, 1)
  end
  -- shift blobby platform pos
  blob.onPlatformNum = 1
end

function update_camera(dt)
  -- make camera follow blob's highest height
  cam.y = lerp(cam.y, blob.maxHeight-cam.trap_y, 3*dt)
end


function lerp(a, b, t)
   return a + t * (b - a)
end