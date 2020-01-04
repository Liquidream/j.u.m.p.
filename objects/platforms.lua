
-- Defines all the platform object types

-- ------------------------------------------------------------
-- Base platform properties, shared by all platforms, etc.
--
BasePlatformObject = Object:extend()
-- base constructor
function BasePlatformObject:new(x,y)
  -- initialising
  self.x = x
  self.y = y

  -- self.spr = 8 + irnd(2)
  -- self.spr_w = 1
  -- self.spr_h = 1
  -- self.hitbox_w = 32
  -- self.hitbox_h = 32
end
function BasePlatformObject:update(dt)
  -- anything?
end
function BasePlatformObject:draw()
  -- anything?
end
-- base state switcher (e.g. on "press")
-- most platforms will override this
function BasePlatformObject:setPressedState(is_pressed)
  self.pressed_state = is_pressed
  --log("setPressedState = "..tostring(is_pressed))
end


-- ------------------------------------------------------------
-- Static platform type (no interaction)
--
StaticPlatform = BasePlatformObject:extend()

function StaticPlatform:new(x,y,spr_width)
  StaticPlatform.super.new(self, x, y)

  self.type = 1
    -- 1 = solid block
    -- 2 = spikers
    -- 3 = floaters
    -- 4 = springers
    -- 5 = blockers

  self.spr = (spr_width==1) and (8 + irnd(2)) or 32
  self.spr_w = spr_width
  self.spr_h = 1
  self.hitbox_w = 32*spr_width
  self.hitbox_h = 32

  -- self:Reset()
end

function StaticPlatform:update(dt)
  -- update base class/values
  StaticPlatform.super.update(self, dt)

  -- update local stuff
end

function StaticPlatform:draw()
  -- draw base class/values
  StaticPlatform.super.draw(self)

  -- draw local stuff
end

-- function create_platform(x,y,type)
--   local newPlatform = {
--     x = x,
--     y = y,
--     type = type, 
--      -- 1 = solid block
--      -- 2 = spikers
--      -- 3 = floaters
--      -- 4 = springers
--      -- 5 = blockers
--     spr = 8 + irnd(2),
--     spr_w = 1,
--     spr_h = 1,
--     hitbox_w = 32,
--     hitbox_h = 32,

--     setPressedState = function(is_pressed)

--     end
--   }
  
-- end