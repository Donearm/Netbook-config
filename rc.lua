-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")

-- {{{ Variable definitions
-- Home directory
home = os.getenv("HOME")
-- Themes define colours, icons, and wallpapers
theme_path = home .. "/.config/awesome/themes/dead_tree"
-- Actually load theme
beautiful.init(theme_path)
-- Define if we want to see naughty notifications
use_naughty = true
naughty.config.presets.normal.border_color = beautiful.naughty_border_color
naughty.config.border_width = 2
-- Define if we want to modify client.opacity
use_composite = false


-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "gvim"
editor_cmd = terminal .. " -e " .. editor


-- Some variables
browser_nav = "firefox -P navigation --no-remote"
browser_mad = "firefox -P maidens --no-remote"
music = "ario"
musicPlay = "gmusicbrowser -remotecmd PlayPause"
musicStop = "gmusicbrowser -remotecmd Stop"
musicPrev = "gmusicbrowser -remotecmd PrevSongInPlaylist"
musicNext = "gmusicbrowser -remotecmd NextSongInPlaylist"
soundLowerVolume = "amixer set Master 2dB-"
soundRaiseVolume = "amixer set Master 2dB+"
soundMute = "amixer set Master 0%"
filemanager = "thunar"
mail = "urxvtc -e mutt -y"
lockScreen = "xscreensaver-command -lock"
networkManager = "wicd-client -n" -- my network manager of choice
spacer = " " -- well, just a spacer

-- Alt is Mod1
alt = "Mod1"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}



-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ Functions

-- Mouse remove function
-- basically move the pointer to the bottom right of the screen with
-- Mod4+Ctrl+m, useful to remove it when it stands in the middle of the
-- screen but without using the touchpad
local safeCoords = {x=1680, y=1050}
function moveMouse(x_co, y_co)
    mouse.coords({ x=x_co, y=y_co })
end


-- Markup functions
function setBg(bgcolor, text)
    return '<bg color="'..bgcolor..'" />'..text
end

function setFg(fgcolor, text)
    return '<span color="'..fgcolor..'">'..text..'</span>'
end

function setBgFg(bgcolor, fgcolor, text)
    return '<bg color="'..bgcolor..'" /><span color="'..fgcolor'">'..text..'</span>'
end

function setFont(font, text)
    return '<span font_desc="'..font..'">'..text..'</span>'
end

-- Wifi signal
function wifiInfo(adapter)
    local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
    local wifiStrength = f:read()
    f:close()


    if wifiStrength == "0" then
        wifiStrength = setFg('#ff6565', wifiStrength) .. "%"
        naughty.notify({ title = "Wifi message",
            text = "No wireless connectivity!",
            timeout = 3,
            position = "top_right",
            fg = beautiful.fg_focus,
            bg = beautiful.bg_focus
        })
    else
        wifiStrength = wifiStrength.."%"
    end
    wifiwidget.text = setFg(beautiful.fg_normal, wifiStrength) 
end



-- Temp functions
function getCpuTemp ()
	local f = io.popen('cut -b 26-28 /proc/acpi/thermal_zone/TZ00/temperature')
	local n = f:read()
	f:close()
	--return '<span color="#fbfbfb">' .. " " .. n .. '°C </span>'
    return  setFg(beautiful.fg_normal, ' '..n..'°C')
end

function getMoboTemp ()
  local f = io.popen('cut -b 1-2 /sys/module/w83627ehf/drivers/platform\:w83627ehf/w83627ehf.656/temp2_input')
  local n = f:read()
  f:close()
  return setFg(beautiful.fg_normal, ' '..n..'°C ')
end

function getGpuTemp ()
    local f = io.popen(home .. "/.conky/nvidiatemp")
	--local f = io.popen('nvidia-settings -q GPUCoreTemp | grep Attribute | grep -o "[0-9][0-9*]"')
	local n = f:read()
	f:close()
    --if (n == nil) then
    --    return ''
    --end
    --if tonumber(n) >= 70 then
    --    n = setFg("#aadc43", n)
    --end
	--return setFg(beautiful.fg_normal, n..'°C ')
    return n
end

function getSdaTemp ()
	local f = io.popen("sudo hddtemp /dev/sda | awk '{print $4}'")
	local n = f:read()
	f:close()
	return setFg(beautiful.fg_normal, ' '..n..'°C ')
end


-- Battery level
function batteryInfo(adapter)
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    fcur:close()
    local cap = fcap:read()
    fcap:close()
    local sta = fsta:read()
    fsta:close()

    local battery = math.floor(cur * 100 / cap)

    if sta:match("Charging") then
        dir = "^"
        battery = battery.."%"..dir
    elseif sta:match("Discharging") then
        dir = "v"
        --battery  = dir..battery.."%"..dir
        if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
            local battery_perc = battery.."%"..dir
            battery = setFg("#e6d51d", battery_perc)
        elseif tonumber(battery) < 25 then
            if tonumber(battery) <= 5 then
                naughty.notify({ title = "Battery Warning",
                    text = "Battery low!"..spacer..battery.."%"..spacer.."left!",
                    timeout = 5,
                    position = "top_right",
                    fg = beautiful.fg_focus,
                    bg = beautiful.bg_focus
                })
            end
            local battery_perc = battery.."%"..dir
            battery = setFg("#ff6565", battery)
        end
    else
        dir = "="
        battery = "AC"..dir
    end

    batterywidget.text = spacer..setFg(beautiful.fg_normal, battery)
end

-- Volume Info
function volInfo()
    local status = io.popen("amixer -c "..cardid.." -- sget "..channel):read("*all")
    local volume = string.match(status, "(%d?%d?%d)%%") 
    volume = string.format("% 3d", volume)
    status = string.match(status, "%[(o[^%]]*)%]")

    if string.find(status, "on", 1, true) then
        volume = volume.."%"
    else
        volume = volume.."M"
    end

    --volumewidget.text = setFg(beautiful.fg_normal, "Vol:")..volume
    volumewidget.text = setFg(beautiful.fg_normal, volume)
end

-- Calendar functions

local calendar = nil
local offset = 0

function removeCalendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function addCalendar(inc_offset)
    local save_offset = offset
    removeCalendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
        timeout = 0,
        hover_timeout = 0.5,
        width = 200,
    })
