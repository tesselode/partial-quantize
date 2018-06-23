local iterator = {}

local function selection_in_pattern_iterator(song)
	local note_columns = {}
	for pos, col in song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index) do
		if col.is_selected then
			table.insert(note_columns, {{
				pattern = pos.pattern,
				track = pos.track,
				line = pos.line,
				column = pos.column,
			}, col})
		end
	end
	local i = 0
	return function()
		i = i + 1
		if note_columns[i] then
			return unpack(note_columns[i])
		end
	end
end

function iterator.get(song, scope)
	assert(scope == 'track'
		or scope == 'selection'
		or scope == 'all_tracks')
	if scope == 'track' then
		return song.pattern_iterator:note_columns_in_pattern_track(
			song.selected_pattern_index,
			song.selected_track_index
		)
	elseif scope == 'selection' then
		return selection_in_pattern_iterator(song)
	elseif scope == 'all_tracks' then
		return song.pattern_iterator:note_columns_in_pattern(song.selected_pattern_index)
	end
end

return iterator