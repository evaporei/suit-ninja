local os = require('os')

-- local folder = 'Clubs'
local folder = 'Spades'

local function lpad(s, l, c)
    local res = string.rep(c or ' ', l - #s) .. s

    return res, res ~= s
end

for i = 1, 13 do
    local number = lpad(tostring(i), 2, '0')
    local ext = '.png'
    local old = folder .. '/' .. folder .. '_card_' .. number .. ext
    local new = folder .. '/' ..  number .. ext
    print(old, new)
    os.rename(old, new)
end
