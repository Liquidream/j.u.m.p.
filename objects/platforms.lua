
-- Defines all the platform object types

-- ------------------------------------------------------------
-- Base platform properties, shared by all platforms, etc.
--
do
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
    spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)
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
end

-- ------------------------------------------------------------
-- BLOCKER platform type (breaks on interation)
--
do
  BlockerPlatform = BasePlatformObject:extend()

  function BlockerPlatform:new(x,y,spr_width)
    BlockerPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.BLOCKER
      -- 1 = solid block
      -- 2 = spikers
      -- 3 = blockers
      -- 4 = springers
      -- 5 = floaters

    self.spr = (spr_width==1) and (8 + irnd(2)) or 32
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32

    self.activeState = true -- default to active "blocking"
    self.hitsLeft = 2       -- number of hits left to break block
    -- self:Reset()
  end

  function BlockerPlatform:update(dt)
    -- update base class/values
    BlockerPlatform.super.update(self, dt)

    -- check for collisions (e.g. jumping "into" it)
    if aabb(blob, self) 
      and self.activeState 
     then
      -- block!
      blob:loseLife()
      blob.vy = 0
      blob.y = self.y + 33
      blob.onGround = false
    end
  end

  function BlockerPlatform:draw()
    -- pal swap
    for i=1,16 do
      pal(i,54)
    end
    if self.activeState then      
      --if self.hitsLeft > 1 then pal(42,54) end
      if self.hitsLeft > 1 then pal(40,54) end
      -- draw blocker (left-half)
      spr(18, self.x -64, self.y, 6, spr_h)
      -- draw blocker (right-half)
      spr(18, self.x + 128, self.y, 6, spr_h, false, false)
      pal()
    end
    -- draw (base) platform
    --BlockerPlatform.super.draw(self)
  end

  local blockerPieces = {}

  function blockerExplode()
    --TODO: Create separate piece objects & palt() to only show main seg
  end

  function drawBlockerPieces()
    --TODO: Draw separate piece using palt() to only show main seg
  end

  function BlockerPlatform:setPressedState(is_pressed)
    -- call base implementation
    BlockerPlatform.super.setPressedState(self,is_pressed)    
    
    -- smash block (only if visible)?    
    if is_pressed
     and self.y > cam.y 
     and self.hitsLeft > 0 then
      log("smash "..self.y)
      -- register a hit
      self.hitsLeft = self.hitsLeft - 1
      -- have we destroyed it?
      if self.hitsLeft <= 0 then
        -- destroy blocker        
        -- TODO: particles here?
        self.activeState = false
      end
     end
  end


  -- override "landed" test
  -- to also check jumping "into"
  function BlockerPlatform:hasLanded(blob)
    -- can't land on this type
    -- call base implementation
    --return BlockerPlatform.super.hasLanded(self,blob)
  end

end

-- ------------------------------------------------------------
-- SLIDER platform type (closes/opens when activated)
--
SLIDER_MAX_OPEN_AMOUNT = 64
do
  SliderPlatform = BasePlatformObject:extend()

  function SliderPlatform:new(x,y,spr_width)
    -- QUESTION: ignore the x pos?
    SliderPlatform.super.new(self, x, y)

    self.type = 6
      -- 1 = solid block
      -- 2 = spikers
      -- 3 = floaters
      -- 4 = springers
      -- 5 = blockers
      -- 6 = sliders

    --self.spr = (spr_width==1) and (8 + irnd(2)) or 32
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32

    --self.openAmount = 0
     self.openAmount = (self.currState==self.activeState) 
                         and 0 or SLIDER_MAX_OPEN_AMOUNT   --0 to MAX

    self.id = irnd(100000)
  end



  function SliderPlatform:update(dt)
    -- update base class/values
    SliderPlatform.super.update(self, dt)

    -- is blob near this platform?
    if blob.y+32 >= self.y-5 and blob.y+32<=self.y+16 then
      -- landed?    
      if self:hasLanded(blob)
      -- blob.y+32 >= self.y-5 and blob.y+32<=self.y+16
      -- and blob.vy>=0 
      -- and self.currState == self.activeState 
      then
        -- landed
        --log("landed!!")
        blob.onGround = true
        blob.vy = 0
        blob.y = self.y-32
      else
        blob.onGround = false
      end

    end
  end

  function SliderPlatform:draw()
    -- draw left "door"
    x = (GAME_WIDTH/2) - 32 - self.openAmount
    spr(11, x, self.y, 1, self.spr_h)
    for i=1,4 do
      x = x - 32
      spr(10, x, self.y, 1, self.spr_h)
    end
    -- draw right "door"
    x = (GAME_WIDTH/2) + self.openAmount
    spr(12, x, self.y, 1, self.spr_h)
    for i=1,4 do
      x = x + 32
      spr(13, x, self.y, 1, self.spr_h)
    end
    -- draw (base) platform?
    --SliderPlatform.super.draw(self)
  end

  function SliderPlatform:setPressedState(is_pressed)
    -- call base implementation
    SliderPlatform.super.setPressedState(self,is_pressed)

    -- NOTE: Slider movement will happen in update   
    addTween(
      tween.new(
        0.3, self, 
        {openAmount = (self.currState==self.activeState) and 0 or SLIDER_MAX_OPEN_AMOUNT}, 
        'outCirc')
    )
  end

  -- override "landed" test
  -- to also check for spikes
  function SliderPlatform:hasLanded(blob)
    -- check for landed
    -- landed?
    if 
    --blob.y+32 >= self.y
    blob.y+32 >= self.y-5 and blob.y+32<=self.y+16
    and blob.vy>=0 
    and self.currState == self.activeState 
    and self.openAmount < 40
    then
      -- landed
      return true
      -- log("landed!!")
      -- blob.onGround = true
      -- blob.vy = 0
      -- blob.y = self.y-32
    --else
      --blob.onGround = false
    end

    -- if aabb(blob, self) 
    --   and blob.vy>0 
    --   and self.currState == self.activeState then
    --   return true
    -- else
    --   return false
    -- end 
    -- call base implementation
    --return SliderPlatform.super.hasLanded(self,blob)
    
    return false -- landing handled in update!
  end

end

-- ------------------------------------------------------------
-- SPIKER platform type (toggles on activation)
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

    -- check for spikes
    if blob.onGround
     and blob.onPlatform == self
     and self.currState == self.activeState then
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