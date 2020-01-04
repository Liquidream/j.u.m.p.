
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
  local jumpAmount = -6

  if player.onGround then
    -- jump?
    player.jumpCounter = player.jumpCounter + 1
    if player.jumpCounter == player.jumpFreq then
      player.vy = jumpAmount
      player.onGround = false
      player.jumpCounter = 0
      log("jump!")
    end

  else  
    -- jumping/falling
    player.vy = player.vy + gravity
    player.y = player.y + player.vy
    -- note only when height increases
    if player.y < player.maxHeight then
      player.maxHeight = player.y
    end
  end  

end

function update_collisions()
  -- player > platforms
  for i = 1,#platforms do
    local platform = platforms[i]    
    -- if collide with platform while falling...
    if aabb(player, platform)
     and player.vy>0 then
      -- then land!
      log("landed!")
      player.onGround = true
      player.vy = 0
      player.score = player.score + 1
    end
  end
end

function update_camera(dt)
  -- make camera follow player's highest height
  cam.y = lerp(cam.y, player.maxHeight-cam.trap_y, 2*dt)
end


function lerp(a, b, t)
   return a + t * (b - a)
end