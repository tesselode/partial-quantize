local Object = require 'classic'
local util = require 'util'

local Note = Object:extend()

function Note:new(pos, col)
	self.value = col.note_value
	self.instrument = col.instrument_value
	self.volume = col.volume_value
	self.panning = col.panning_value
	self.track = pos.track
	self.column = pos.column
	self.start = (pos.line - 1) * 255 + col.delay_value
end

function Note:is_on(track, column)
	return self.track == track and self.column == column
end

function Note:get_finish()
	return self.finish
end

function Note:set_finish(pos, col)
	self.finish = (pos.line - 1) * 255 + col.delay_value
end

function Note:quantize(amount, lines)
	amount = amount or 1
	lines = lines or 1
	self.start = util.lerp(self.start, util.round(self.start, 255 * lines), amount)
	self.finish = self.finish and util.lerp(self.finish, util.round(self.finish, 255 * lines), amount)
end

function Note:write(song)
	local pattern = song.selected_pattern
	local pattern_track = pattern:track(self.track)
	local start_line = math.floor(self.start / 255) + 1
	local finish_line = self.finish and math.floor(self.finish / 255) + 1
	local start_col = pattern_track:line(start_line):note_column(self.column)
	start_col.note_value = self.value
	start_col.instrument_value = self.instrument
	start_col.volume_value = self.volume
	start_col.panning_value = self.panning
	start_col.delay_value = self.start % 255
	if finish_line then
		local finish_col = pattern_track:line(finish_line):note_column(self.column)
		finish_col.note_value = renoise.PatternLine.NOTE_OFF
		finish_col.delay_value = self.finish % 255
	end
end

return Note