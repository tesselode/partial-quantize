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

local function quantize_notes(notes, amount, lines)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines)
	end
end

local function note_has_collisions(notes, a)
	for _, b in ipairs(notes) do
		if b ~= a then
			local start_line_a = util.from_time(a.start.time)
			local start_line_b = util.from_time(b.start.time)
			if a.column == b.column and start_line_a == start_line_b then
				return true
			end
		end
	end
	return false
end

local function resolve_collisions(notes)
	for _, note in ipairs(notes) do
		while note.column < 12 and note_has_collisions(notes, note) do
			note.column = note.column + 1
		end
	end
end

local function write_notes(notes)
	for _, note in ipairs(notes) do
		note:write()
	end
end

local song = renoise.song()
local notes = get_notes(song, 'selection')
quantize_notes(notes, 1)
util.clear(song, 'selection')
resolve_collisions(notes)
write_notes(notes)