end

-- Gmail function
function getGmailUnread()
    -- check if the network is up by pinging the router
    local eth0up = os.execute("ping -c 1 192.168.0.1")
    if eth0up == nil then
        -- if no connection available, return 0 
        return spacer .. '0/0'
    else
        local unread = io.popen(home .. "/Script/imap_check.py")
        local f = unread:read()
        unread:close()
        return spacer .. setFg(beautiful.fg_normal, f)
    end
end

-- And the function to read the temporary file
function runGmailCheck()
    os.execute(home .. "/Script/imap_check.py > /tmp/gmailcheck &")
end

-- }}}

-- {{{ Tags
tags = {}
tags.setup = {
    { name = "1", layout = layouts[1] },
    { name = "2", layout = layouts[1] },
    { name = "3", layout = layouts[1] },
    { name = "4", layout = layouts[1] }
}
-- Define tags table.
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Create 4 tags per screen.
    for i, t in ipairs(tags.setup) do
        tags[s][i] = tag({ name = t.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", t.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", t.mwfact)
        awful.tag.setproperty(tags[s][i], "hide", t.hide)
    end
    tags[s][1].selected = true
end
-- }}}


-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "lock screen", "xscreensaver-command -lock" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "reboot", "sudo reboot"}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, image(home .. "/.icons/archlinux-wm-awesome.png") },
                                        { "open terminal", terminal, image("/usr/share/pixmaps/rxvt-unicode.png") },
                                        { "firefox (navigation)", "firefox -P navigation --no-remote", image("/usr/share/pixmaps/firefox.png") },
                                        { "firefox (maidens)", "firefox -P maidens --no-remote", image("/usr/share/pixmaps/firefox.png") },
                                        { "chromium", "chromium-browser --enable-plugins", image("/usr/share/pixmaps/chromium-browser.png") },
                                        { "thunar", "thunar", image(home .. "/.icons/thunar-logo.png") },
                                        { "Music", music, image("/usr/share/ario/art/ario.png") },
                                        --{ "Pidgin", "pidgin", image("/usr/share/icons/hicolor/16x16/apps/pidgin.png") },
                                        { "Skype", "skype", image("/usr/share/pixmaps/skype.png") },
                                        { "HP Toolbox", "hp-toolbox", image("/usr/share/hplip/data/images/32x32/hp_logo.png") },
                                        --{ "Avidemux", "avidemux2_gtk", image("/usr/share/pixmaps/avidemux.png") },
                                        --{ "Gimp", "gimp", image("/usr/share/gimp/2.0/images/gimp-logo.png") },
                                        { "Gcolor", "gcolor2", image("/usr/share/pixmaps/gcolor2/icon.png") },
                                        { "Gtkam", "gtkam", image("/usr/share/pixmaps/gtkam.png") }
                                      }
                            })

