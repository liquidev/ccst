-- Base CCST API.

local aengine = require "audio-engine"
local buffer = require "buffer"

local ccst = {}

function ccst.synth(t)
   t.is_synth = true
   t.default_voices = t.default_voices or 1
   return t
end

function ccst.create_synth(T)
   assert(T.kind.is_synth, T.name.." is not a synth")

   local synth = {
      T = T,
      global_state = {},
      voices = {},
      free_voices = {},

      output_buffer = buffer.new(aengine.buffer_size),
      remove_voices = {},
   }

   T.init_global_state(synth.global_state)

   return synth
end

function ccst.start_voice(synth, voice)
   local id
   if #synth.free_voices > 0 then
      id = table.remove(synth.free_voices)
   else
      id = #synth.voices + 1
   end
   synth.voices[id] = voice
   synth.voices[id].is_on = true
   synth.T.on_note_start(synth.voices[id])
   return id
end

function ccst.end_voice(synth, id)
   synth.voices[id].is_on = false
   synth.T.on_note_end(synth.voices[id])
end

function ccst.synthesize(synth, output_buffer)
   buffer.new(#output_buffer, synth.output_buffer)
   for id, voice in pairs(synth.voices) do
      synth.T.generate_voice(voice, synth.output_buffer, aengine)
      if voice.is_finished then
         table.insert(synth.remove_voices, id)
      end
      for i = 1, #output_buffer do
         output_buffer[i] = output_buffer[i] + synth.output_buffer[i]
      end
   end

   while true do
      local voice_id = table.remove(synth.remove_voices)
      if voice_id == nil then break end
      synth.voices[voice_id] = nil
      table.insert(synth.free_voices, voice_id)
   end
end

function ccst.convert_fltp_to_s8(inout_buffer)
   for i = 1, #inout_buffer do
      inout_buffer[i] = math.max(-127, math.min(math.floor(inout_buffer[i] * 127), 127))
   end
end

return ccst
