---@diagnostic disable: lowercase-global
-- remove tmux stuff from hotkeys_popup
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- dpi function
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- json library
local json = require("json")

local cfg_dir = gears.filesystem.get_configuration_dir()

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(cfg_dir .. "theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
-- myawesomemenu = {
--    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
--    { "manual", terminal .. " -e man awesome" },
--    { "edit config", editor_cmd .. " " .. awesome.conffile },
--    { "restart", awesome.restart },
--    { "quit", function() awesome.quit() end },
-- }

-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                     { "open terminal", terminal }
--                                   }
--                         })

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                      menu = mymainmenu })

-- Menubar configuration
-- menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
-- local taglist_buttons = gears.table.join(
--                     awful.button({ }, 1, function(t) t:view_only() end),
--                     awful.button({ modkey }, 1, function(t)
--                                               if client.focus then
--                                                   client.focus:move_to_tag(t)
--                                               end
--                                           end),
--                     awful.button({ }, 3, awful.tag.viewtoggle),
--                     awful.button({ modkey }, 3, function(t)
--                                               if client.focus then
--                                                   client.focus:toggle_tag(t)
--                                               end
--                                           end),
--                     awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
--                     awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
--                 )

-- local tasklist_buttons = gears.table.join(
--                      awful.button({ }, 1, function (c)
--                                               if c == client.focus then
--                                                   c.minimized = true
--                                               else
--                                                   c:emit_signal(
--                                                       "request::activate",
--                                                       "tasklist",
--                                                       {raise = true}
--                                                   )
--                                               end
--                                           end),
--                      awful.button({ }, 3, function()
--                                               awful.menu.client_list({ theme = { width = 250 } })
--                                           end),
--                      awful.button({ }, 4, function ()
--                                               awful.client.focus.byidx(1)
--                                           end),
--                      awful.button({ }, 5, function ()
--                                               awful.client.focus.byidx(-1)
--                                           end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "tag_"..s.index.."1", "tag_"..s.index.."2", "tag_"..s.index.."3", "tag_"..s.index.."4", "tag_"..s.index.."5" }, s, awful.layout.layouts[1])
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    --           {description = "view previous", group = "tag"}),
    -- awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
    --           {description = "view next", group = "tag"}),
    -- awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    --           {description = "go back", group = "tag"}),

    awful.key({ modkey }, "Left",  function() 
        awful.client.focus.global_bydirection("left")
        if client.focus then client.focus:raise() end
    end, {description = "focus window left",  group = "tag"}),

    awful.key({ modkey }, "Right", function() 
        awful.client.focus.global_bydirection("right")
        if client.focus then client.focus:raise() end
    end, {description = "focus window right", group = "tag"}),

    awful.key({ modkey }, "Up",    function() 
        awful.client.focus.global_bydirection("up")
        if client.focus then client.focus:raise() end
    end, {description = "focus window up",    group = "tag"}),

    awful.key({ modkey }, "Down",  function() 
        awful.client.focus.global_bydirection("down")
        if client.focus then client.focus:raise() end
    end, {description = "focus window down",  group = "tag"}),


    awful.key({ modkey }, "h",  function() 
        awful.client.focus.global_bydirection("left")
        if client.focus then client.focus:raise() end
    end, {description = "focus window left",  group = "tag"}),

    awful.key({ modkey }, "l", function() 
        awful.client.focus.global_bydirection("right")
        if client.focus then client.focus:raise() end
    end, {description = "focus window right", group = "tag"}),

    awful.key({ modkey }, "k",    function() 
        awful.client.focus.global_bydirection("up")
        if client.focus then client.focus:raise() end
    end, {description = "focus window up",    group = "tag"}),

    awful.key({ modkey }, "j",  function() 
        awful.client.focus.global_bydirection("down")
        if client.focus then client.focus:raise() end
    end, {description = "focus window down",  group = "tag"}),

    awful.key({modkey}, "t", function ()
        naughty.notify({
            title = "Test Title",
            text = "Test Notification",
        })
    end),


    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ modkey }, "RightClick", function(c) end,
              {description = "resize client", group = "client"}),

    awful.key({ modkey }, "r", function(c)
        awful.tag.master_width_factor = 0.5
        awful.client.setwfact(0.5)
    end,
              {description = "resize back to default", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    -- awful.key({ modkey}, "h", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end,
            --   {description = "open the help menu with all shortcuts", group = "awesome"}),
    awful.key({ modkey }, "c", function() awful.spawn.spawn("code " .. cfg_dir .. "rc.lua") end,
            {description = "open the rc.lua file with code", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "c", function() awful.spawn.spawn(terminal .. " -e nano " .. cfg_dir .. "rc.lua") end,
                {description = "open the rc.lua file with code", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "e", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ "Control", "Shift"   }, "Escape", function () awful.spawn.spawn("alacritty --class \"TaskMgr\" -e btop") end,
              {description = "spawn floating alacritty window running btop with focus", group = "awesome"}),

    awful.key({ modkey }, "d", function () awful.spawn("rofi -show combi -theme rafl -monitor -1") end,
              {description = "launch rofi", group = "launcher"}),
    awful.key({ modkey }, "b", function () awful.spawn("brave") end,
              {description = "launch brave", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "p", function () awful.spawn("qpwgraph") end,
              {description = "launch patching software (qpwgraph)", group = "launcher"}),
    awful.key({ modkey }, "Print", function () awful.spawn("flameshot gui") end,
              {description = "launch flameshot", group = "launcher"}),

    -- awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    --           {description = "increase master width factor", group = "layout"}),
    -- awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    --           {description = "decrease master width factor", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    --           {description = "increase the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    --           {description = "decrease the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    --           {description = "increase the number of columns", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    --           {description = "decrease the number of columns", group = "layout"}),
    -- awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    --           {description = "select next", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"})

    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
            --   {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift" }, "space",  function(c)
        c.floating = not c.floating
        awful.placement.centered(c.focus)
    end,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            if c.maximized then
                c.border_width = 0
            else
                c.border_width = beautiful.border_width
            end
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"})
    -- awful.key({ modkey, "Control" }, "m",
    --     function (c)
    --         c.maximized_vertical = not c.maximized_vertical
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize vertically", group = "client"}),
    -- awful.key({ modkey, "Shift"   }, "m",
    --     function (c)
    --         c.maximized_horizontal = not c.maximized_horizontal
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 2, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        c.maximized = not c.maximized
        if c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    {
        rule_any = { class = { "Brave-browser", "discord", "Steam" }},
        properties = { screen = 2, tag = "t_21" }
    },
    {
        rule_any = { class = {
            "Polybar",
            "eww-primary_bar",
            "eww-secondary_bar"
        } },
        properties = { focusable = false, border_width = 0 }
    },
    {
        rule_any = { class = {"stalonetray"}},
        properties = {
            focusable = false,
            border_width = 0,
            above = true
        }
    },
    {
        rule_any = { class = {"eww-primary_bar", "eww-secondary_bar"}},
        properties = {
            focusable = false,
            border_width = 0,
            below = true,
            above = false
        }
    },

    { 
        -- Warhammer 40,000: Darktide
        rule_any = { class = { "steam_app_1361210" } },
        properties = { floating = true, fullscreen = true, screen = 1, sticky = true, ontop = true }
    },

    { 
        rule_any = { class = { "TaskMgr" } },
        properties = { floating = true, focus = true, ontop = true }
    },

    { rule_any = { type = { 'dialog', 'modal' } },
        properties = {
            ontop = true,
            floating = true,
            placement = awful.placement.centered
        }
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            -- awful.titlebar.widget.floatingbutton (c),
            -- awful.titlebar.widget.maximizedbutton(c),
            -- awful.titlebar.widget.stickybutton   (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            -- awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- client.connect_signal("property::fullscreen", function(c)
--     local function callback(stdout, stderr, exitreason, exitcode)

--             local pid = trim(stdout)
--             if not isempty(pid) then
--                 awful.spawn.spawn("polybar-msg -p " .. pid .. " cmd " .. show_hide)
--             end
--         end

--     local keys = {}
--     local n = 0
--     for s in screen do
--         n = n + 1
--         for key, val in pairs(s.outputs) do
--             keys[n] = key
--         end
--     end
--     cmd = cfg_dir .. "scripts/polybar_pid.sh " .. keys[c.screen.index]
--     if c.fullscreen then
--         show_hide = "hide"
--         awful.spawn.easy_async(cmd, callback)
--     else
--         show_hide = "show"
--         awful.spawn.easy_async(cmd, callback)
--     end

-- end)

tag.connect_signal("property::selected", function (t)
    local cmd = "$HOME/.config/custom_scripts/for_wm/python/tags.py client update"
    awful.spawn.with_shell(cmd)
end)

-- client.connect_signal("unmanage", function(c)
--     if c.fullscreen then
--         is_fs = "true"
--     else
--         is_fs = "false"
--     end

--     print(c.name .. ":" .. c.screen.index .. ": " .. is_fs)
-- end)

-- }}}


-- {{{ Autostart

-- awful.spawn.spawn(cfg_dir .. "scripts/polybar.sh")
awful.spawn.spawn(cfg_dir .. "scripts/picom.sh")
awful.spawn.with_shell("pkill -15 -x tags.py; $HOME/.config/custom_scripts/for_wm/python/tags.py server")
awful.spawn.with_shell("eww kill; eww daemon; eww open primary_bar; eww open secondary_bar; sleep 1; $HOME/.config/custom_scripts/for_wm/python/tags.py client update")
awful.spawn.spawn("discord")

-- }}}

-- {{{ CUSTOM FUNCTIONS
    
-- function get_tags()
--     local tags = "";
--     for s in screen do
--         tags = tags .. s.index .. ":"
--         for i, tag in ipairs(s.tags) do
--             tags = tags .. tag.name .. ";"
--         end
--         tags = tags .. ";"
--     end
--     return tags
-- end

function get_tags()
    local tags = {};
    for s in screen do
        local screen_tags = {}
        for i, tag in ipairs(s.tags) do
            local tag_table = {}
            tag_table["name"] = tag.name
            tag_table["selected"] = tag.selected
            table.insert(screen_tags, tag_table)
        end
        tags[s.index] = screen_tags
    end
    return json.encode(tags)
end

function trim(s)
    return s:match'^%s*(.*%S)' or ''
end

function isempty(s)
    return s == nil or s == ''
end

-- function get_outputs()
--     local screens = {}
--     for s in screen do
--         for key, val in pairs(s.outputs) do
--             screens[key] = s.index
--         end
--     end
--     return screens
-- end

-- function get_screen_by_name(name)
--     return get_outputs()[name]
-- end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
        return tostring(o)
    end
end
-- }}}


naughty.config.defaults.screen = "primary"
-- preferably do this with dpi scaling, but awful.screen.primary is null so lmao
-- that's because it's just screen.primary, retard
naughty.config.defaults.icon_size = 48
naughty.config.defaults.position = "top_right"
naughty.config.defaults.font = "SFNS Display 9"
naughty.config.defaults.max_width = 400
naughty.config.defaults.max_height = 450
naughty.config.defaults.margin = 16
naughty.config.padding = dpi(8)
naughty.config.spacing = dpi(8)
