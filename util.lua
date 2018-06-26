local util = {}

-- https://github.com/rxi/lume/blob/master/lume.lua#L87
function util.round(x, increment)
	if increment then return util.round(x / increment) * increment end
	return x >= 0 and math.floor(x + .5) or math.ceil(x - .5)
end

function util.lerp(a, b, f)
	return a + (b - a) * f
end

function util.to_time(line, delay)
	return (line - 1) * 255 + delay
end

function util.from_time(time)
	local line = math.floor(time / 255) + 1
	local delay = time % 255
	assert(line > 0, time)
	return line, delay
end

return util