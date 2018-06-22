-- https://github.com/rxi/lume/blob/master/lume.lua#L87
local function round(x, increment)
	if increment then return round(x / increment) * increment end
	return x >= 0 and math.floor(x + .5) or math.ceil(x - .5)
end

local song = renoise.song()

local notes = {}

-- get notes
for pos, col in song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index, true) do
	if col.is_selected and not col.is_empty then
		for _, note in ipairs(notes) do
			if not note.finish and note.track == pos.track and note.column == pos.column then
				note.finish = pos.line * 255 + col.delay_value
			end
		end
		if col.note_value ~= 120 then
			table.insert(notes, {
				value = col.note_value,
				track = pos.track,
				column = pos.column,
				start = pos.line * 255 + col.delay_value
			})
		end
	end
end

-- quantize notes
for _, note in ipairs(notes) do
	note.start = round(note.start, 255)
	note.finish = note.finish and round(note.finish, 255)
end

-- clear selection
for _, col in song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index, true) do
	if col.is_selected then
		col:clear()
	end
end

-- write note data
local pattern = song.selected_pattern
for _, note in ipairs(notes) do
	local start_line = math.floor(note.start / 255)
	local finish_line = note.finish and math.floor(note.finish / 255)
	pattern:track(note.track):line(start_line):note_column(note.column).note_value = note.value
	if finish_line then
		pattern:track(note.track):line(finish_line):note_column(note.column).note_value = 120
	end
end