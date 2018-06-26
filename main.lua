local iterator = require 'iterator'
local Note = require 'note'
local util = require 'util'

local function get_notes(song, scope)
	local iter = iterator.get(song, scope)
	local notes = {}
	for pos, col in iter do
		if col.note_value ~= renoise.PatternLine.EMPTY_NOTE then
			for _, note in ipairs(notes) do
				if not note:get_finish() and note:is_on(pos.track, pos.column) then
					note:set_finish(pos, col)
				end
			end
			if col.note_value ~= renoise.PatternLine.NOTE_OFF then
				table.insert(notes, Note(song, pos, col))
			end
		end
	end
	return notes
end

local song = renoise.song()
local notes = get_notes(song, 'selection')
for _, note in ipairs(notes) do note:quantize(1, 1, 'quantize_length') end
util.clear(song, 'selection')
for _, note in ipairs(notes) do note:resolve_collisions(notes) end
for _, note in ipairs(notes) do note:write() end