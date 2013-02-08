local measure = function(f,...)
	local st = love.timer.getMicroTime()
	collectgarbage()
	local mcount = collectgarbage('count')
	f(...)
	return ((love.timer.getMicroTime() - st)*1000),
		math.abs(collectgarbage('count') - mcount)
end

return {
	measure = measure,
}