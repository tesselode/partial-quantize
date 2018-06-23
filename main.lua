local iterator = require 'iterator'
local Note = require 'note'
local util = require 'util'

local function getNotes(song, scope)
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

local function quantizeNotes(notes, amount, lines)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines)
	end
end

local function writeNotes(notes)
	for _, note in ipairs(notes) do
		note:write()
	end
end

local song = renoise.song()
local notes = getNotes(song, 'selection')
quantizeNotes(notes, 1)
util.clear(song, 'selection')
writeNotes(notes)