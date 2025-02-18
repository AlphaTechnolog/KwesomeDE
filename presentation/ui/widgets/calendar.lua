-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local gobject = require("gears.object")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local wibox = require("wibox")
local wtext = require("presentation.ui.widgets.text")
local wtbutton = require("presentation.ui.widgets.button.text")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi
local setmetatable = setmetatable
local os = os

local calendar = { mt = {} }

local function day_name_widget(name)
	return wibox.widget
	{
		widget = wibox.container.background,
		forced_width = dpi(35),
		forced_height = dpi(35),
		wtext
		{
			halign = "center",
			size = 15,
			bold = true,
			text = name
		}
	}
end

local function date_widget(date, is_current, is_another_month)
	local text_color = beautiful.colors.on_background
	if is_current == true then
		text_color = beautiful.colors.on_accent
	elseif is_another_month == true then
		text_color = helpers.color.darken(beautiful.colors.on_background, 0.2)
	end

	return wibox.widget
	{
		widget = wibox.container.background,
		forced_width = dpi(35),
		forced_height = dpi(35),
		shape = gshape.circle,
		bg = is_current and beautiful.random_accent_color() or beautiful.colors.transparent,
		wtext
		{
			halign = "center",
			size = 15,
			color = text_color,
			text = date
		}
	}
end

function calendar:set_date(date)
	self.date = date

	self.days:reset()

	local current_date = os.date("*t")

	self.days:add(day_name_widget("Su"))
	self.days:add(day_name_widget("Mo"))
	self.days:add(day_name_widget("Tu"))
	self.days:add(day_name_widget("We"))
	self.days:add(day_name_widget("Th"))
	self.days:add(day_name_widget("Fr"))
	self.days:add(day_name_widget("Sa"))

	local first_day = os.date("*t", os.time{year = date.year, month = date.month, day = 1})
	local last_day = os.date("*t", os.time{year = date.year, month = date.month + 1, day = 0})
	local month_days = last_day.day

	local time = os.time{year = date.year, month = date.month, day = 1}
	self.month:set_text(os.date("%B %Y", time))

	local days_to_add_at_month_start = first_day.wday - 1
	local days_to_add_at_month_end = 42 - last_day.day - days_to_add_at_month_start

	local previous_month_last_day = os.date("*t", os.time{year = date.year, month = date.month, day = 0}).day
	for day = previous_month_last_day - days_to_add_at_month_start, previous_month_last_day - 1, 1 do
		self.days:add(date_widget(day, false, true))
	end

	for day = 1, month_days do
		local is_current = day == current_date.day and date.month == current_date.month
		self.days:add(date_widget(day, is_current, false))
	end

	for day = 1, days_to_add_at_month_end do
		self.days:add(date_widget(day, false, true))
	end
end

function calendar:set_date_current()
	self:set_date(os.date("*t"))
end

function calendar:increase_date()
	local new_calendar_month = self.date.month + 1
	self:set_date({year = self.date.year, month = new_calendar_month, day = self.date.day})
end

function calendar:decrease_date()
	local new_calendar_month = self.date.month - 1
	self:set_date({year = self.date.year, month = new_calendar_month, day = self.date.day})
end

local function new()
    local ret = gobject{}
    gtable.crush(ret, calendar, true)

	ret.month = wtbutton.normal
	{
		animate_size = false,
		text = os.date("%B %Y"),
		on_release = function()
			ret:set_date_current()
		end
	}

    local month = wibox.widget
    {
        layout = wibox.layout.align.horizontal,
        wtbutton.normal
        {
            forced_width = dpi(35),
            forced_height = dpi(35),
            font = beautiful.icons.caret_left.font,
            size = 15,
            text_normal_bg = beautiful.colors.on_background,
            text = beautiful.icons.caret_left.icon,
            on_release = function()
                ret:decrease_date()
            end
        },
		ret.month,
        wtbutton.normal
        {
            forced_width = dpi(35),
            forced_height = dpi(35),
            font = beautiful.icons.caret_right.font,
            size = 15,
            text_normal_bg = beautiful.colors.on_background,
            text = beautiful.icons.caret_right.icon,
            on_release = function()
                ret:increase_date()
            end
        }
    }

    ret.days = wibox.widget
    {
        layout = wibox.layout.grid,
        forced_num_rows = 6,
        forced_num_cols = 7,
        spacing = dpi(15),
        expand = true
    }

    local widget = wibox.widget
    {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(15),
        month,
        ret.days
    }

	ret:set_date(os.date("*t"))

	gtable.crush(widget, calendar, true)
	return widget
end

function calendar.mt:__call(...)
    return new(...)
end

return setmetatable(calendar, calendar.mt)