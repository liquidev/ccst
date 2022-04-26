-- Audio engine used for playing back samples.

local buffer = require "buffer"

local aengine = {}

function aengine.init()
   aengine.speaker = peripheral.find("speaker")
   aengine.speaker.playNote("harp", 1, 24)

   aengine.sample_rate = 48000
   aengine.sample_time = 1 / aengine.sample_rate
   aengine.target_buffer_size = aengine.sample_rate / 20
   aengine.buffer_size = aengine.target_buffer_size
   aengine.last_update = os.epoch("utc") / 1000

   aengine.output_buffer = buffer.new(aengine.buffer_size)
end

function aengine.start_audio_timer()
   local timer_id = os.startTimer(0.05)
   return timer_id
end

function aengine.begin_rendering()
   local now = os.epoch("utc") / 1000
   local time_passed = now - aengine.last_update
   aengine.last_update = now
   aengine.buffer_size = math.min(math.floor(time_passed * aengine.sample_rate), aengine.target_buffer_size + 100)
   buffer.new(aengine.buffer_size, aengine.output_buffer)
end

function aengine.play_audio()
   while not aengine.speaker.playAudio(aengine.output_buffer) do
   end
end

return aengine
