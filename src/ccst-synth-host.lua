-- Utility program for hosting synthesizers.

local aengine = require "audio-engine"
local ccst = require "ccst"
local music_math = require "music-math"

---

local args = { ... }

local synth_path = args[1] or error("no synth path provided")
local Synth = require("synth."..synth_path)

aengine.init()
local audio_timer = aengine.start_audio_timer()

local synth = ccst.create_synth(Synth)

local a4 = 440
local note_keys = {
   [keys.a] = -9,
   [keys.w] = -8,
   [keys.s] = -7,
   [keys.e] = -6,
   [keys.d] = -5,
   [keys.f] = -4,
   [keys.t] = -3,
   [keys.g] = -2,
   [keys.y] = -1,
   [keys.h] = 0,
   [keys.u] = 1,
   [keys.j] = 2,
   [keys.k] = 3,
   [keys.o] = 4,
   [keys.l] = 5,
   [keys.p] = 6,
}
local notes_on = {}

while true do
   local event = { os.pullEvent() }
   local kind = event[1]
   if kind == "key" then
      local key, is_repeated = table.unpack(event, 2)
      local note_index = note_keys[key]
      if not is_repeated and note_index ~= nil then
         local pitch_hz = music_math.note_frequency(a4, note_index)
         notes_on[key] = ccst.start_voice(synth, {
            pitch_hz = pitch_hz,
         })
      end
   elseif kind == "key_up" then
      local key = event[2]
      local voice_id = notes_on[key]
      if voice_id then
         ccst.end_voice(synth, voice_id)
         notes_on[key] = nil
      end
   elseif kind == "timer" and event[2] == audio_timer then
      audio_timer = aengine.start_audio_timer()
      aengine.begin_rendering()
      local synthesis_start = os.clock()
      ccst.synthesize(synth, aengine.output_buffer)
      local synthesis_end = os.clock()
      ccst.convert_fltp_to_s8(aengine.output_buffer)
      aengine.play_audio()

      term.setBackgroundColor(colors.gray)
      term.setTextColor(colors.green)
      term.clear()
      local width, height = term.getSize()
      for x = 1, width do
         local sample_index = x * 4
         local sample = aengine.output_buffer[sample_index]
         local y = (-sample / 128 + 1) / 2 * height
         term.setCursorPos(x, y)
         term.write('+')
      end
      term.setTextColor(colors.white)
      term.setCursorPos(1, 1)
      term.write(("buffer size: %d"):format(aengine.buffer_size))
   end
end
