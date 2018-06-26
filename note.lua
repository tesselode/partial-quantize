local Object = require 'classic'
local util = require 'util'

local Note = Object:extend()

function Note:new(song, pos, col)
	self.pattern = song:pattern(pos.pattern)
	self.track = pos.track
	self.column = pos.column
	self.start = {
		value = col.note_value,
		instrument = col.instrument_value,
		volume = col.volume_value,
		pan = col.panning_value,
		time = util.to_time(pos.line, col.delay_value),
	}
end

function Note:is_on(track, column)
	return self.track == track and self.column == column
end

function Note:get_pattern_length()
	return self.pattern.number_of_lines * 255 - 1
end

function Note:get_finish()
	return self.finish
end

function Note:set_finish(pos, col)
	self.finish = {
		instrument = col.instrument_value,
		volume = col.volume_value,
		pan = col.panning_value,
		time = util.to_time(pos.line, col.delay_value),
	}
	self.length = self.finish.time - self.start.time
end

function Note:quantize(amount, lines, end_mode)
	assert(end_mode == 'no_change'
		or end_mode == 'quantize_end'
		or end_mode == 'preserve_length'
	    or end_mode == 'quantize_length')
	amount = amount or 1
	lines = lines or 1
	self.start.time = util.lerp(self.start.time, util.round(self.start.time, 255 * lines), amount)
	self.start.time = self.start.time > self:get_pattern_length() and self:get_pattern_length() or self.start.time
	if self.finish then
		if end_mode == 'quantize_end' then
			self.finish.time = util.lerp(self.finish.time, util.round(self.finish.time, 255 * lines), amount)
			self.finish.time = self.finish.time > self:get_pattern_length() and self:get_pattern_length() or self.finish.time
		elseif end_mode == 'preserve_length' then
			self.finish.time = util.lerp(self.finish.time, self.start.time + self.length, amount)
		elseif end_mode == 'quantize_length' then
			self.finish.time = util.lerp(self.finish.time, self.start.time + util.round(self.length, 255 * lines), amount)
		end
	end
end

function Note:write()
	local pattern_track = self.pattern:track(self.track)
	if self.finish then
		local finish_line, finish_delay = util.from_time(self.finish.time)
		local finish_col = pattern_track:line(finish_line):note_column(self.column)
		finish_col.note_value = renoise.PatternLine.NOTE_OFF
		finish_col.instrument_value = self.finish.instrument
		finish_col.volume_value = self.finish.volume
		finish_col.panning_value = self.finish.pan
		finish_col.delay_value = finish_delay
	end
	local start_line, start_delay = util.from_time(self.start.time)
	local start_col = pattern_track:line(start_line):note_column(self.column)
	start_col.note_value = self.start.value
	start_col.instrument_value = self.start.instrument
	start_col.volume_value = self.start.volume
	start_col.panning_value = self.start.pan
	start_col.delay_value = start_delay
end

return Note