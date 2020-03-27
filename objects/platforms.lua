
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
    debug_log("self.activeState="..tostring(self.activeState))
    -- default to false state (could be active or inactive)
    self.currState = currPressedState --false    
    self.completed = false        -- lit up when blobby has landed (on most blocks)
  end
  function BasePlatformObject:update(dt)
    -- anything?
  end
  function BasePlatformObject:draw()
    -- if visited?
    if self.completed then
      pal(13,9)
      pal(24,10)
      pal(41,7)
    end

    -- anything?
    spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true)

    -- if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
  end
  -- base state switcher (e.g. on "press")
  -- most platforms will override this
  function BasePlatformObject:setPressedState(is_pressed)
    self.currState = is_pressed
    --debug_log("setPressedState = "..tostring(is_pressed))
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
  function BasePlatformObject:setCompleted(is_completed)
    self.completed = is_completed
  end
end

-- ------------------------------------------------------------
-- SIDESWITCHER platform type (switches left/right on press)
--
do
  SLIDER_MAX_MOVEMENT = 200
  SideSwitcherPlatform = BasePlatformObject:extend()

  function SideSwitcherPlatform:new(x,y,spr_width)
    SideSwitcherPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.SIDESWITCHER
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32
    
    -- randomise current state
    self.currState = irnd(2)==0

    self.side = (self.activeState) and 1 or 3 -- 1=left, 3=right
    self.x = PLATFORM_POSITIONS[self.side]
    
    if self.side == 1 then
      self.openAmount = (self.currState==self.activeState) 
                          and SLIDER_MAX_MOVEMENT or 0
    else
      self.openAmount = (self.currState==self.activeState) 
                          and 0 or SLIDER_MAX_MOVEMENT
    end

    -- self.openAmount = (self.currState==self.activeState) 
    --                      and 0 or SLIDER_MAX_MOVEMENT
    -- self.openAmount = (self.currState==self.activeState) 
    --                      and 0 or SLIDER_MAX_OPEN_AMOUNT

    -- log("self.side = "..self.side)
    -- log("self.x = "..self.x)
    -- log("self.openAmount = "..self.openAmount)

    self.id = irnd(100000)
  end



  function SideSwitcherPlatform:update(dt)
    -- update base class/values
    SideSwitcherPlatform.super.update(self, dt)

    -- is blob near this platform?
    if blob.y+32 >= self.y-5 and blob.y+32<=self.y+16 
     and not blob.onGround then
      -- landed?    
      if self:hasLanded(blob) then
        -- landed
        debug_log("landed!!")
        blob.onGround = true
        -- were we hurt?
        if blob.vy > 500 then
          blob:loseLife()
        end
        blob.vy = 0
        blob.y = self.y-32
      else
        blob.onGround = false
      end

    end
  end

  function SideSwitcherPlatform:draw()
    
    -- if visited?
    if self.completed then
      pal(13,9)
      pal(19,10)
      pal(24,8)
      pal(41,7)
    else
      -- dark grey
      pal(19,33)
      pal(24,33)
    end

    -- draw left "door"
    x = (GAME_WIDTH/2) - 263 + self.openAmount
    spr(11, x, self.y, 1, self.spr_h)
    for i=1,4 do
      x = x - 32
      spr(10, x, self.y, 1, self.spr_h)
    end
    -- draw right "door"
    x = (GAME_WIDTH) + -40 + self.openAmount
    spr(12, x, self.y, 1, self.spr_h)
    for i=1,4 do
      x = x + 32
      spr(13, x, self.y, 1, self.spr_h)
    end

    -- if DEBUG_MODE then 
    --   use_font ("small-font")
    --   local tx=self.x
    --   pprint("C:"..tostring(self.currState), tx,self.y-60,7) 
    --   pprint("A:"..tostring(self.activeState), tx,self.y-48,7) 
    --   pprint("=:"..tostring(self.currState==self.activeState), tx,self.y-36,7) 
    --   pprint("O:"..tostring(flr(self.openAmount)), tx,self.y-24,9) 
    --   pprint("S:"..tostring(self.sectionNum), tx,self.y-12,7) 
    --   use_font ("main-font")
    -- end


    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true) 

    -- draw (base) platform?
    --SideSwitcherPlatform.super.draw(self)
  end

  function SideSwitcherPlatform:setPressedState(is_pressed)      
    -- abort on completed?
    if self.completed then 
      return
    end
    
    self.currState = not self.currState
    
    -- NOTE: Slider movement will happen in update   
    addTween(
      tween.new(
        0.3, self, 
        {openAmount = (not self.currState) and 0 or SLIDER_MAX_MOVEMENT}, 
        'outCirc')
    )
  end

  -- override "landed" test
  -- to also check for spikes
  function SideSwitcherPlatform:hasLanded(blob)
    -- check for landed
    -- landed?
    if 
     blob.y+32 >= self.y-5 and blob.y+32<=self.y+16
     and blob.vy>=0 
     and self.currState == self.activeState 
     --and self.openAmount < 40
    then
      -- landed
      return true
    end
    
    return false -- landing handled in update!
  end

  function SideSwitcherPlatform:setCompleted(is_completed)
    self.completed = true
    self.currState = true
    self.activeState = true
  end

