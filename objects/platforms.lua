
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
  -- randomise which is the "active" state (true/false)
  self.activeState = irnd(2)==0 
  -- default to false state (could be active or inactive)
  self.currState = false

  -- self.hitbox_w = 32
  -- self.hitbox_h = 32
end
function BasePlatformObject:update(dt)
  -- anything?
end
function BasePlatformObject:draw()
  -- anything?
  spr(self.spr, self.x, self.y, self.spr_w, spr_h)
end
-- base state switcher (e.g. on "press")
-- most platforms will override this
function BasePlatformObject:setPressedState(is_pressed)
  self.currState = is_pressed
  --log("setPressedState = "..tostring(is_pressed))
end
-- base "landed" test
-- most platforms will override this
function BasePlatformObject:hasLanded(blob)
  -- check AABB collisions of platform hitbox
  if aabb(blob, self) 
     and blob.vy>0 then
      -- landed
      return true
  end 
  return false
end

-- ------------------------------------------------------------
-- SPIKER platform type (no interaction)
--
do
  SpikerPlatform = BasePlatformObject:extend()

  function SpikerPlatform:new(x,y,spr_width)
    SpikerPlatform.super.new(self, x, y)

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

  function SpikerPlatform:update(dt)
    -- update base class/values
    SpikerPlatform.super.update(self, dt)

    -- update local stuff
  end

  function SpikerPlatform:draw()
    -- draw spikes
    spr((self.currState==self.activeState) and 16 or 17, self.x, self.y-32, self.spr_w, spr_h)
    -- draw (base) platform
    SpikerPlatform.super.draw(self)
  end

  function SpikerPlatform:setPressedState(is_pressed)
    -- log("setPressedState("..tostring(is_pressed)..")")
    -- call base implementation
    SpikerPlatform.super.setPressedState(self,is_pressed)

    -- check for spikes
    -- log(" - blob.onGround = "..tostring(blob.onGround))
    -- log(" - self.currState == self.activeState = "..tostring(self.currState == self.activeState))
    if blob.onGround
     and blob.onPlatform == self
     and self.currState == self.activeState then
      -- log("  > loseLife()")
      blob:loseLife()
    end
  end

  -- override "landed" test
  -- to also check for spikes
  function SpikerPlatform:hasLanded(blob)
    -- check for spikes
    if aabb(blob, self) and blob.vy>0 
     and self.currState == self.activeState then
      blob:loseLife()
    end 
    -- call base implementation
    return SpikerPlatform.super.hasLanded(self,blob)
  end

end

-- ------------------------------------------------------------
-- STATIC platform type (no interaction)
--
do
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

  function StaticPlatform:setPressedState(is_pressed)
    -- call base implementation
    StaticPlatform.super.setPressedState(self,is_pressed)
  end

end