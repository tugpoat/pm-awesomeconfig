local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")

local common = require("common")
local beautiful = common.beautiful


--beautiful.init("/home/pat/.config/awesome/themes/vaporwave/theme.lua")
local bat_name = "BAT0"

-- Spacers
--volspace = wibox.widget.textbox()
--volspace:set_text(" ")

-- {{{ BATTERY
-- Battery attributes
local bat_state  = ""
local bat_charge = 0
local bat_time   = 0
local blink      = true

-- Icon
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batfull)

-- Charge %
batpct = wibox.widget.textbox()
vicious.register(batpct, vicious.widgets.bat, function(widget, args)
  bat_state  = args[1]
  bat_charge = args[2]
  bat_time   = args[3]
  if args[1] == "-" then
    if bat_charge > 70 then
      baticon:set_image(beautiful.widget_batfull)
    elseif bat_charge > 30 then
      baticon:set_image(beautiful.widget_batmed)
    elseif bat_charge > 10 then
      baticon:set_image(beautiful.widget_batlow)
    else
      baticon:set_image(beautiful.widget_batempty)
    end
  else
    baticon:set_image(beautiful.widget_ac)
    if args[1] == "+" then
      blink = not blink
      if blink then
        baticon:set_image(beautiful.widget_acblink)
      end
    end
  end

  return args[2] .. "%"
end, nil, bat_name)

-- Buttons
function popup_bat()
  local state = ""
  if bat_state == "↯" then
    state = "Full"
  elseif bat_state == "↯" then
    state = "Charged"
  elseif bat_state == "+" then
    state = "Charging"
  elseif bat_state == "-" then
    state = "Discharging"
  elseif bat_state == "⌁" then
    state = "Not charging"
  else
    state = "Unknown"
  end

  naughty.notify { text = "Charge : " .. bat_charge .. "%\nState  : " .. bat_state ..
    " (" .. bat_time .. ")", timeout = 5, hover_timeout = 0.5 }
end
batpct:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
baticon:buttons(batpct:buttons())
-- End Battery}}}


-- {{{ Start Volume

volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

function update_volume(widget)
   local fd = io.popen("amixer sget Master")
   local status = fd:read("*all")
   fd:close()

   local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
   -- volume = string.format("% 3d", volume)

   status = string.match(status, "%[(o[^%]]*)%]")

   -- starting colour
   local sr, sg, sb = 0x3F, 0x3F, 0x3F
   -- ending colour
   local er, eg, eb = 0xDC, 0xDC, 0xCC

   local ir = math.floor(volume * (er - sr) + sr)
   local ig = math.floor(volume * (eg - sg) + sg)
   local ib = math.floor(volume * (eb - sb) + sb)
   interpol_colour = string.format("%.2x%.2x%.2x", ir, ig, ib)
   if string.find(status, "on", 1, true) then
       volume = " <span background='#" .. interpol_colour .. "'>   </span>"
   else
       volume = " <span color='red' background='#" .. interpol_colour .. "'> M </span>"
   end
   widget:set_markup(volume)
end

update_volume(volume_widget)

mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function () update_volume(volume_widget) end)
mytimer:start()

--}}}

-- {{{ Start CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
--
-- Initialize widget
cpu = awful.widget.graph()
-- Graph properties
cpu:set_width(50)
cpu:set_background_color("#494B4F")
cpu:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                    {1, "#AECF96" }}})
-- Register widget
vicious.register(cpu, vicious.widgets.cpu, "$1")

--cpu = wibox.widget.textbox()
--vicious.register(cpu, vicious.widgets.cpu, "All: $1% 1: $2% 2: $3% 3: $4% 4: $5%", 2)
-- End CPU }}}
--
-- {{{ Start Mem

memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_ram)
--
-- Initialize widget
mem = awful.widget.graph()
-- Progressbar properties
mem:set_width(50)
mem:set_background_color("#494B4F")
mem:set_border_color(nil)
mem:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#AECF96"}, {0.5, "#88A175"}, 
                    {1, "#FF5656"}}})
-- Register widget
vicious.register(mem, vicious.widgets.mem, "$1", 13)
-- End Mem }}}

fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs)

-- {{{ Start Wifi
wifiicon = wibox.widget.imagebox()
wifiicon:set_image(beautiful.widget_wifi)
--
wifi = wibox.widget.textbox()
vicious.register(wifi, vicious.widgets.wifiiw, "${ssid} Rate: ${rate}MB/s Link: ${linp}%", 3, "wlan0")
-- End Wifi }}}