end

-- ------------------------------------------------------------
-- SPRINGER platform type (boosts player on activation - if close enough)
--
do
  SpringerPlatform = BasePlatformObject:extend()

  function SpringerPlatform:new(x,y,spr_width)
    SpringerPlatform.super.new(self, x, y)

    self.currState = false
    self.activeState = true
    self.type = PLATFORM_TYPE.SPRINGER
    self.spr = 9
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32

    -- self:Reset()
  end

  function SpringerPlatform:update(dt)
    -- update base class/values
    SpringerPlatform.super.update(self, dt)

    -- update local stuff
  end

  function SpringerPlatform:draw()
    -- (draw everything offset down a bit - top of spring is platform)
    local yoff = -32
    -- draw springer
    spr((self.currState==self.activeState) and 25 or 24, self.x, self.y+yoff, self.spr_w, spr_h)
    
    -- if visited?
    if self.completed then
      pal(13,9)
      pal(19,10)
      pal(41,78)
    end

    -- draw (base) platform
    spr(self.spr - (self.completed and 1 or 0), 
       self.x, self.y+yoff+32, self.spr_w, self.spr_h)

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true) 

    --  if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
    -- pprint(tostring(self.currState), 
    --   self.x+50,self.y,7)
  end

  function SpringerPlatform:setPressedState(is_pressed)
    -- call base implementation
    --SpringerPlatform.super.setPressedState(self,is_pressed)
    
    local dist = distance( blob.x, blob.y+32, self.x, self.y )
    -- one-time activation
    -- (only activate if pressed while on-screen)
    if not self.currState
     and dist < 100
     and is_pressed then 
      self.currState = is_pressed

      --log(dist)
      -- close enough to perform boost?
      if dist < 30 and dist > 0 then
        -- adjust score/platform, depending on state
        if blob.onPlatform ~= self then
          -- "land"
          blob.onPlatformNum = blob.onPlatformNum + blob.lastJumpPlatformCount
          -- log("blob.onPlatformNum = "..tostring(blob.onPlatformNum))
          -- log("blob.lastJumpPlatformCount = "..tostring(blob.lastJumpPlatformCount))
          blob.onPlatform = self
          blob.onPlatform.completed = true
          blob.score = blob.score + blob.lastJumpPlatformCount

          blob.vy = 0
          blob.x = self.x + (self.spr_w*32/2) - 16
          blob.y = self.y - 48

          -- generate new platforms (and clear old ones)
          generate_platforms()

          -- launch Blobby higher than usual (3 platforms)
          jump_blob(3)

          -- play sfx
          pick(sounds.boings):play()
        end
      end
    end

    -- (v1) - requires being ON platform
    -- if blob.onGround
    --  and blob.onPlatform == self
    --  and self.currState == self.activeState then
    --   -- launch Blobby higher than usual (3 platforms)
    --   jump_blob(3)
    -- end
  end

  -- override "landed" test
  -- to also check for spikes
  function SpringerPlatform:hasLanded(blob)
    -- check for spikes
    -- if aabb(blob, self) and blob.vy>0 
    --  and self.currState == self.activeState then
    --   blob:loseLife()
    -- end 
    -- call base implementation
    return SpringerPlatform.super.hasLanded(self,blob)
  end

end

