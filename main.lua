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

local function quantize(scope, whole_song, amount, lines, end_mode)
	local song = renoise.song()
	if whole_song then
		for pattern_index, _ in ipairs(song.patterns) do
			quantize_pattern(song, pattern_index, scope, amount, lines, end_mode)
		end
	else
		quantize_pattern(song, song.selected_pattern_index, scope, amount, lines, end_mode)
	end
end

local function create_gui(whole_song_default, scope_default)
	local vb = renoise.ViewBuilder()
	renoise.app():show_custom_dialog(
		'Partial quantize',
		vb:column {
			margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,
			spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING,
			width = 300,
			vb:column {
				margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
				spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
				style = 'panel',
				width = '100%',
				vb:text {
					text = 'Region',
					width = '100%',
					align = 'center',
					font = 'bold',
				},
				vb:switch {
					id = 'song_scope',
					width = '100%',
					value = whole_song_default and 2 or 1,
					items = {
						'Pattern',
						'Song',
					}
				},
				vb:switch {
					id = 'pattern_scope',
					width = '100%',
					value = scope_default == 'column' and 1
						 or scope_default == 'track' and 2
						 or scope_default == 'selection' and 3
						 or scope_default == 'all_tracks' and 4
						 or 1,
					items = {
						'Column',
						'Track',
						'Selection',
						'All tracks',
					}
				},
			},
			vb:column {
				margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
				spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
				style = 'panel',
				width = '100%',
				vb:text {
					text = 'Quantization',
					width = '100%',
					align = 'center',
					font = 'bold',
				},
				vb:horizontal_aligner {
					mode = 'justify',
					vb:text {
						text = 'Amount',
					},
					vb:slider {
						id = 'amount',
						width = 125,
						value = 1,
					},
				},
				vb:horizontal_aligner {
					mode = 'justify',
					vb:text {
						text = 'Lines',
					},
					vb:valuebox {
						id = 'lines',
						width = 125,
						min = 1,
						max = 64,
						value = 1,
						tostring = function(value)
							return ('%.f'):format(math.floor(value))
						end,
						tonumber = function(string)
							return tonumber(string)
						end,
					},
				},
				vb:horizontal_aligner {
					mode = 'justify',
					vb:text {
						text = 'Note off mode',
					},
					vb:popup {
						id = 'end_mode',
						width = 125,
						items = {
							'No change',
							'Quantize end',
							'Preserve length',
							'Quantize length',
						},
					},
				},
			},
			vb:button {
				width = '100%',
				height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT,
				text = 'Quantize',
				notifier = function()
					local whole_song = vb.views.song_scope.value == 2
					local scope = vb.views.pattern_scope.value == 1 and 'column'
							   or vb.views.pattern_scope.value == 2 and 'track'
							   or vb.views.pattern_scope.value == 3 and 'selection'
							   or vb.views.pattern_scope.value == 4 and 'all_tracks'
					local amount = vb.views.amount.value
					local lines = vb.views.lines.value
					local note_off_mode = vb.views.end_mode.value == 1 and 'no_change'
									   or vb.views.end_mode.value == 2 and 'quantize_end'
									   or vb.views.end_mode.value == 3 and 'preserve_length'
									   or vb.views.end_mode.value == 4 and 'quantize_length'
					quantize(scope, whole_song, amount, lines, note_off_mode)
				end,
			}
		}
	)
end

renoise.tool():add_menu_entry {
	name = 'Main Menu:Tools:Partial Quantize...',
	invoke = function() create_gui(true, 'all_tracks') end,
}

renoise.tool():add_menu_entry {
	name = 'Pattern Editor:Pattern:Partial Quantize...',
	invoke = function() create_gui(false, 'all_tracks') end,
}

renoise.tool():add_menu_entry {
	name = 'Pattern Editor:Track:Partial Quantize...',
	invoke = function() create_gui(false, 'track') end,
}

renoise.tool():add_menu_entry {
	name = 'Pattern Editor:Column:Partial Quantize...',
	invoke = function() create_gui(false, 'column') end,
}

renoise.tool():add_menu_entry {
	name = 'Pattern Editor:Selection:Partial Quantize...',
	invoke = function() create_gui(false, 'selection') end,
}