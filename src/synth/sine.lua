-- A demo synth that produces a sine wave.

local ccst = require "ccst"

local Sine = {
   name = "Sine",
   kind = ccst.synth { default_voices = 1 },
}

function Sine.init_global_state(state)
end

function Sine.generate_voice(voice, buffer, settings)
   for i = 1, #buffer do
      local angle = voice.time * voice.pitch_hz * math.pi * 2
      buffer[i] = math.sin(angle) * 0.8
      voice.time = voice.time + settings.sample_time
   end
end

function Sine.on_note_start(voice)
   voice.time = 0
end

function Sine.on_note_end(voice)
   voice.is_finished = true
end

return Sine
