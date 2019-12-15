
function update_game(dt)
  _t=_t+1


  -- player
  update_player(dt)

  -- collisions
  update_collisions()

  -- update camera
  update_camera(dt)
  
end

function update_player(dt)
  local gravity = 0.1
  local jumpAmount = -6

  if not player.onGround then
    -- update fall
    player.vy = player.vy + gravity
    player.y = player.y + player.vy
    -- note only when height increases
    if player.y < player.maxHeight then
      player.maxHeight = player.y
    end
    -- land
    if player.y > GAME_HEIGHT-40 then
      log("land")
      player.onGround = true
      player.vy = 0
    end
  end
  -- jump?
  if _t%200 == 100 then
    player.vy = jumpAmount
    player.onGround = false
    log("jump!")
  end
  
  -- v1 ---------------------------------------
  -- local speed = 200
  -- if _t%400<100 then
  --   player.y = player.y - speed *dt
  -- elseif _t%400>200 and _t%400<300 then
  --   player.y = player.y + speed *dt
  -- end
  -- -- note only when height increases
  -- if player.dy < 0 then
  --   player.maxHeight = player.y
  -- end
  ---------------------------------------------
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
    end
  end
end

function update_camera(dt)
  -- if player goes beyong camera "trap" height...
  --if player.y < cam.y+cam.trap_y then
    -- ... make camera follow player
    cam.y = lerp(cam.y, player.maxHeight-cam.trap_y, 2*dt)
  --end
end


function lerp(a, b, t)
   return a + t * (b - a)
end