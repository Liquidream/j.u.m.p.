-- globals
_t = 0
blob = {}
cam = {}
tweens = {}
sounds = {}
buttons = {} -- menu/other buttons
cursor = {}
lastPressedState = false
gameCounter = 0 -- used for countdown delays at end/start of levels
lastPlatformState = false
countOfSameStates = 0
-- shake tells how much to
-- shake the screen
shake=0
shake_x=0
shake_y=0

function init_cursor()
  -- re-show the mouse cursor 
  -- (for menu on Desktop)
  if not ON_MOBILE then    
    love.mouse.setVisible(true)
  end

  -- define cursor obj, for collision testing later
  cursor = {
    x = 0,
    y = 0,
    hitbox_w = 0,
    hitbox_h = 0,
  }
end


function init_title()  
  use_palette(ak54)
  
  gameState = GAME_STATE.TITLE

  -- init mouse/touch controls
  init_cursor()

  -- -- reset menu buttons
  buttons = {}

  -- create platform definitions   
  last_xpos = PLATFORM_POSITIONS[2]
  -- init/clear platforms
  platforms = {}
    
  init_blob()
  
  init_section(1) -- level/section
  
  -- reposition blob at start
  reset_blob()
  
  init_cam()

  cam.y = -200
  addTween(
    tween.new(
     2, cam, 
      {y = blob.maxHeight - GAME_HEIGHT/2 -30 }, 
      'outBounce',
      function(self)
        -- init menu buttons        
        local menu_xpos = 20
        local menu_ypos = GAME_HEIGHT/2 - 30

        local easyButton = BaseButtonObject(menu_xpos, menu_ypos, "EASY", function()
          -- start game
          init_game(1)
        end,nil,nil,10,11)
        local mediumButton = BaseButtonObject(menu_xpos, menu_ypos+25, "MEDIUM", function()
          -- start game
          init_game(5)
        end,nil,nil,45,44)
        local hardButton = BaseButtonObject(menu_xpos, menu_ypos+50, "HARD", function()
          -- start game
          init_game(10)
        end,nil,nil,52,53)
        local nightmareButton = BaseButtonObject(menu_xpos, menu_ypos+75, "NIGHTMARE", function()
          -- start game
          init_game(20)
        end,nil,nil,38,39)
        table.insert(buttons, easyButton)
        table.insert(buttons, mediumButton)
        table.insert(buttons, hardButton)
        table.insert(buttons, nightmareButton)
        
        -- reset time for credits
        _t=0
      end
    )
  )
  -- force cam to be a bit higher on title
  --cam.y = blob.maxHeight - GAME_HEIGHT/2 -40
  
  -- play starting music playlist (intro + music loop)
  -- (only if not already playing something
  --  e.g. coz started at higher level/tempo)
  MusicManager:playMusic(SPEEDUP_PLAYLISTS[-1])
  
  gameState = GAME_STATE.TITLE
end

function createTextObj(text, fontName, col1, col2)

end

function init_game(startSection)  
  speedUpNum = 0
  gameState = GAME_STATE.LVL_INTRO
  -- clear all menu buttons
  buttons = {}
  pressedCount = 0
  -- (force pressed state to false - to ignore click of starting game)
  currPressedState = false

  -- re-hide the mouse cursor
  love.mouse.setVisible(false)

  -- create platform definitions   
  last_xpos = PLATFORM_POSITIONS[2]
  -- init/clear platforms
  platforms = {}

  
  init_blob()

  blob.last_level_full_lives = startSection or 1  
  init_section(blob.last_level_full_lives) -- level/section
  
  -- reposition blob at start
  reset_blob()
  
  init_cam()
  
  -- if playing music...
  if MusicManager.currentsong ~= -1 then
    -- release title music loop
    MusicManager.playlist[1]:setLooping(false)
  end
end

-- create initial platforms & reset blobby
function init_section(sectionNum)  
  debug_log("init_section="..sectionNum)