-- Launchbox
mylauncher = awful.widget.launcher({ image = image(home .. "/.icons/arch-logo.png"),
                                     menu = mymainmenu })
-- Cpu widget
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(home .. "/.icons/intel_atom.png")
cpuwidget01 = widget({ type = "textbox" })
vicious.register(cpuwidget01, vicious.widgets.cpu,
	' <span color="#fbfbfb">[</span>$1%<span color="#fbfbfb">]</span>')
cpuwidget02 = widget({ type = "textbox" })
vicious.register(cpuwidget02, vicious.widgets.cpu,
	' <span color="#fbfbfb">[</span>$2%<span color="#fbfbfb">]</span>')

-- Motherboard icon
--moboicon = widget({ type = "imagebox", name = "moboicon", align = "right" })
--moboicon.image = image(home .. "/.icons/motherboard.png")

-- Gpu icon
--gpuicon = widget({ type = "imagebox", name = "gpuicon", align = "right" })
--gpuicon.image = image(home .. "/.icons/nvidia-black.png")

-- Memory widget
memwidget = widget({ type = "textbox"})
vicious.register(memwidget, vicious.widgets.mem, " $1%")
memicon = widget({ type = "imagebox"})
memicon.image = image(home .. "/.icons/ram_drive.png")

-- Network widget
netupicon = widget({ type = "imagebox"})
netupicon.image = image(home .. "/.icons/up_arrow.png")
netdownicon = widget({ type = "imagebox" })
netdownicon.image = image(home .. "/.icons/down_arrow.png")
netupwidget = widget({ type = "textbox"})
-- the last 3 options are interval-in-seconds, properties-name, padding
vicious.register(netupwidget, vicious.widgets.net,
	'${wlan0 up_kb}', nil, nil, 3)
netdownwidget = widget({ type = "textbox"})
vicious.register(netdownwidget, vicious.widgets.net,
	'${wlan0 down_kb}', nil, nil, 3)

-- Wifi widget
wifiicon = widget({ type = "imagebox"})
wifiicon.image = image(home .. "/.icons/WiFiTrack.png")
wifiicon:buttons({
    awful.button({ }, 1, function () awful.util.spawn(networkManager) end),
    awful.button({ }, 3, function () awful.util.spawn(networkManager) end)
})
wifiwidget = widget({ type = "textbox"})
vicious.register(wifiwidget, vicious.widgets.wifi, "${rate}", 60, 'wlan0')

-- Battery widget
batteryicon = widget({ type = "imagebox"})
batteryicon.image = image(home .. "/.icons/BatteryTicker.png")
batterywidget = widget({ type = "textbox"})
--batteryInfo("BAT0")
vicious.register(batterywidget, vicious.widgets.bat, '$2', 60, 'BAT0')

-- Temperatures
cputemp = widget({ type = 'textbox'})
vicious.register(cputemp, getCpuTemp, "$1", 30)

--mobotemp = widget({ type = 'textbox'})
--vicious.register(mobotemp, getMoboTemp, "$1", 30)

--gputemp = widget({ type = 'textbox'})
--vicious.register(gputemp, getGpuTemp, "$1", 30)
 
--sdatemp = widget({ type = 'textbox'})
--vicious.register(sdatemp, getSdaTemp, "$1", 30)

-- Volume widget
volumeicon = widget({ type = "imagebox"})
volumeicon.image = image(home .. "/.icons/speaker.png")

