local iterator = require 'iterator'

local function quantize(scope, amount, lines, end_mode)
	local song = renoise.song()
	local notes = iterator.get_notes(song, scope)
	iterator.clear_notes(song, scope)
	for _, note in ipairs(notes) do
		note:quantize(amount, lines, end_mode)
		note:resolve_collisions(notes)
		note:write()
	end
end

local function create_gui()
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
					width = '100%',
					items = {
						'Pattern',
						'Song',
					}
				},
				vb:switch {
					width = '100%',
					items = {
						'Column',
						'Track',
						'Selection',
						'All',
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
						width = 125,
						min = 1,
						max = 100,
						value = 100,
					},
				},
				vb:horizontal_aligner {
					mode = 'justify',
					vb:text {
						text = 'Note off mode',
					},
					vb:popup {
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
			}
		}
	)
end

create_gui()