--
-- Constants
--
DEBUG_MODE = false

GAME_WIDTH_LANDSCAPE = 256  -- 16:9 aspect ratio
GAME_HEIGHT_LANDSCAPE = 144 -- (Landscape)
GAME_WIDTH_PORTRAIT = 144   -- 16:9 aspect ratio
GAME_HEIGHT_PORTRAIT = 256  -- (Portrait, for mobiles)
GAME_SCALE = 3

GAME_STATE = { SPLASH=0, TITLE=1, INFO=2, LVL_INTRO=3, LVL_PLAY=4, LVL_END=5, 
               LOSE_LIFE=6, GAME_OVER=7, COMPLETED=8 }

PLATFORM_TYPE = { STATIC=1, SPIKER=2, SLIDER=3, BLOCKER=4, SPRINGER=5, FLOATER=6 }

-- Andrew Kensler (+another black!)
-- https://lospec.com/palette-list/andrew-kensler-54
ak54 = {
  0x000000, 0x05fec1, 0x32af87, 0x387261,  
  0x000000, 0x1c332a, 0x2a5219, 0x2d8430, 
  0x00b716, 0x50fe34, 0xa2d18e, 0x84926c, 
  0xaabab3, 0xcdfff1, 0x05dcdd, 0x499faa, 
  0x2f6d82, 0x3894d7, 0x78cef8, 0xbbc6ec, 
  0x8e8cfd, 0x1f64f4, 0x25477e, 0x72629f, 
  0xa48db5, 0xf5b8f4, 0xdf6ff1, 0xa831ee, 
  0x3610e3, 0x241267, 0x7f2387, 0x471a3a, 
  0x93274e, 0x976877, 0xe57ea3, 0xd5309d, 
  0xdd385a, 0xf28071, 0xee2911, 0x9e281f, 
  0x4e211a, 0x5b5058, 0x5e4d28, 0x7e751a, 
  0xa2af22, 0xe0f53f, 0xfffbc6, 0xffffff, 
  0xdfb9ba, 0xab8c76, 0xeec191, 0xc19029, 
  0xf8cb1a, 0xea7924, 0xa15e30, 0x10082e
  -- custom colours
}


--
-- Globals
--
ON_MOBILE = castle and not castle.system.isDesktop()

GAME_WIDTH = GAME_WIDTH_PORTRAIT     -- default to portrait/mobile
GAME_HEIGHT = GAME_HEIGHT_PORTRAIT   -- (will update automatically to screen rotation)


-- Helper functions

function aabb(a,b)
  return (
    a.x < b.x + b.hitbox_w 
    and a.x + a.hitbox_w > b.x 
    and a.y < b.y + b.hitbox_h 
    and a.y + a.hitbox_h > b.y
  )
end

function addTween(tween)
  table.insert( tweens, tween )
end