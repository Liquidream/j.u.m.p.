-- globals
_t = 0
blob = {}
cam = {}
platforms = {}
lastPressedState = false
maxTypeNumber = 3
gameCounter = 0 -- used for countdown delays at end/start of levels
tweens = {}

function init_game()
  --init_data()
  init_sugarcoat()  
  init_assets()
  init_input()
  init_blob()
  --init_cam()
  init_level()

  _initialized = true
  on_resize()

  -- show the title
  --init_title()
end

-- create level platforms
function init_level()
  local platformDist = 150
  -- create "floor" platform
  platforms[1] = StaticPlatform(
                    -56,
                    GAME_HEIGHT,
                    8)

  -- create other platforms
  for i = 2,5+(blob.levelNum*3) do
    local positions = {10, 56, 102}
    local xpos = positions[irnd(3)+1]
    local ypos = GAME_HEIGHT+platformDist-(i*platformDist)

    --local pType = PLATFORM_TYPE.SLIDER
    
    -- randomise types (based on those unlocked)    
    local pType = irnd(maxTypeNumber)+1
    
    if pType == PLATFORM_TYPE.STATIC then
      platforms[i] = StaticPlatform(xpos, ypos, 1)
    
    elseif pType == PLATFORM_TYPE.SPIKER then
      platforms[i] = SpikerPlatform(xpos, ypos, 1)

    elseif pType == PLATFORM_TYPE.SLIDER then
      platforms[i] = SliderPlatform(56, ypos, 1)
    end

  end
  
  -- reposition blob at start
  reset_blob()

  -- reset camera
  init_cam()

  -- ready to play
  gameState = GAME_STATE.LVL_PLAY

  --gameState = GAME_STATE.LVL_END
  --gameCounter = 0
end

-- create & initialise blob obj 
-- (will be positioned later)
function init_blob()
  blob = {
    lives = 3,
    score = 0,
    levelNum = 1,
    hitbox_w = 32,
    hitbox_h = 32,
    jumpFreq = 50, --100
    loseLife = function(self)
      log("OUCH!!!!")
      self.lives = self.lives - 1
      cls(38) flip()
    end
  }
end

-- reset blob back to starting position
-- (either start of game or after losing a life)
function reset_blob()
  blob.x = GAME_WIDTH/2 - 16     -- start in the middle
  blob.y = GAME_HEIGHT-100   -- start near the bottom (on starting platform)
  -- blob.y = GAME_HEIGHT-40   -- start near the bottom (on starting platform)
  blob.maxHeight = GAME_HEIGHT-40
  blob.vy = 0     -- y velocity
  blob.vx = 0     -- x velocity
  blob.state = 0  -- 0=start, 1=jumping, 2=flying, 3=landing?
  blob.onGround = false
  blob.jumpCounter = 0
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