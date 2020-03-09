--
-- Based on https://love2d.org/wiki/SoundManager
--

MusicManager = {}
MusicManager.queue = {}
MusicManager.playlist = {}
MusicManager.currentsong = -1

--do the magic
function MusicManager:play(sound)  
  --Sound:new('Jump Music Level 1 Game Loop.ogg', 1)
  sound:setVolume(1)
  sound:setLooping(false)
  --put it in the queue
  table.insert(self.queue, sound)
  --and play it
  sound:play()
end

--do the music magic
function MusicManager:playMusic(first, ...)
  --stop all currently playing music
  for i, snd in ipairs(self.playlist) do
    snd:stop()
  end
  --decide if we were passed a table or a vararg,
  --and assemble the playlist
  if type(first) == "table" then
     self.playlist = first
  else
     self.playlist = {first, ...}
  end
  self.currentsong = 1
  --play
  self.playlist[1]:play()
end

--do some shufflin'
function MusicManager:shuffle(first, ...)
  local playlist
  if type(first) == "table" then
     playlist = first
  else
     playlist = {first, ...}
  end
  table.sort(playlist, shuffle)
  return unpack(playlist)
end

--update
function MusicManager:update(dt)
  --check which sounds in the queue have finished, and remove them
  local removelist = {}
  for i, v in ipairs(self.queue) do
     if not v:isPlaying() then
        table.insert(removelist, i)
     end
  end
  --we can't remove them in the loop, so use another loop
  for i, v in ipairs(removelist) do
     table.remove(self.queue, v-i+1)
  end
  --advance the playlist if necessary
  if self.currentsong ~= -1 and self.playlist and not self.playlist[self.currentsong]:isPlaying() then
     self.currentsong = self.currentsong + 1
     if self.currentsong > #self.playlist then
        self.currentsong = 1
     end
     self.playlist[self.currentsong]:play()
  end
end



-- helper functions
local function shuffle(a, b)
  return math.random(1, 2) == 1
end

return MusicManager;