volumewidget = widget({ type = "textbox"})
-- enable caching
vicious.enable_caching(vicious.widgets.volume)
vicious.register(volumewidget, vicious.widgets.volume, "$1%", 2, "Master")
volumewidget:buttons(awful.util.table.join(
    awful.button({ }, 4, function() awful.util.spawn(soundRaiseVolume) end),
    awful.button({ }, 5, function() awful.util.spawn(soundLowerVolume) end),
    awful.button({ }, 3, function() awful.util.spawn(soundMute) end)
    ))

-- Gmail widget
--gmailicon = widget({ type = "imagebox"})
--gmailicon.image = image(home .. "/.icons/gmail-black.png")
--gmailwidget = widget({ type = "textbox" })
--gmailwidget.text = getGmailUnread
--vicious.register(gmailwidget, getGmailUnread, nil, 60)

-- {{{ Wibox
-- Set the default text in textbox
mypromptbox = widget({ type = "textbox" })

-- Date widget
datebox = widget({ type = "textbox"})
datebox:add_signal("mouse::enter", function () addCalendar(0) end)
datebox:add_signal("mouse::leave", function () removeCalendar() end)
datebox.buttons = awful.util.table.join(
    awful.button({ }, 4, function () addCalendar(-1) end),
    awful.button({ }, 5, function () addCalendar(1) end)
)
vicious.register(datebox, vicious.widgets.date, setFg('white', "  %T  "))


-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
        awful.button({ }, 1, awful.tag.viewonly),
        awful.button({ modkey }, 1, awful.client.movetotag),
		awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, awful.client.toggletag),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
        )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
			awful.button({ }, 1, function () awful.layout.inc(layouts, 1)
				naughty.notify({ text = awful.layout.getname(awful.layout.get(1))}) end),
			awful.button({ }, 3, function () awful.layout.inc(layouts, -1)
				naughty.notify({ text = awful.layout.getname(awful.layout.get(1))}) end),
			awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mylayoutbox[s].image = image("/usr/share/awesome/themes/default/layouts/tilew.png")

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ 
        position = "top", 
        screen = s,
        fg = beautiful.fg_normal, 
        bg = beautiful.bg_normal, 
        height = 18 })
    -- Add widgets to the wibox, in this order
    mywibox[s].widgets = {
		{
			mytaglist[s],
			mylauncher,
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
			s == screen.count() and mysystray or nil,
			mylayoutbox[s],
			datebox,
			batterywidget,
			batteryicon,
			--gmailwidget,
			--gmailicon,
			volumewidget,
			volumeicon,
			wifiwidget,
			wifiicon,
			netdownwidget,
			netdownicon,
			netupwidget,
			netupicon,
			memwidget,
			memicon,
			cpuwidget02,
			cpuwidget01,
			cputemp,
			cpuicon,
			mytasklist[s],
			layout = awful.widget.layout.horizontal.rightleft
		}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ alt },               "m",   function () awful.util.spawn(music) end),
    awful.key({ modkey },            "f",   function () awful.util.spawn(browser_mad) end),
    awful.key({ modkey, alt       }, "f",   function () awful.util.spawn(browser_nav) end),
    awful.key({ none }, "XF86AudioPlay",    function () awful.util.spawn(musicPlay) end),
    awful.key({ none }, "XF86AudioStop",    function () awful.util.spawn(musicStop) end),
    awful.key({ none }, "XF86AudioPrev",    function () awful.util.spawn(musicPrev) end),
    awful.key({ none }, "XF86AudioNext",    function () awful.util.spawn(musicNext) end),
    awful.key({ none }, "XF86AudioLowerVolume", function () awful.util.spawn(soundLowerVolume) end),
    awful.key({ none }, "XF86AudioRaiseVolume", function () awful.util.spawn(soundRaiseVolume) end),
    awful.key({ none }, "XF86AudioMute",    function () awful.util.spawn(soundMute) end),
    awful.key({ none }, "XF86Sleep",    function () awful.util.spawn(lockScreen) end),
    awful.key({ none }, "XF86Mail",     function () awful.util.spawn(mail) end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Control" }, "m", function() moveMouse(safeCoords.x, safeCoords.y) end),
    -- Win+z: stop any widget but battery and wifi, Win+Shift+z:
    -- reactivate all widgets
    awful.key({ modkey,           }, "z", function() io.popen(home .. "/Script/awesome_widgets.sh stop") end),
    awful.key({ modkey, "Shift"   }, "z", function() io.popen(home .. "/Script/awesome_widgets.sh start") end),
	
	-- Alt+t: disable touchpad; Win+Alt+t: enable touchpad
	awful.key({ alt },				 "t", function() io.popen(home .. "/Script/script_touchpad.sh off") end),
	awful.key({ modkey, alt		  }, "t", function() io.popen(home .. "/Script/script_touchpad.sh on") end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Mod4+s set the window sticky; pressing it again leave the window
    -- only on the current tag
    awful.key({ modkey },            "s",     function ()
        for s = 1, screen.count( ) do
            tagtable = screen[s]:tags()
            for k,t in pairs(tagtable) do
                if t ~= awful.tag.selected() then
                    awful.client.toggletag ( t, c )
                end
            end
        end
    end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
	awful.key({ modkey,			  }, "n",	   function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,}, "m",
    awful.key({ modkey }, "t", awful.client.togglemarked),
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
        awful.key({ modkey, "Shift" }, "F" .. i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          for k, c in pairs(awful.client.getmarked()) do
                              awful.client.movetotag(tags[screen][i], c)
                          end
                      end
                   end)
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "gcolor2" },
      properties = { floating = true } },
    { rule = { class = "ario" },
      properties = { floating = true } },
    { rule = { class = "Firefox:Dialog" },
      properties = { floating = true } },
    { rule = { class = "skype" },
      properties = { floating = true } },
    { rule = { class = "hp-toolbox" },
      properties = { floating = true } },
    { rule = { class = "evince" },
      properties = { floating = true } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Chats" },
      properties = { tag = tags[1][4] } },
    }


