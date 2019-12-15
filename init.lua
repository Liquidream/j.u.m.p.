-- globals
_t = 0
player = {}
cam = {}
platforms = {}


function init_game()
  --init_data()
  init_sugarcoat()  
  init_assets()
  init_input()
  init_player()
  init_cam()
  init_level()

  _initialized = true
  on_resize()


  gameState = GAME_STATE.LVL_PLAY

  -- show the title
  --init_title()
end

-- create level platforms
function init_level()
  local platformDist = 150
  for i = 1,5+(player.levelNum*3) do
    -- create new platform
    platforms[i] = {
      x = 55,
      y = GAME_HEIGHT+platformDist-(i*platformDist),
      type = 1, -- 1=
      spr = 8,
      spr_w = 1,
      spr_h = 1,
      hitbox_w = 32,
      hitbox_h = 32,
    }
  end
end

function init_player()
  player = {
    x = GAME_WIDTH/2 - 16,     -- start in the middle
    y = GAME_HEIGHT-40,   -- start near the bottom (on starting platform)
    maxHeight = GAME_HEIGHT-40,
    lives = 3,
    vy = 0,     -- y velocity
    vx = 0,     -- x velocity
    state = 0,  -- 0=start, 1=jumping, 2=flying, 3=landing?
    onGround = false,
    levelNum = 1,
    hitbox_w = 32,
    hitbox_h = 32,
  }
end

-- put player in starting position
-- (either start of game or after losing a life)
function reset_player()
  player.x = GAME_WIDTH/2     -- start in the middle
  player.y = GAME_HEIGHT-40   -- start near the bottom (on starting platform)
  player.maxHeight = player.y
  player.state = 0  -- 0=start, 1=jumping, 2=flying, 3=landing?
  player.onGround = true
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
  load_font ("assets/Awesome.ttf", 16, "main-font", true)
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