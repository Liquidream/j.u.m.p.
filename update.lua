
function update_game(dt)
  _t=_t+1


  -- player
  update_player(dt)

  -- update camera
  update_camera(dt)
  
end

function update_player(dt)
  if _t%400<100 then
    player.y = player.y - 2
  elseif _t%400>200 and _t%400<300 then
    player.y = player.y + 2
  end
end

function update_camera(dt)
  -- if player goes beyong camera "trap" height...
  --if player.y < cam.y+cam.trap_y then
    -- ... make camera follow player
    cam.y = lerp(cam.y, player.y-cam.trap_y, 1*dt)
  --end
end


function lerp(a, b, t)
   return a + t * (b - a)
end