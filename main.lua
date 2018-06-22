-- https://github.com/rxi/lume/blob/master/lume.lua#L87
local function round(x, increment)
	if increment then return round(x / increment) * increment end
	return x >= 0 and math.floor(x + .5) or math.ceil(x - .5)
end

local song = renoise.song()

local function clear(iterator)
	for _, col in iterator do
		if col.is_selected then
			col:clear()
		end
	end
end

local function getIterator()
	return song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index, true)
end

local function getNotes(iterator)
	local notes = {}
	for pos, col in iterator do
		if col.is_selected and not col.is_empty then
			for _, note in ipairs(notes) do
				if not note.finish and note.track == pos.track and note.column == pos.column then
					note.finish = pos.line * 255 + col.delay_value
				end
			end
			if col.note_value ~= renoise.PatternLine.NOTE_OFF then
				table.insert(notes, {
					value = col.note_value,
					track = pos.track,
					column = pos.column,
					start = pos.line * 255 + col.delay_value
				})
			end
		end
	end
	return notes
end

local function quantizeNotes(notes)
	for _, note in ipairs(notes) do
		note.start = round(note.start, 255)
		note.finish = note.finish and round(note.finish, 255)
	end
end

local function writeNotes(notes)
	local pattern = song.selected_pattern
	for _, note in ipairs(notes) do
		local pattern_track = pattern:track(note.track)
		local start_line = math.floor(note.start / 255)
		local finish_line = note.finish and math.floor(note.finish / 255)
		pattern_track:line(start_line):note_column(note.column).note_value = note.value
		if finish_line then
			pattern_track:line(finish_line):note_column(note.column).note_value = renoise.PatternLine.NOTE_OFF
		end
	end
end

local notes = getNotes(getIterator())
quantizeNotes(notes)
clear(getIterator())
writeNotes(notes)