local Note = require 'note'
local util = require 'util'

local song = renoise.song()

local function getIterator()
	return song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index, true)
end

local function getNotes(iterator)
	local notes = {}
	for pos, col in iterator do
		if col.is_selected and not col.is_empty then
			for _, note in ipairs(notes) do
				if not note:get_finish() and note:is_on(pos.track, pos.column) then
					note:set_finish(pos, col)
				end
			end
			if col.note_value ~= renoise.PatternLine.NOTE_OFF then
				table.insert(notes, Note(pos, col))
			end
		end
	end
	return notes
end

local function quantizeNotes(notes, amount, lines)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines)
	end
end

local function writeNotes(notes)
	for _, note in ipairs(notes) do
		note:write(song)
	end
end

local notes = getNotes(getIterator())
quantizeNotes(notes, 1)
util.clear(getIterator())
writeNotes(notes)