--  blob.startPlatformNum = 0

  -- calc starting platform number (done once)
  if blob.startPlatformNum == 0 then
    for i=1,sectionNum do
      blob.startPlatformNum = blob.startPlatformNum + ((i>1) and (5+((i-1)*3)) or 1)
      --log("Section ["..i.."] - blob.startPlatformNum = "..blob.startPlatformNum)
    end
    -- set starting score (if not at the start)
    if blob.startPlatformNum>1 then
      blob.score = blob.startPlatformNum
    end
  end
  debug_log("blob.startPlatformNum... = "..blob.startPlatformNum)
  -- create "floor" platform
  --TODO: if level num > 1 then have diff static type (as resuming)
  if platforms[1] == nil then
    debug_log("create 'floor' platform...")
    local ypos = GAME_HEIGHT+PLATFORM_DIST_Y-(blob.startPlatformNum*PLATFORM_DIST_Y)
    local startPlatform = StaticPlatform(-56, ypos, 8)
    startPlatform.num = blob.startPlatformNum
    startPlatform.sectionNum = sectionNum
    platforms[1] = startPlatform
    -- test
    --platforms[1].gapSide=1
  end
  
  -- set the level/section num
  blob.levelNum = sectionNum
  -- set the total num platforms for this level/section
  blob.numPlatforms = 5+(sectionNum*3)
  debug_log("blob.numPlatforms... = "..blob.numPlatforms)
  if blob.platformCounter <= 1 then
    blob.platformCounter = blob.startPlatformNum
  end

  -- if not title screen
  if gameState ~= GAME_STATE.TITLE then
    -- generate any missing platforms (and clear old ones)
    generate_platforms()     
 -- if gameState ~= GAME_STATE.TITLE then
    -- show intro / popup
    init_level_intro()
  end
end

function init_level_intro()
  gameState = GAME_STATE.LVL_INTRO
  gameCounter = 0

  -- any announcements? (speed, platform, tips)
  checkSpeedupAndPopups()
end

function init_level_intro2()
  -- move to intro pt.2 ("get ready")
  gameState = GAME_STATE.LVL_INTRO2
  gameCounter = 0
  popup = nil
  hiding_popup = false
end

function init_level_end()
  gameState = GAME_STATE.LVL_END
  gameCounter = 0

  -- record progress for continue?
  if blob.lives == 3 then
    blob.last_level_full_lives = blob.levelNum + 1
  end
end

-- any announcements? (speed, platform, tips)
function checkSpeedupAndPopups()
  
  -- determine speed
  -- (only really necessary for debugging)
  if DEBUG_MODE then
    --log("checkSpeedupAndPopups -------------")
    for i=1,20 do
      local speedUpDef = SPEEDUP_LEVELS[i]
      if speedUpDef and blob.levelNum >= i then
        blob.speedFactor = speedUpDef[1]
        speedUpNum = speedUpDef[2]
        --log("  > blob.speedFactor = "..blob.speedFactor)
      end
    end
  end

  -- speed up announce?
  local speedUpDef = SPEEDUP_LEVELS[blob.levelNum]-- or (blob.levelNum > 20 and SPEEDUP_LEVELS[20])  
  if speedUpDef then
    blob.speedFactor = speedUpDef[1]
    log("blob.speedFactor = "..blob.speedFactor)
    -- announce speed-up
    speedUpNum = speedUpDef[2]
    --log("speedUpNum = "..speedUpNum)
    init_popup(1, speedUpNum) -- 1 = speedup msg
    -- speed up music (switch track to next speed music)
    MusicManager:playMusic(SPEEDUP_PLAYLISTS[speedUpNum])    
  end   
  
  -- new platforms?
  for pDef in all(PLATFORM_DEFS) do
    if pDef.announceAtLevel == blob.levelNum then
      -- announce platform
      init_popup(0, pDef.type) -- 2 = platform msg
    end
  end

  -- TODO: tips?
end

function init_popup(info_type, info_value)
  --log("init_popup("..info_type..","..info_value..")...")
  -- [info_types]
  -- 1 = speed-ups, 2 = platforms

  popup = {
    sx = 0,
    sy = 0,
    info_type = info_type,
    info_value = info_value,
  }
  
  addTween(
    tween.new(
      1, popup, 
      {sx = 1, 
       sy = 1}, 
      'outElastic',
      function(self)
        --log("complete!!!!")
      end
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
        -- move to intro pt.2 ("get ready")
        init_level_intro2()
      end)
  )
end
  
