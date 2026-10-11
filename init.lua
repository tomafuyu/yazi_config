require("full-border"):setup()

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	local t = ""
	if time ~= 0 then
		t = tostring(os.date("%Y-%m-%d %H:%M:%S", time))
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", t)
end

