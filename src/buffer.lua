-- Buffer utilities.

local buffer = {}

-- Creates a new zero-filled buffer of the given size. If t is provided, it's filled with zeroes.
function buffer.new(size, t)
   t = t or {}
   for i = 1, size do
      t[i] = 0
   end
   for i = #t, size + 1, -1 do
      t[i] = nil
   end
   return t
end

return buffer
