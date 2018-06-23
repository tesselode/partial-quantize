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

local function quantize_notes(notes, amount, lines)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines)
	end
end

local function resolve_collisions(notes)
	for i = 1, #notes - 1 do
		for j = i + 1, #notes do
			local a = notes[i]
			local b = notes[j]
			local start_line_a = util.from_time(a.start.time)
			local start_line_b = util.from_time(b.start.time)
			if a.column < 12 and a.column == b.column and start_line_a == start_line_b then
				rprint(a.column)
				a.column = a.column + 1
				rprint(a.column)
			end
		end
	end
end

local function write_notes(notes)
	for _, note in ipairs(notes) do
		note:write()
	end
end

local song = renoise.song()
local notes = getNotes(song, 'selection')
quantize_notes(notes, 1)
util.clear(song, 'selection')
resolve_collisions(notes)
write_notes(notes)