-- ------------------------------------------------------------
-- BLOCKER platform type (breaks on interation)
--
do
  BlockerPlatform = BasePlatformObject:extend()

  function BlockerPlatform:new(x, y, spr_width, hitsLeft)
    BlockerPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.BLOCKER
    self.spr = (spr_width==1) and (8 + irnd(2)) or 32
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32

    self.activeState = true -- default to active "blocking"
    self.hitsLeft = hitsLeft or 1 -- number of hits left to break block   
    
    -- explosion
    self.pieces = {}
  end

  function BlockerPlatform:update(dt)
    -- update base class/values
    BlockerPlatform.super.update(self, dt)

    -- check for collisions (e.g. jumping "into" it)
    if aabb(blob, self) 
      and self.activeState 
     then
      -- are we "boosting"?
      if blob.lastJumpPlatformCount > 2 then
        -- explode now
        self.hitsLeft = 0
        self.activeState = false        
        self:explode()
      else
        -- block!      
        blob.vy = 0
        blob.y = self.y + 33
        blob.onGround = false
      end
    end

    -- update explosion?
    if not self.activeState then
      self:updatePieces(dt)
    end
  end

  function BlockerPlatform:draw()
    -- pal swap
    for i=1,17 do
      pal(i,self.flash and 47 or 54)
      --pal(i,54)
    end
    if self.activeState then      
      if self.hitsLeft > 1 then 
        -- hide cracks
        pal(42,54)
      end
      -- draw blocker (left-half)
      spr(18, self.x -64, self.y, 6, spr_h)
      -- draw blocker (right-half)
      spr(18, self.x + 128, self.y, 6, spr_h, false, false)
    else
      -- draw exploding pieces
      self:drawPieces()
    end
    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true)   
    self.flash = false

    -- if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
    -- draw (base) platform
    --BlockerPlatform.super.draw(self)
  end

  function BlockerPlatform:createPiece(main_col,rox,roy)
    -- create a single piece
    local piece = {
      x = self.x + rox,
      y = self.y + roy,
      a = 0,
      dx = rnd(200)-100,
      dy = -rnd(250),
      da = rnd(2)-1,
      col = main_col,
      rox = (rox/192), -- rotation origin x-pos
      roy = (roy/32),  -- rotation origin y-pos
    }
    return piece
  end

  function BlockerPlatform:explode()
    -- Create separate piece objects & palt() to only show main seg
    table.insert( self.pieces, self:createPiece(1, 9,15) )
    table.insert( self.pieces, self:createPiece(2, 36,14) )
    table.insert( self.pieces, self:createPiece(3, 68,7) )
    table.insert( self.pieces, self:createPiece(5, 65,24) )
    table.insert( self.pieces, self:createPiece(6, 100,13) )
    table.insert( self.pieces, self:createPiece(7, 122,18) )
    table.insert( self.pieces, self:createPiece(8, 142,21) )
    table.insert( self.pieces, self:createPiece(9, 164,14) )
    table.insert( self.pieces, self:createPiece(10,188,10) )
    table.insert( self.pieces, self:createPiece(11,183,26) )
    table.insert( self.pieces, self:createPiece(12,87,3) )
    table.insert( self.pieces, self:createPiece(13,131,4) )
    table.insert( self.pieces, self:createPiece(14,144,3) )
    table.insert( self.pieces, self:createPiece(15,134,28) )
    table.insert( self.pieces, self:createPiece(16,16,2) )
    table.insert( self.pieces, self:createPiece(17, 90,24) )
    -- play sfx
    sounds.breaking:play()
  end

  function BlockerPlatform:updatePieces(dt)
    local gravity = 400
    -- Draw separate piece using palt() to only show main seg
    for key, piece in pairs(self.pieces) do
      piece.x = piece.x + piece.dx *dt
      piece.dy = piece.dy + gravity *dt
      piece.y = piece.y + piece.dy *dt  -- gravity
      piece.a = piece.a + piece.da *dt  -- spin

      -- remove pieces that fall past screen
      if piece.y > cam.y+GAME_HEIGHT+100 then
        table.remove(self.pieces, key)
      end
    end
  end

  function BlockerPlatform:drawPieces()
    -- Draw separate piece using palt() to only show main seg
    for key, piece in pairs(self.pieces) do      
      -- set color trans to single segment      
      for i=1,17 do
        if i==piece.col then 
          pal(i,54)
        else
          palt(i,true) 
        end
      end
      palt(40,true) 
      palt(42,true) 
      palt(50,true) 

      -- draw piece L+R (shadow)
      pal(piece.col,40)
      aspr(18, piece.x-63, piece.y+1, piece.a, 6,1, piece.rox,piece.roy)
      aspr(18, piece.x+127, piece.y+1, piece.a, 6,1, piece.rox,piece.roy)
      -- draw piece L+R (shadow)
      pal(piece.col,self.flash and 47 or 54)
      aspr(18, piece.x-64, piece.y, piece.a, 6,1, piece.rox,piece.roy)
      aspr(18, piece.x+128, piece.y, piece.a, 6,1, piece.rox,piece.roy)

      -- reset palette
      pal()
      palt()
      palt(0, false)
      palt(35,true)
    end
  end

  function BlockerPlatform:setPressedState(is_pressed)
    -- call base implementation
    BlockerPlatform.super.setPressedState(self,is_pressed)    
    
    -- smash block (only if visible)?    
    if is_pressed
     and self.y > cam.y
     and self.sectionNum == blob.levelNum
     and self.hitsLeft > 0 then
      -- register a hit
      self.hitsLeft = self.hitsLeft - 1
      -- shake blocker
      -- addTween(
      --   tween.new(
      --     0.3, self, 
      --     {y = self.y}, 
      --     'inOutBack')
      -- )
      self.flash = true
      -- have we destroyed it?
      if self.hitsLeft <= 0 then
        -- destroy blocker        
        self.activeState = false
        -- TODO: particles here?
        self:explode()
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
do
  SLIDER_MAX_OPEN_AMOUNT = 64
  SliderPlatform = BasePlatformObject:extend()

  function SliderPlatform:new(x,y,spr_width)
    -- QUESTION: ignore the x pos?
    SliderPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.SLIDER
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
      then
        -- landed
        blob.onGround = true
        -- were we hurt?
        if blob.vy > 500 then
          blob:loseLife()
        end
        blob.vy = 0
        blob.y = self.y-32
      else
        blob.onGround = false
      end

    end
  end
  
  function SliderPlatform:draw()

    -- if visited?
    if self.completed then
      pal(13,9)
      pal(19,10)
      pal(24,8)
      pal(41,7)
    end

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

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true) 

    -- if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end

    -- draw (base) platform?
    --SliderPlatform.super.draw(self)
  end

  function SliderPlatform:setPressedState(is_pressed)    
    -- abort on completed?
    if self.completed then 
      return
    end
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
      -- debug_log("landed!!")
      -- blob.onGround = true
      -- blob.vy = 0
      -- blob.y = self.y-32
    --else
      --blob.onGround = false
    end
    
    return false -- landing handled in update!
  end

  function SliderPlatform:setCompleted(is_completed)
    self.completed = true
    self.currState = true
    self.activeState = true
  end

end

-- ------------------------------------------------------------
-- SPIKER platform type (toggles on activation)
--
do
  SpikerPlatform = BasePlatformObject:extend()

  function SpikerPlatform:new(x,y,spr_width)
    SpikerPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.SPIKER
    self.spr = 9 --(8 + irnd(2))
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
    
    -- if visited?
    if self.completed then
      pal(13,9)
      pal(24,10)
      pal(41,7)
    end

    -- draw (base) platform
    spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true) 

    --  if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
    --SpikerPlatform.super.draw(self)
  end

  function SpikerPlatform:setPressedState(is_pressed)
    -- abort on completed?
    if self.completed then 
      return
    end
    
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
     and blob.vy < 500 -- only lose life if not fallen too far (dont want to lose 2 lives!)
     and self.currState == self.activeState then
      blob:loseLife()
    end 

    -- call base implementation
    return SpikerPlatform.super.hasLanded(self,blob)
  end

  function SpikerPlatform:setCompleted(is_completed)
    self.completed = true
    self.currState = false
    self.activeState = true
  end

end

-- ------------------------------------------------------------
-- TRIPLESPIKER platform type (toggles on activation)
--
do
  TripleSpikerPlatform = SpikerPlatform:extend()

  function TripleSpikerPlatform:new(x,y,spr_width)
    TripleSpikerPlatform.super.new(self, x, y, spr_width)

    self.type = PLATFORM_TYPE.TRIPLESPIKER
    self.spr_w = spr_width
  end

  function TripleSpikerPlatform:update(dt)
    -- update base class/values
    TripleSpikerPlatform.super.update(self, dt)

    -- update local stuff    
  end

  function TripleSpikerPlatform:draw()
    -- draw spikes
    spr((self.currState==self.activeState) and 16 or 17, self.x, self.y-32, self.spr_w, spr_h)
    
    -- if visited?
    if self.completed then
      pal(13,9)
      pal(24,10)
      pal(41,7)
    end

    -- draw (base) platform
    spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true) 

    -- draw decoys
    for i=1,3 do
      local xpos = PLATFORM_POSITIONS[i]
      if self.x ~= xpos then
        -- draw spikes
        spr((self.currState~=self.activeState) and 16 or 17, xpos, self.y-32, self.spr_w, spr_h)
        
        -- if visited?
        if self.completed then
          pal(13,9)
          pal(24,10)
          pal(41,7)
        end
        -- draw (base) platform
        spr(self.spr, xpos, self.y, self.spr_w, self.spr_h)

        -- reset palette
        pal()
        palt()
        palt(0, false)
        palt(35,true)
      end
    end

    -- if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
  end

  function TripleSpikerPlatform:setPressedState(is_pressed)
    -- call base implementation
    TripleSpikerPlatform.super.setPressedState(self,is_pressed)
  end

  -- override "landed" test
  -- to also check for spikes
  function TripleSpikerPlatform:hasLanded(blob)
    -- call base implementation
    return TripleSpikerPlatform.super.hasLanded(self,blob)
  end

