-- globals
_t = 0
blob = {}
cam = {}
--platforms = {} -- init/clear platforms
lastPressedState = false
maxTypeNumber = 4
gameCounter = 0 -- used for countdown delays at end/start of levels
tweens = {}

function init_game()
  -- only perform core init once
  if not _initialized then
    init_sugarcoat()  
    init_assets()
    init_input()
    on_resize()
  end
  _initialized = true

  -- create platform definitions
  platformDefs = {
    { type = PLATFORM_TYPE.SPIKER,  odds = 0.5,  unlockAt=0 },  -- unlocked=true?
    { type = PLATFORM_TYPE.SLIDER,  odds = 0.25, unlockAt=11 },
    { type = PLATFORM_TYPE.BLOCKER, odds = 0.25, unlockAt=14 },
    { type = PLATFORM_TYPE.TRIPLESPIKER, odds = 0.95, unlockAt=20 },
  }
  -- init/clear platforms
  platforms = {}

  
  init_blob()
  
  init_section(1) -- level/section
  --init_section(2) -- level/section

  -- reposition blob at start
  reset_blob()
  
  init_cam()
  

  -- show the title
  --init_title()

  Sounds.music = Sound:new('Jump Music Level 1 Game Loop.ogg', 1)
  Sounds.music:setVolume(1)
  Sounds.music:setLooping(true)
  Sounds.music:play()
  --
  -- Sounds.music:playWithPitch(1)
  -- local tr2 = 1.0594630943592952645
  -- Sounds.music:playWithPitch(1 * (tr2 ^ 1))
end

-- create initial platforms & reset blobby
function init_section(sectionNum)  
  debug_log("init_section="..sectionNum)
  blob.startPlatformNum = 0
  -- calc starting platform number (index)
  for i=1,sectionNum do
    blob.startPlatformNum = blob.startPlatformNum + ((i>1) and (5+((i-1)*3)) or 1)
  end
  debug_log("blob.startPlatformNum... = "..blob.startPlatformNum)
  -- create "floor" platform
  --TODO: if level num > 1 then have diff static type (as resuming)
  if platforms[1] == nil then
    local ypos = GAME_HEIGHT+PLATFORM_DIST_Y-(blob.startPlatformNum*PLATFORM_DIST_Y)
    platforms[1] = StaticPlatform(-56, ypos, 8)
    platforms[1].num = blob.startPlatformNum
  end
  
  -- set the level/section num
  blob.levelNum = sectionNum
  -- set the total num platforms for this level/section
  blob.numPlatforms = 5+(sectionNum*3)
  debug_log("blob.numPlatforms... = "..blob.numPlatforms)
  if blob.platformCounter <= 1 then
    blob.platformCounter = blob.startPlatformNum
  end

  -- generate any missing platforms (and clear old ones)
  generate_platforms()
  
  
  --
  -- show intro / popup
  --
  init_level_intro()
end

function init_level_intro()
  gameState = GAME_STATE.LVL_INTRO
  gameCounter = 0

  init_popup()
end

function init_level_end()
  gameState = GAME_STATE.LVL_END
  gameCounter = 0

  -- TODO: review speed-ups and new platform messages, etc.
  
  -- any announcements? (speed, platform, tips)

  -- speed up?
  local speedup_levels={2,4,6}
  if has_value(speedup_levels, blob.levelNum) then
    blob.speedFactor = min(blob.speedFactor + 0.25, 2.5)
    -- announce speed-up
    local speedUpNum = table.indexOf(speedup_levels, blob.levelNum)
    init_popup(1, speedUpNum) -- 1 = speedup msg
    -- TODO: speed up music (switch track to next speed music)
  end   
  log("blob.speedFactor = "..blob.speedFactor)
  
  -- new platforms?
  for pDef in all(platformDefs) do
    if pDef.unlockAt == blob.levelNum then
      -- announce platform
      init_popup(2, pDef.type) -- 2 = platform msg
    end
  end

  -- TODO: tips?
  
end

