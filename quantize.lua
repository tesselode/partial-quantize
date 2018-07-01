local iterator = require 'iterator'

local function quantize_pattern(song, pattern, scope, amount, lines, end_mode)
	local notes = iterator.get_notes(song, pattern, scope)
	iterator.clear_notes(song, pattern, scope)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines, end_mode)
		note:resolve_collisions(notes)
		note:write()
	end
end

return function(scope, whole_song, amount, lines, end_mode)
	local song = renoise.song()
	song:describe_undo 'Partially Quantize Notes'
	if whole_song then
		for pattern_index, _ in ipairs(song.patterns) do
			quantize_pattern(song, pattern_index, scope, amount, lines, end_mode)
		end
	else
		quantize_pattern(song, song.selected_pattern_index, scope, amount, lines, end_mode)
	end
end