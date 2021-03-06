--
-- Constants
--
DEBUG_MODE = false

GAME_WIDTH_LANDSCAPE = 256  -- 16:9 aspect ratio
GAME_HEIGHT_LANDSCAPE = 144 -- (Landscape)
GAME_WIDTH_PORTRAIT = 144   -- 16:9 aspect ratio
GAME_HEIGHT_PORTRAIT = 256  -- (Portrait, for mobiles)
GAME_SCALE = 3

GAME_STATE = { SPLASH=0, TITLE=1, INFO=2, LVL_INTRO=3, LVL_INTRO2=3.5, LVL_PLAY=4, LVL_END=5, 
               LOSE_LIFE=6, GAME_OVER=7, COMPLETED=8 }

PLATFORM_TYPE = { STATIC=0, 
                  SPIKER=1, SLIDER=2, BLOCKER=3, TRIPLESPIKER = 4,
                  SPRINGER=5, SIDESWITCHER=6 }
PLATFORM_POSITIONS = {5, 56, 107}
PLATFORM_DIST_Y = 150
PLATFORM_DEFS = {
  { type = PLATFORM_TYPE.SPIKER,  odds = 0.25,  atPlatform=1, announceAtLevel=1  },
  { type = PLATFORM_TYPE.SLIDER,  odds = 0.25, atPlatform=9, announceAtLevel=2 },
  { type = PLATFORM_TYPE.BLOCKER, odds = 0.25, atPlatform=34, announceAtLevel=4 },
  { type = PLATFORM_TYPE.TRIPLESPIKER, odds = 0.25, atPlatform=71, announceAtLevel=6  },
  { type = PLATFORM_TYPE.SIDESWITCHER, odds = 0.25, atPlatform=120, announceAtLevel=8  },
  { type = PLATFORM_TYPE.SPRINGER, odds = 0.25, atPlatform=149, announceAtLevel=9  },
}
SPEEDUP_LEVELS = {
--level, speed, playlist #
   [5] = {1.75, 1},
   [10]= {2,    2},
   [15]= {2.25, 3},
   [20]= {2.375,  4},
} 
-- (PREV) SPEEDUP_LEVELS = {
-- --level, speed, playlist #
--    [5] = {1.125, 1},
--    [10]= {1.25,  2},
--    [15]= {1.5,   3},
--    [20]= {1.75,  4},
-- } 


-- Andrew Kensler (+another black!)
-- https://lospec.com/palette-list/andrew-kensler-54
ak54 = {
  0x000000, 0x05fec1, 0x32af87, 0x387261,  
  0x010101, 0x1c332a, 0x2a5219, 0x2d8430, 
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

fadeBlackTable={
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
  {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
  {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
  {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
  {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
  {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
  {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
  {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
  {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
  {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
  {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
  {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
  {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
  {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
  {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
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

function distance( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function addTween(tween)
  table.insert( tweens, tween )
end

function debug_log(msg)
  if DEBUG_MODE then
    log(msg)
  end
end

function fade(i)
  for c=0,15 do
      if flr(i+1)>=16 or flr(i+1)<=0 then
          pal(c,0)
      else
          pal(c,fadeBlackTable[c+1][flr(i+1)])
      end
  end
end

function has_value(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end
  return false
end

--
-- https://gist.github.com/walterlua/978150/2742d9479cd5bfb3d08d90cfcb014da94021e271
--
function table.indexOf(t, object)
  if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

  for i, v in pairs(t) do
      if object == v then
          return i
      end
  end
end