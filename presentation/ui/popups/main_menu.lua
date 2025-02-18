-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local awful = require("awful")
local widgets = require("presentation.ui.widgets")
local action_panel = require("presentation.ui.panels.action")
local message_panel = require("presentation.ui.panels.message")
local info_panel = require("presentation.ui.panels.info")
local app_launcher = require("presentation.ui.popups.app_launcher")
local screenshot_popup = require("presentation.ui.apps.screenshot")
local record_popup = require("presentation.ui.apps.record")
local hotkeys_popup = require("presentation.ui.popups.hotkeys")
local power_popup = require("presentation.ui.popups.power")
local theme_popup = require("presentation.ui.apps.theme")
local beautiful = require("beautiful")
local ipairs = ipairs
local capi = { awesome = awesome, screen = screen, tag = tag }

local recent_places_daemon = require("daemons.system.recent_places")

local instance = nil

local function recent_places_sub_menu()
    local menu = widgets.menu{}

    recent_places_daemon:connect_signal("update", function(self, recent_places)
        for _, place in ipairs(recent_places) do
            menu:add(widgets.menu.button
            {
                text = place.title,
                on_press = function() awful.spawn("xdg-open " .. place.path, false) end
            })
        end
    end)

    return menu
end

local function tag_sub_menu()
    local menu = widgets.menu{}

    local checkbox_color = beautiful.random_accent_color()

    for _, tag in ipairs(capi.screen.primary.tags) do
        local button = widgets.menu.checkbox_button
        {
            text = tag.name,
            checkbox_color = checkbox_color,
            on_press = function()
                tag:view_only()
            end
        }

        menu:add(button)

        tag:connect_signal("property::selected", function(t)
            if t.selected == true then
                button:turn_on()
            else
                button:turn_off()
            end
        end)
    end

    return menu
end

local function layout_sub_menu()
    local menu = widgets.menu{}

    capi.tag.connect_signal("property::selected", function(t)
        menu:reset()

        local checkbox_color = beautiful.random_accent_color()

        for _, layout in ipairs(t.layouts) do
            local button = widgets.menu.checkbox_button
            {
                text = layout.name,
                image = beautiful["layout_" .. (layout.name or "")],
                checkbox_color = checkbox_color,
                on_press = function()
                    t.layout = layout
                end
            }

            menu:add(button)

            if t.layout == layout then
                button:turn_on()
            else
                button:turn_off()
            end

            t:connect_signal("property::layout", function()
                if t.layout == layout then
                    button:turn_on()
                else
                    button:turn_off()
                end
            end)
        end
    end)

    return menu
end

local function widget()
    return widgets.menu
    {
        widgets.menu.button
        {
            icon = beautiful.icons.launcher,
            text = "Applicaitons",
            on_press = function() app_launcher:show() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.industry,
            text = "Action Panel",
            on_press = function() action_panel:toggle() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.message,
            text = "Message Panel",
            on_press = function() message_panel:toggle() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.calendar,
            text = "Info Panel",
            on_press = function() info_panel:toggle() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.keyboard,
            text = "Keybinds",
            on_press = function() hotkeys_popup.show_help() end
        },
        widgets.menu.separator(),
        widgets.menu.button
        {
            icon = beautiful.icons.camera_retro,
            text = "Screenshot",
            on_press = function() screenshot_popup:toggle() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.video,
            text = "Record",
            on_press = function() record_popup:toggle() end
        },
        widgets.menu.separator(),
        widgets.menu.sub_menu_button
        {
            icon = beautiful.icons.tag,
            text = "Tag",
            sub_menu = tag_sub_menu()
        },
        widgets.menu.sub_menu_button
        {
            icon = beautiful.icons.table_layout,
            text = "Layout",
            sub_menu = layout_sub_menu()
        },
        widgets.menu.separator(),
        widgets.menu.sub_menu_button
        {
            icon = beautiful.icons.folder_open,
            text = "Recent Places",
            sub_menu = recent_places_sub_menu()
        },
        widgets.menu.separator(),
        widgets.menu.button
        {
            icon = beautiful.icons.gear,
            text = "Settings",
            on_press = function() awful.spawn("dconf-editor", false) end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.spraycan,
            text = "Theme",
            on_press = function() theme_popup:toggle() end
        },
        widgets.menu.separator(),
        widgets.menu.button
        {
            icon = beautiful.icons.reboot,
            text = "Restart",
            on_press = function() capi.awesome.restart() end
        },
        widgets.menu.button
        {
            icon = beautiful.icons.exit,
            text = "Exit",
            on_press = function() power_popup:show() end
        }
    }
end

if not instance then
    instance = widget()
end
return instance