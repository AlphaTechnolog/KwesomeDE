local naughty = require("naughty")

local icons =
{
    "system-error",
    "dialog-error",
    "aptdaemon-error",
    "arch-error-symbolic",
    "data-error",
    "dialog-error-symbolic",
    "emblem-error",
    "emblem-insync-error",
    "error",
    "gnome-netstatus-error.svg",
    "gtk-dialog-error",
    "itmages-error",
    "mintupdate-error",
    "ownCloud_error",
    "script-error",
    "state-error",
    "stock_dialog-error",
    "SuggestionError",
    "yum-indicator-error"
}

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification
    {
        app_icon = icons,
        app_name = "Awesome",
        icon = icons,
        title = "Error" .. (startup and " during startup!" or "!"),
        message = message,
        urgency = "critical"
    }
end)