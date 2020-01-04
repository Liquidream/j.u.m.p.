
function update_game(dt)
  _t=_t+1

  -- player interactions
  update_player_input()

  -- jumping "blob"
  update_blob(dt)

  -- collisions
  update_collisions()

  -- update camera
  update_camera(dt)
  
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
  local gravity = 0.1
  
  if blob.onGround then
    local jumpAmountY = -6
    local jumpAmountX = 0
    if platforms[blob.onPlatformNum+1] then 
      jumpAmountX = (platforms[blob.onPlatformNum+1].x - blob.x)/85
    end
    -- jump?
    blob.jumpCounter = blob.jumpCounter + 1
    if blob.jumpCounter == blob.jumpFreq then
      blob.vy = jumpAmountY
      blob.vx = jumpAmountX
      blob.onGround = false
      blob.jumpCounter = 0
      log("jump!")
    end

  else  
    -- jumping/falling
    blob.vy = blob.vy + gravity
    blob.y = blob.y + blob.vy
    blob.x = blob.x + blob.vx
    -- note only when height increases
    if blob.y < blob.maxHeight then
      blob.maxHeight = blob.y
    end
  end  

end

function update_collisions()
  -- player > platforms
  for i = 1,#platforms do
    local platform = platforms[i]    
    -- if collide with platform while falling...
    if aabb(blob, platform)
     and blob.vy>0 then
      -- then land!
      log("landed!")
      blob.onGround = true
      blob.vy = 0
      blob.score = blob.score + 1
      blob.onPlatformNum = i
      blob.x = platform.x + (platform.spr_w*32/2) - 16
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