-- {{{ Autorun apps
autorun = true
autorunApps =
{
    --"xscreensaver",
    "xbindkeys",
    "xcompmgr -c -C -r10 -o.70 -D5 &",
    "xset m 1 2",
    "urxvtd -q -o -f",
}
if autorun then
    for app = 1, #autorunApps do
        awful.util.spawn(autorunApps[app]) 
     end
end
		
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- add a titlebar to each floating client
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
    --    if not c.titlebar and c.class ~= "Xmessage" then
    --        awful.titlebar.add(c, { modkey = modkey })
    --    end
        -- floating clients are always on top
        c.above = true
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
 
    -- client placement
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    -- honor size hints
    c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.add_signal("marked", function (c) c.border_color = beautiful.border_marked end)

client.add_signal("manage", function (c, startup)
	-- if we are not managing this application at startup,
	-- move it to the screen where the mouse is.
	-- we only do it for filtered windows (i.e. no dock, etc).
	if not startup and awful.client.focus.filter(c) then
		c.screen = mouse.screen
	end
end)


-- }}}
    -- I want Mplayer sticky in all tags
    -- well better not I guess, can't reduce to icon
    --if c.name:find("MPlayer") then
    --    for s = 1, screen.count() do
    --        tagtable = screen[s]:tags()
    --        for k,t in pairs(tagtable) do
    --            if t ~= awful.tag.selected() then
    --                awful.client.toggletag(t, c)
    --            end
    --        end
    --    end
    --end
    

    -- Check application->screen/tag mappings.

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
--    client.focus = c

    -- Set key bindings
--    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
--    c.size_hints_honor = false
--end)


-- Hook called every minute
--timer60 = timer { timeout = 60 }
--timer60:add_signal("timeout", function() datebox.text = os.date(" %a %b %d, %H:%M ")
--timer60:start()
--
-- Timer for imap_check.py, 10min
-- mailtimer = timer { timeout = 600 }
-- mailtimer:add_signal("timeout", runGmailCheck())
-- mailtimer:start()
--
-- Timer for batteryInfo
--batterytimer = timer { timeout = 60 }
--batterytimer:add_signal("timeout", function() batteryInfo("BAT0") end)
--batterytimer:start()
--
-- Timer for wifiInfo
--wifitimer = timer { timeout = 30 }
--wifitimer:add_signal("timeout", function() wifiInfo("wlan0") end)
--wifitimer:start()
-- vim: set filetype=lua tabstop=4 shiftwidth=4:
