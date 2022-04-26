local music_math = {}

-- Calculates the frequency of the nth note relative to A4.
function music_math.note_frequency(a4, n)
   return a4 * 2^(n / 12)
end

return music_math
