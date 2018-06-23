local Object = require 'classic'
local util = require 'util'

local Note = Object:extend()

function Note:new(song, pos, col)
	self.pattern = song:pattern(pos.pattern)
	self.track = pos.track
	self.column = pos.column
	self.data = {
		start = {
			value = col.note_value,
			instrument = col.instrument_value,
			volume = col.volume_value,
			panning = col.panning_value
		}
	}
	self.start_time = util.to_time(pos.line, col.delay_value)
end

function Note:is_on(track, column)
	return self.track == track and self.column == column
end

function Note:get_finish()
	return self.finish_time
end

function Note:set_finish(pos, col)
	self.data.finish = {
		instrument = col.instrument_value,
		volume = col.volume_value,
		panning = col.panning_value
	}
	self.finish_time = util.to_time(pos.line, col.delay_value)
end

function Note:quantize(amount, lines)
	amount = amount or 1
	lines = lines or 1
	self.start_time = util.lerp(self.start_time, util.round(self.start_time, 255 * lines), amount)
	self.finish_time = self.finish_time and util.lerp(self.finish_time, util.round(self.finish_time, 255 * lines), amount)
end

function Note:write()
	local pattern_track = self.pattern:track(self.track)
	local start_line, start_delay = util.from_time(self.start_time)
	local start_col = pattern_track:line(start_line):note_column(self.column)
	start_col.note_value = self.data.start.value
	start_col.instrument_value = self.data.start.instrument
	start_col.volume_value = self.data.start.volume
	start_col.panning_value = self.data.start.panning
	start_col.delay_value = start_delay

	if self.finish_time then
		local finish_line, finish_delay = util.from_time(self.finish_time)
		local finish_col = pattern_track:line(finish_line):note_column(self.column)
		finish_col.note_value = renoise.PatternLine.NOTE_OFF
		finish_col.instrument_value = self.data.finish.instrument
		finish_col.volume_value = self.data.finish.volume
		finish_col.panning_value = self.data.finish.panning
		finish_col.delay_value = finish_delay
	end
end

return Note