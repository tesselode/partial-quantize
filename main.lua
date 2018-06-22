local song = renoise.song()

local notes = {}

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

for _, note in ipairs(notes) do
	rprint(note)
	rprint '\n'
end

rprint 'done'