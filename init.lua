function Root:layout()
	self._chunks = ui.Layout()
		:direction(ui.Layout.VERTICAL)
		:constraints({
			ui.Constraint.Length(0), -- Header
			ui.Constraint.Length(1), -- Tabs
			ui.Constraint.Fill(1),   -- File manager
			ui.Constraint.Length(1), -- Status
		})
		:split(self._area)
end

function Tabs.height()
	return 1
end

local original_redraw = Tabs.redraw

function Tabs:redraw()
	local area = self._area
	local width = area.w

	if width <= 0 then
		return {}
	end

	local cwd = ya.readable_path(
		tostring(cx.active.current.cwd)
	)

	local max_path_width = math.floor(width * 0.4)

	local path = ui.Line({
		ui.Span(" " .. ui.truncate(cwd, {
			max = math.max(0, max_path_width - 2),
			rtl = true,
		}) .. " "):style(th.mgr.cwd),
	})

	local path_width = path:width()
	local tabs_width = math.max(0, width - path_width - 1)

	self._area = ui.Rect({
		x = area.x,
		y = area.y,
		w = tabs_width,
		h = area.h,
	})

	local tabs = original_redraw(self)
	self._area = area

	path:area(area):align(ui.Align.RIGHT)

	return { tabs, path }
end


local function rounded(self, style)
    return ui.Line({
        ui.Span(th.counticon.sep_left):fg(style:bg()),
        ui.Span(self):style(style),
        ui.Span(th.counticon.sep_right):fg(style:bg()),
        ui.Span(" "),
    })
end

Status:children_add(function()
    local count = #cx.yanked
    if count < 1 then
        return ""
    end

    if cx.yanked.is_cut then
        return rounded(th.counticon.cut .. count, th.mgr.count_cut)
    else
        return rounded(th.counticon.copied .. count, th.mgr.count_copied)
    end
end, 501, Status.RIGHT)

Status:children_add(function()
    local count = #cx.active.selected
    if count < 1 then
        return ""
    end
    return rounded(th.counticon.selected .. count, th.mgr.count_selected)
end, 500, Status.RIGHT)

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	local t = ""
	if time ~= 0 then
		t = tostring(os.date("%Y-%m-%d %H:%M:%S", time))
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", t)
end

require("full-border"):setup()
require("mime-ext"):setup()

