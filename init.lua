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

  -- init/clear platforms
  platforms = {}

  init_blob()
  -- reposition blob at start
  reset_blob()
  
  init_cam()
  
  init_section()

  -- show the title
  --init_title()

  Sounds.music = Sound:new('Jump_Music_90bpm_DMaj.wav', 1)
  Sounds.music:setVolume(0.75)
  Sounds.music:setLooping(true)
  Sounds.music:play()
  --
  -- Sounds.music:playWithPitch(1)
  -- local tr2 = 1.0594630943592952645
  -- Sounds.music:playWithPitch(1 * (tr2 ^ 1))
end

-- create initial platforms & reset blobby
function init_section()  
  -- create "floor" platform
  --TODO: if level num > 1 then have diff static type (as resuming)
  if platforms[1] == nil then
    platforms[1] = StaticPlatform(-56, GAME_HEIGHT, 8)
    platforms[1].num = 1  
  end
  
  -- set the total num platforms for this level/section
  blob.numPlatforms = 5+(blob.levelNum*3)

  -- generate any missing platforms (and clear old ones)
  generate_platforms()
  
  log("blob.speedFactor = "..blob.speedFactor)
  
  --
  -- ready to play
  gameState = GAME_STATE.LVL_PLAY
end
  
-- create & return a random platform
function createNewPlatform()
  -- 
  blob.platformCounter = blob.platformCounter + 1
  local num = blob.platformCounter
  debug_log("in createNewPlatform()... seeding:"..num)
  
  -- seed rng for platform
  srand(num)
  -- ERROR: Can't do this atm, as it always results in activeState = false?!?

  local platformDist = 150
  local positions = {10, 56, 102}
  local xpos = positions[irnd(3)+1]
  local ypos = GAME_HEIGHT+platformDist-(num*platformDist)
  
  -- check for end of level/section
  if blob.platformCounter == blob.startPlatformNum + blob.numPlatforms then
    -- create a landing platform for checkpoint
    --TODO: maybe change the platform look/style?
    local checkPoint = StaticPlatform(-56, ypos, 8)
    checkPoint.isCheckpoint = true
    return checkPoint
  end


  
  -- randomise types (based on those unlocked)    
  local pType = irnd(maxTypeNumber-1)+2
  --local pType = PLATFORM_TYPE.BLOCKER    
  --local pType = PLATFORM_TYPE.STATIC
  --local pType = PLATFORM_TYPE.SPIKER

  -- REMOVED Static from RNG, as "inactive Spiker" is same!
  -- if pType == PLATFORM_TYPE.STATIC then
  --   return StaticPlatform(xpos, ypos, 1)
  
  if pType == PLATFORM_TYPE.SPIKER then    
    return SpikerPlatform(xpos, ypos, 1)

  elseif pType == PLATFORM_TYPE.SLIDER then
    return SliderPlatform(56, ypos, 1)
  
  elseif pType == PLATFORM_TYPE.BLOCKER 
    and #platforms < blob.startPlatformNum + blob.numPlatforms 
    and platforms[#platforms].type ~= PLATFORM_TYPE.BLOCKER then
      -- no "double blockers" and no blocker as the final platform
      return BlockerPlatform(-56, ypos, 8)
  
  else
    -- default type 
    -- (now Spiker - as when inactive, same as static!)
    return SpikerPlatform(xpos, ypos, 1)
    -- return StaticPlatform(xpos, ypos, 1)
  end
end

-- create & initialise blob obj 
-- (will be positioned later)
function init_blob()
  blob = {
    lives = 3,
    score = 0,       -- essentially the platform num?
    levelNum = 1,
    speedFactor = 1, -- will increase (up to 2.5?) as game progresses
    hitbox_w = 32,
    hitbox_h = 32,
    jumpFreq = 10,
    numPlatforms = 0, -- number of platforms for the current section
    platformCounter = 1, -- running counter of platform gen numbers
    onPlatformNum = 0,
    startPlatformNum = 1,

    loseLife = function(self)
      log("OUCH!!!!")
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
function reset_blob()--islevelInit)
  blob.x = GAME_WIDTH/2 - 16     -- start in the middle
  blob.y = GAME_HEIGHT-40   -- start near the bottom (on starting platform)
  blob.maxHeight = GAME_HEIGHT-40
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
    y = 0,
    trap_y = GAME_HEIGHT/2
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
  --load_png("keys", "assets/keys.png", ak54, true)
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