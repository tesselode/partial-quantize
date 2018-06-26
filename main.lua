local iterator = require 'iterator'
local util = require 'util'

local song = renoise.song()
local notes = iterator.get_notes(song, 'selection')
for _, note in ipairs(notes) do note:quantize(1, 1, 'quantize_length') end
iterator.clear_notes(song, 'selection')
for _, note in ipairs(notes) do note:resolve_collisions(notes) end
for _, note in ipairs(notes) do note:write() end