-- create & return a random platform
function createNewPlatform(platformNum)    

  -- seed rng for platform
  srand(platformNum)
  debug_log("srand("..platformNum..")")

  local newPlatform = nil
  local xpos = nil
  repeat
    xpos = pick(PLATFORM_POSITIONS)
    debug_log("  >> picked xpos="..xpos)
  until xpos ~= last_xpos

  -- re-seed rng for platform
  srand(platformNum)

  local ypos = GAME_HEIGHT+PLATFORM_DIST_Y-(platformNum*PLATFORM_DIST_Y)
  local prevPlatform = platforms[#platforms]
  
  ------------------------------------------------
  -- checkpoint - end of level/section
  ------------------------------------------------
  if platformNum == blob.startPlatformNum + blob.numPlatforms then
    -- create a landing platform for checkpoint
    newPlatform = StaticPlatform(-56, ypos, 8)
    newPlatform.isCheckpoint = true
    -- rig it so prev platform always at a side
    if prevPlatform.x == PLATFORM_POSITIONS[2] then
      -- with a spiker in left/right pos
      --log("> replaced platform with spiker (b4 checkpoint)")
      platforms[#platforms] = SpikerPlatform(PLATFORM_POSITIONS[(irnd(1)==0 and 1 or 3)], prevPlatform.y, 1)
      platforms[#platforms].num = prevPlatform.num
    end

    -- make a gap either side for blobby to jump through
    newPlatform.gapSide = (platforms[#platforms].x == PLATFORM_POSITIONS[1]) and 1 or 2

    last_xpos = PLATFORM_POSITIONS[2]
    goto end_createPlatform
    --return checkPoint
  end
  
  
  -- randomly select a platform type (based on those unlocked)  
  -- re-seed rng for platform
  srand(platformNum)
  
  while newPlatform == nil do
    -- pick a platform type
    local pDef = pick(PLATFORM_DEFS)
    debug_log("  >> picked type="..pDef.type)
    
    -- rigged!!
    --pDef.type = PLATFORM_TYPE.SIDESWITCHER

    -- BASIC checks
    -- is platform unlocked yet? (platform number, NOT level)
    if pDef.atPlatform > platformNum then goto continue end
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
    elseif pDef.type == PLATFORM_TYPE.SLIDER 
      and (last_xpos ~= PLATFORM_POSITIONS[2] or prevPlatform.isCheckpoint) -- not too many "middle" pos platforms
      then
    ------------------------------------------------
      newPlatform = SliderPlatform(PLATFORM_POSITIONS[2], ypos, 1) -- always middle pos
    
    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.BLOCKER 
      -- no blocker as the final platform...
      and platformNum ~= blob.startPlatformNum + blob.numPlatforms - 1
      -- ...and no "double blockers"
      and platforms[#platforms].type ~= PLATFORM_TYPE.BLOCKER 
      -- # then check on blockers, only if not 3 ahead of springer
      and (#platforms<3 or platforms[#platforms-2].type ~= PLATFORM_TYPE.SPRINGER)
      then
    ------------------------------------------------
        -- log("======================")
        -- log("platformNum = "..platformNum)
        -- log("blob.startPlatformNum = "..blob.startPlatformNum)
        -- log("blob.numPlatforms = "..blob.numPlatforms)
        -- log("blob.startPlatformNum + blob.numPlatforms = "..blob.startPlatformNum + blob.numPlatforms)
        -- log("======================")
        xpos = last_xpos  -- always prev platform pos
        newPlatform = BlockerPlatform(-56, ypos, 8, (platformNum < 60) and 1 or (1+irnd(2)))

        -- be nice to player for early levels
        -- (don't have "blocker" above a "spiker")
        if (platformNum < 60 
           or (platformNum < 100 and prevPlatform.type == PLATFORM_TYPE.SPIKER)
           or (platformNum < 200 and prevPlatform.type == PLATFORM_TYPE.TRIPLESPIKER))
           and prevPlatform.type ~= PLATFORM_TYPE.STATIC
         then
          -- replace "spiker" with a "static"
          --log("> replaced spiker with a static!")
          platforms[#platforms] = StaticPlatform(prevPlatform.x, prevPlatform.y, 1)
          platforms[#platforms].num = prevPlatform.num
          platforms[#platforms].sectionNum = prevPlatform.sectionNum
        end

        -- is blocker straight after a checkpoint?
        if prevPlatform.isCheckpoint then
          -- flag it, so can't destroy until next section
          newPlatform.isAfterCheckpoint = true
        end
    
    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.TRIPLESPIKER then
    ------------------------------------------------
      -- create three spikers (Blobby will only jump on ONE of them)
      newPlatform = TripleSpikerPlatform(xpos, ypos, 1)

    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.SPRINGER 
    -- Can't spring OVER a Checkpoint
     and platformNum <= blob.startPlatformNum + blob.numPlatforms - 3  -- if >= 3 from checkpoint
     then
    ------------------------------------------------
      newPlatform = SpringerPlatform(xpos, ypos, 1)
    
    ------------------------------------------------
    elseif pDef.type == PLATFORM_TYPE.SIDESWITCHER then
    ------------------------------------------------
      -- xpos is generated inside constructor
      newPlatform = SideSwitcherPlatform(56, ypos, 1)
  
  
    else
      -- do nothing - let it loop again
    end

    ::continue::    
  end

   debug_log("newPlatform.type == "..tostring(newPlatform.type))
   debug_log("#platforms == "..tostring(#platforms))
  -- -- DEBUG:
  for k,p in pairs(platforms) do
    debug_log(" - ["..k.."|"..tostring(p.num).."]="..p.type)
  end

  -- adjustment to avoid too many in same state
  if newPlatform.activeState == lastPlatformState then
    countOfSameStates = countOfSameStates + 1
    if countOfSameStates > 2 
     and newPlatform.type ~= PLATFORM_TYPE.BLOCKER
     and newPlatform.type ~= PLATFORM_TYPE.SPRINGER 
     and newPlatform.type ~= PLATFORM_TYPE.SIDESWITCHER 
     then
      -- flip the state
      newPlatform.activeState = not newPlatform.activeState
      --log("flipped default state, for variety!")
    end
  else
    countOfSameStates = 0
  end

  ::end_createPlatform::

  newPlatform.num = platformNum

  -- remember...
  last_xpos = xpos
  lastPlatformState = newPlatform.activeState

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
    speedFactor = 1.5,  -- will increase as game progresses (was 1)
    hitbox_w = 32,
    hitbox_h = 32,
    jumpFreq = 10,
    numPlatforms = 0, -- number of platforms for the current section
    platformCounter = 1, -- running counter of platform gen numbers
    onPlatformNum = 1,
    startPlatformNum = 0,
    last_level_full_lives = 0,

    loseLife = function(self)
      debug_log("OUCH!!!!")
      self.lives = self.lives - 1
      -- shake camera
      shake = shake + 0.25
      -- flash red
      cls(38) flip()
      -- play sfx
      pick(sounds.ouches):play()
      -- game over?
      if self.lives <= 0 then
        init_game_over()   
      end
    end
  }
end

function init_game_over()
  log("init_game_over()")
  gameState = GAME_STATE.GAME_OVER      
  gameCounter = 0
  -- object for tween use
  gameover_ui = {
    ypos = -200
  }

  -- stop game playlist
  MusicManager:stop()  
  -- play end jingle
  sounds.gameover[speedUpNum==0 and 1 or speedUpNum]:play()

  addTween(
    tween.new(
     2, gameover_ui, 
      {ypos = (GAME_HEIGHT/2)-116 }, 
      'outBounce', function()        
        -- NOTE: Restart buttons delayed, to avoid clicking too quick
        -- init mouse/touch controls
        init_cursor()
        -- init menu buttons
        buttons = {}
        local menu_xpos = 50
        local menu_ypos = GAME_HEIGHT/2 - 5

        local continueButton = BaseButtonObject(menu_xpos, menu_ypos+10, "YES", function()
          -- continue game
          init_game(blob.last_level_full_lives)
          -- stop game over sfx
          sounds.gameover[speedUpNum==0 and 1 or speedUpNum]:stop()
          -- play starting music playlist (for correct speed)
          MusicManager:playMusic(SPEEDUP_PLAYLISTS[speedUpNum])
        end,nil,nil)
        local titleButton = BaseButtonObject(menu_xpos, menu_ypos+35, "NO", function()
          -- stop game over sfx
          sounds.gameover[speedUpNum==0 and 1 or speedUpNum]:stop()
          -- exit to title
          init_title()
        end,nil,nil)
        table.insert(buttons, continueButton)
        table.insert(buttons, titleButton)
      end
    )
  )

  
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
  -- initialise camera object (smooth panning camera)
  cam = {
    x = 0,
    y = blob.maxHeight-GAME_HEIGHT/2,    
    trap_y = GAME_HEIGHT/2
  }
end

function init_sugarcoat()
  init_sugar("J.U.M.P.", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  -- start with splash screen palette 
  load_png("splash", "assets/splash.png", palettes.pico8, true)
  
  screen_resizeable(true, 2, on_resize)
  screen_render_integer_scale(false)
  set_frame_waiting(60)

   -- Get User info  
  --  me = castle.user.getMe()    
  --  my_id = me.userId
  --  my_name = me.username
  --  -- get photo
  --  if me.photoUrl then
  --    load_png("photo", me.photoUrl, ak54) 
  --  end
end

function init_assets()
  -- load fonts
  load_font ("assets/AweMono.ttf", 16, "small-font")
  load_font ("assets/gomarice_gogono_cocoa_mochi.ttf", 40, "big-font")
  load_font ("assets/gomarice_gogono_cocoa_mochi.ttf", 22, "main-font", true)
  load_font ("assets/GAMEPLAY-1987.ttf", 16, "big-font3", true)
  -- load gfx
  load_png("popups", "assets/popups.png", ak54, true)
  spritesheet_grid(32,32)
  --spritesheet_grid(128,128)
  load_png("spritesheet", "assets/spritesheet.png", ak54, true)
  spritesheet_grid(32,32)

  -- init sounds
  local musicVol = 0.7
  local sfxVol = 0.9
  -- init music  
  SPEEDUP_PLAYLISTS = {  
    [-1]={-- x1 (title + start)
      Sound:new('Jump Music Title Music Loop.ogg', 1, true, musicVol),  
      Sound:new('Jump Music Level 1 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 1 Game Loop.ogg', 1, true, musicVol)
    },
    [0]={-- x1
      Sound:new('Jump Music Level 1 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 1 Game Loop.ogg', 1, true, musicVol)
    },
    {-- x2
      Sound:new('Jump Music Level 1-2 Transition.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 2 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 2 Game Loop.ogg', 1, true, musicVol)
    },
    {-- x3
      Sound:new('Jump Music Level 2-3 Transition.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 3 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 3 Game Loop.ogg', 1, true, musicVol)
    },
    {-- x4
      Sound:new('Jump Music Level 3-4 Transition.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 4 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 4 Game Loop.ogg', 1, true, musicVol)
    },
    {-- x5
      Sound:new('Jump Music Level 4-5 Transition.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 5 Intro Loop.ogg', 1, false, musicVol),
      Sound:new('Jump Music Level 5 Game Loop.ogg', 1, true, musicVol)
    },
  }

  -- init sfx
  sounds.checkpoints={}
  for i= 1,5 do
    sounds.checkpoints[i] = Sound:new('Jump SFX Checkpoint'..i..'.ogg', 1, false, sfxVol)
  end
  sounds.ouches={}
  for i= 1,5 do
    sounds.ouches[i] = Sound:new('Jump SFX Ouch'..i..'.ogg', 2, false, sfxVol)
  end
  -- game over
  sounds.gameover={
    Sound:new('Jump Music Game Over Level 1.ogg', 1, false, sfxVol),
    Sound:new('Jump Music Game Over Level 2.ogg', 1, false, sfxVol),
    Sound:new('Jump Music Game Over Level 3.ogg', 1, false, sfxVol),
    Sound:new('Jump Music Game Over Level 4-5.ogg', 1, false, sfxVol),
  }
  -- breaking blocker
  sounds.breaking = Sound:new('JUMP SFX Breaking.ogg', 3, false, sfxVol-0.2)
  -- boings
  sounds.boings={}
  for i= 1,2 do
    sounds.boings[i] = Sound:new('JUMP SFX Boing'..i..'.ogg', 2, false, sfxVol)
  end  
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

function init_splash()
  -- init splash
  gameState = GAME_STATE.SPLASH 
  use_palette(palettes.pico8)
  splashStartTime = t()
end