end

-- ------------------------------------------------------------
-- STATIC platform type (no interaction)
--
do
  StaticPlatform = BasePlatformObject:extend()

  function StaticPlatform:new(x,y,spr_width)
    StaticPlatform.super.new(self, x, y)

    self.type = PLATFORM_TYPE.STATIC
    self.spr = (spr_width==1) and (8 + irnd(2)) or 32
    self.spr_w = spr_width
    self.spr_h = 1
    self.hitbox_w = 32*spr_width
    self.hitbox_h = 32
    self.isCheckpoint = false -- is this a checkpoint?
    self.checkpointReached = false   -- (checkpoint state)
    self.gapSide = 0 -- (0=no gap, 1=left, 2=right)
  end

  function StaticPlatform:update(dt)
    -- update base class/values
    StaticPlatform.super.update(self, dt)

    -- update local stuff
  end

  function StaticPlatform:draw()
    local offset = 0
    if self.gapSide == 1 then offset=offset+100 end
    if self.gapSide == 2 then offset=offset-100 end

    -- if visited?
    if self.completed 
     and self.num ~= blob.startPlatformNum
     and not self.isCheckpoint
    then
      pal(13,9)
      pal(24,10)
      pal(19,10)
      pal(41,7)
    end

    spr(self.spr, self.x + offset, self.y, self.spr_w, self.spr_h)
    -- draw base class/values
    --StaticPlatform.super.draw(self)

    -- draw local stuff
    if self.isCheckpoint then
      -- flag state?
      if self.checkpointReached then
        pal(5,9)
        pal(6,8)
      end
      -- draw checkpoint flag
      if self.gapSide ~= 1 then
        -- left
        spr(29, self.x+80, self.y-32)
      else
        -- right
        spr(29, self.x+150, self.y-32)
      end
          
    end

    -- reset palette
    pal()
    palt()
    palt(0, false)
    palt(35,true)  

    -- draw level number
    if self.spr_w~=1 and gameState ~= GAME_STATE.TITLE then
      if self.gapSide ~= 1 then
        print(self.sectionNum, self.x+58, self.y+5, 24)
      else
        print(self.sectionNum, self.x+172, self.y+5, 24)
      end
    end

    -- if DEBUG_MODE then pprint(tostring(self.sectionNum), 
    --   self.x+50,self.y,7) end
  end

  function StaticPlatform:setPressedState(is_pressed)
    -- call base implementation
    StaticPlatform.super.setPressedState(self,is_pressed)
  end

end