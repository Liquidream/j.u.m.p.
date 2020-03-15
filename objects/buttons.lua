
-- Defines all the button object types

-- ------------------------------------------------------------
-- Base button properties, shared by all button types
--
do
  BaseButtonObject = Object:extend()
  -- base constructor
  function BaseButtonObject:new(x,y,text,funcOnClick,w,h,col,hcol,font)
    -- initialising
    self.x = x
    self.y = y
    self.text = text
    self.hovered = false
    -- cols?
    self.col = col or 17
    self.hcol = hcol or 47

    -- font?
    self.font = font or "main-font"
    -- auto-calc size?
    if w == nil then
      self.w = #text*15
      self.h = 24
    else      
      self.w = w
      self.h = h
    end
    -- hitbox
    self.hitbox_w = self.w
    self.hitbox_h = self.h

    -- event handlers
    self.onClick = funcOnClick or function()
      -- no base functionality
      debug_log("'"..tostring(self.text).."' button clicked")
    end
  end
  function BaseButtonObject:update(dt)
    -- collision detection
    self.hovered = false
    if aabb(cursor, self) then
      -- hovering
      self.hovered = true
    end
    -- clicked?
    if somethingPressed and self.hovered then
      somethingPressed = false
      self:onClick()      
    end
  end
  function BaseButtonObject:draw()
    use_font (self.font)
    if self.hovered then
      pprint(tostring(self.text), self.x,self.y, self.hovered and self.hcol or self.col)
    else    
      pprint_shiny(tostring(self.text), self.x,self.y,  21, 0, 17, 8,10)
    end
    --pprint(tostring(self.text), self.x,self.y, self.hovered and self.hcol or self.col)

    if DEBUG_MODE then 
      -- draw bounding box
      rect(self.x, self.y, self.x+self.hitbox_w, self.y+self.hitbox_h,36)
    end
  end
  
end
