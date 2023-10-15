local quantize = require 'quantize'

-- creates the partial quantize settings window
return function(whole_song_default, scope_default)
	local settings = renoise.Document.create 'PartialQuantizeSettings' {
		song_scope = 1,
		pattern_scope = 1,
		nudge = 0,
		amount = 100,
		lines = 1,
		swing = 0,
		end_mode = 1,
	}
	if whole_song_default ~= nil then
		settings.song_scope.value = whole_song_default and 2 or 1
	end
	if scope_default ~= nil then
		settings.pattern_scope.value = scope_default == 'column' and 1
		                            or scope_default == 'track' and 2
		                            or scope_default == 'selection' and 3
		                            or scope_default == 'all_tracks' and 4
	end

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
					items = {
						'Pattern',
						'Song',
					},
					bind = settings.whole_song,
				},
				vb:switch {
					id = 'pattern_scope',
					width = '100%',
					items = {
						'Column',
						'Track',
						'Selection',
						'All tracks',
					},
					bind = settings.pattern_scope,
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
						text = 'Nudge',
					},
					vb:valuebox {
						id = 'nudge_valuebox',
						width = 125,
						min = -256,
						max = 256,
						bind = settings.nudge,
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
						text = 'Amount',
					},
					vb:valuebox {
						id = 'amount_valuebox',
						width = 125,
						min = 0,
						max = 100,
						bind = settings.amount,
						tostring = function(v)
							return ('%.f'):format(v) .. '%'
						end,
						tonumber = function(s)
							if s:sub(-1) == '%' then s = s:sub(1, -2) end
							local v = tonumber(s)
							return v
						end,
					},
				},
				vb:horizontal_aligner {
					mode = 'right',
					vb:minislider {
						id = 'amount_slider',
						width = 125,
						min = 0,
						max = 100,
						bind = settings.amount,
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
						bind = settings.lines,
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
						text = 'Swing',
					},
					vb:valuebox {
						id = 'swing_valuebox',
						width = 125,
						min = 0,
						max = 100,
						bind = settings.swing,
						tostring = function(v)
							return ('%.f'):format(v) .. '%'
						end,
						tonumber = function(s)
							if s:sub(-1) == '%' then s = s:sub(1, -2) end
							local v = tonumber(s)
							return v and v
						end,
					},
				},
				vb:horizontal_aligner {
					mode = 'right',
					vb:minislider {
						id = 'swing_slider',
						width = 125,
						min = 0,
						max = 100,
						bind = settings.swing,
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
						bind = settings.end_mode,
						items = {
							'No change',
							'Quantize end',
							'Preserve length',
						},
					},
				},
			},
			vb:button {
				width = '100%',
				height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT,
				text = 'Quantize',
				notifier = function()
					local whole_song = settings.song_scope.value == 2
					local scope = settings.pattern_scope.value == 1 and 'column'
							   or settings.pattern_scope.value == 2 and 'track'
							   or settings.pattern_scope.value == 3 and 'selection'
							   or settings.pattern_scope.value == 4 and 'all_tracks'
					local nudge = settings.nudge.value
					local amount = settings.amount.value / 100
					local lines = settings.lines.value
					local swing = settings.swing.value / 100
					local note_off_mode = settings.end_mode.value == 1 and 'no_change'
									   or settings.end_mode.value == 2 and 'quantize_end'
									   or settings.end_mode.value == 3 and 'preserve_length'
					quantize(scope, whole_song, nudge, amount, lines, swing, note_off_mode)
				end,
			}
		}
    )
end
