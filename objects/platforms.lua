
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
    -- call base implementation
    SpikerPlatform.super.setPressedState(self,is_pressed)
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