function init_popup(info_type, info_value)
  -- [info_types]
  -- 1 = speed-ups, 2 = platforms

  popup = {
    -- x = GAME_WIDTH/2,
    -- y = GAME_HEIGHT/2,
    sx = 0,
    sy = 0,
    -- width = 0,
    -- height = 0,
    spr_content = 0
  }
  
  addTween(
    tween.new(
      1, popup, 
      {sx = 1, 
       sy = 1}, 
      'outElastic'
      -- function(self)
      --   log("complete!!!!")
      -- end
    )
  )
end

function hide_popup()
  hiding_popup = true
  addTween(
    tween.new(
      0.5, popup, 
      {sx = 0, 
       sy = 0}, 
      'inBack',
      function(self)
        log(">>complete!!!!")
        -- start section
        gameState = GAME_STATE.LVL_INTRO2
        gameCounter = 0
        popup = nil
        hiding_popup = false
      end)
  )
end
  
-- create & return a random platform
function createNewPlatform(platformNum)
  
  
  -- seed rng for platform
  srand(platformNum)

  
  local xpos = pick(PLATFORM_POSITIONS)
  local ypos = GAME_HEIGHT+PLATFORM_DIST_Y-(platformNum*PLATFORM_DIST_Y)
  local prevPlatform = platforms[#platforms]
  
  -- check for end of level/section
  if platformNum == blob.startPlatformNum + blob.numPlatforms then
    -- create a landing platform for checkpoint
    --TODO: maybe change the platform look/style?
    local checkPoint = StaticPlatform(-56, ypos, 8)
    checkPoint.isCheckpoint = true
    return checkPoint
  end
  
  -- randomly select a platform type (based on those unlocked)
  local newPlatform = nil
  while newPlatform == nil do
    -- pick a platform type
    local pDef = pick(platformDefs)

    -- rigged!!
    --pDef.type = PLATFORM_TYPE.TRIPLESPIKER

    -- BASIC checks
    -- is platform unlocked yet? (platform number, NOT level)
    if pDef.unlockAt > platformNum then goto continue end
    -- did we meet the odds?
    if rnd(1) > pDef.odds then goto continue end

    -- ADVANCED checks

    -- REMOVED Static from RNG, as "inactive Spiker" is same!
    -- if pType == PLATFORM_TYPE.STATIC then
    --   return StaticPlatform(xpos, ypos, 1)
    ------------------------------------------------
    if pDef.type == PLATFORM_TYPE.SPIKER then    
    ------------------------------------------------
      newPlatform = SpikerPlatform(xpos, ypos, 1)

    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.SLIDER then
    ------------------------------------------------

      newPlatform = SliderPlatform(56, ypos, 1)
    
    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.BLOCKER 
    ------------------------------------------------
      and #platforms < blob.startPlatformNum + blob.numPlatforms 
      and platforms[#platforms].type ~= PLATFORM_TYPE.BLOCKER then
        -- no "double blockers" and no blocker as the final platform
        newPlatform = BlockerPlatform(-56, ypos, 8)

        -- be nice to player for early levels
        -- (don't have "blocker" above a "spiker")
        if (platformNum < 20 and prevPlatform.type == PLATFORM_TYPE.SPIKER)
           or (platformNum < 50 and prevPlatform.type == PLATFORM_TYPE.TRIPLESPIKER)
         then
          -- replace "spiker" with a "static"
          log("> replaced spiker with a static!")
          platforms[#platforms] = StaticPlatform(prevPlatform.x, prevPlatform.y, 1)
          platforms[#platforms].num = prevPlatform.num
        end
    
    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.TRIPLESPIKER then
    ------------------------------------------------
      -- create three spikers (Blobby will only jump on ONE of them)
      newPlatform = TripleSpikerPlatform(xpos, ypos, 1)
  
    else
      -- do nothing - let it loop again
    end

    ::continue::    
  end

  -- debug_log("newPlatform.type == "..tostring(newPlatform.type))
  -- debug_log("#platforms == "..tostring(#platforms))
  -- -- DEBUG:
  -- for k,p in pairs(platforms) do
  --   debug_log(" - ["..k.."|"..tostring(p.num).."]="..p.type)
  -- end

  -- finally, return new platform
  return newPlatform
end

-- create & initialise blob obj 
-- (will be positioned later)
function init_blob()
  blob = {
    lives = 3,
    score = 0,       -- essentially the platform num?
    levelNum = 0,    -- ...this gets set in init_section()
    speedFactor = 1, -- will increase (up to 2.5?) as game progresses
    hitbox_w = 32,
    hitbox_h = 32,
    jumpFreq = 10,
    numPlatforms = 0, -- number of platforms for the current section
    platformCounter = 1, -- running counter of platform gen numbers
    onPlatformNum = 1,
    startPlatformNum = 1,

    loseLife = function(self)
      debug_log("OUCH!!!!")
      self.lives = self.lives - 1
      cls(38) flip()
      -- game over?
      if self.lives <= 0 then
        gameState = GAME_STATE.GAME_OVER      
        gameCounter = 0
      end
    end
  }
end

-- reset blob back to starting position
-- (either start of game or section)
function reset_blob()
  blob.x = GAME_WIDTH/2 - 16     -- start in the middle
  blob.y = platforms[1].y - 32
  --blob.y = GAME_HEIGHT-40   -- start near the bottom (on starting platform)
  blob.maxHeight = blob.y-40
  --blob.maxHeight = GAME_HEIGHT-40
  blob.vy = 0     -- y velocity
  blob.vx = 0     -- x velocity
  blob.state = 0  -- 0=start, 1=jumping, 2=flying, 3=landing?
  blob.onGround = false
  blob.jumpCounter = 0
  blob.lastCheckpointPlatNum = 1
end

function init_cam()
  -- TODO: initialise camera object (smooth panning camera)
  cam = {
    x = 0,
    y = blob.maxHeight-GAME_HEIGHT/2,
    --y = platforms[1].y - GAME_HEIGHT/2,
    
    trap_y = GAME_HEIGHT/2
    --trap_y = GAME_HEIGHT/2
  }
end

function init_sugarcoat()
  init_sugar("J.U.M.P.", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  -- start with splash screen palette 
  --load_png("splash", "assets/splash.png", palettes.pico8, true)

  use_palette(ak54)
  load_font ("assets/gomarice_gogono_cocoa_mochi.ttf", 26, "main-font", true)
  --load_font ("assets/PublicSans-Black.otf", 21, "main-font", true)
  --load_font ("assets/Awesome.ttf", 32, "main-font", true)
  -- load_png("title", "assets/title-text.png", ak54, true)
  screen_resizeable(true, 2, on_resize)
  screen_render_integer_scale(false)
  set_frame_waiting(60)

   -- Get User info  
   me = castle.user.getMe()    
   my_id = me.userId
   my_name = me.username
   -- get photo
   if me.photoUrl then
     load_png("photo", me.photoUrl, ak54) 
   end
   
  -- init splash
  -- gameState = GAME_STATE.SPLASH 
  -- use_palette(palettes.pico8)
  -- splashStartTime = t()
end

function init_assets()
  -- load gfx
  load_png("spritesheet", "assets/spritesheet.png", ak54, true)
  load_png("popups", "assets/popups.png", ak54)
  spritesheet_grid(32,32)
  
  -- todo: load sfx + music
  --init_sounds()
end

function init_input()
  -- keyboard & gamepad input
  -- register_btn(0, 0, {input_id("keyboard", "left"),
  --                     input_id("keyboard", "a"),
  --                     input_id("controller_button", "dpleft")})
  -- register_btn(1, 0, {input_id("keyboard", "right"),
  --                     input_id("keyboard", "d"),
  --                     input_id("controller_button", "dpright")})
  -- register_btn(2, 0, {input_id("keyboard", "up"),
  --                     input_id("keyboard", "w"),
  --                     input_id("controller_button", "dpup")})
  -- register_btn(3, 0, {input_id("keyboard", "down"),
  --                     input_id("keyboard", "s"),
  --                    input_id("controller_button", "dpdown")})
  register_btn(4, 0, {input_id("keyboard", "space"),
                      input_id("controller_button", "x")})
  -- mouse input
  register_btn(5,  0, input_id("mouse_position", "x"))
  register_btn(6,  0, input_id("mouse_position", "y"))
  register_btn(7,  0, input_id("mouse_button", "lb"))


end