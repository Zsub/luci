-- Copyright 2017 Dirk Brenken (dev@brenken.org)
-- This is free software, licensed under the Apache License, Version 2.0

local fs = require("nixio.fs")
local uci = require("uci")
local sys = require("luci.sys")
local json = require("luci.jsonc")
local trminput = uci.get("travelmate", "global", "trm_rtfile") or "/tmp/trm_runtime.json"
local parse = json.parse(fs.readfile(trminput) or "")

m = Map("travelmate", translate("Travelmate"),
	translate("Configuration of the travelmate package to to enable travel router functionality. ")
	.. translate("For further information ")
	.. [[<a href="https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md" target="_blank">]]
	.. translate("see online documentation")
	.. [[</a>]]
	.. translate("."))

-- Main travelmate options

s = m:section(NamedSection, "global", "travelmate")

o1 = s:option(Flag, "trm_enabled", translate("Enable travelmate"))
o1.default = o1.disabled
o1.rmempty = false

o2 = s:option(Flag, "trm_automatic", translate("Enable 'automatic' mode"),
	translate("Keep travelmate in an active state."))
o2.default = o2.enabled
o2.rmempty = false

o3 = s:option(Value, "trm_iface", translate("Restrict interface trigger to certain interface(s)"),
	translate("Space separated list of interfaces that trigger travelmate processing. "..
	"To disable event driven (re-)starts remove all entries."))
o3.rmempty = true

o4 = s:option(Value, "trm_triggerdelay", translate("Trigger delay"),
	translate("Additional trigger delay in seconds before travelmate processing begins."))
o4.default = 2
o4.datatype = "range(1,90)"
o4.rmempty = false

o5 = s:option(Flag, "trm_debug", translate("Enable verbose debug logging"))
o5.default = o5.disabled
o5.rmempty = false

-- Runtime information

ds = s:option(DummyValue, "_dummy", translate("Runtime information"))
ds.template = "cbi/nullsection"

dv1 = s:option(DummyValue, "status", translate("Online Status"))
dv1.template = "travelmate/runtime"
if parse == nil then
	dv1.value = translate("n/a")
elseif parse.data.station_connection == "true" then
	dv1.value = translate("connected")
else
	dv1.value = translate("not connected")
end

dv2 = s:option(DummyValue, "travelmate_version", translate("Travelmate version"))
dv2.template = "travelmate/runtime"
if parse ~= nil then
	dv2.value = parse.data.travelmate_version or translate("n/a")
else
	dv2.value = translate("n/a")
end

dv3 = s:option(DummyValue, "station_ssid", translate("Station SSID"))
dv3.template = "travelmate/runtime"
if parse ~= nil then
	dv3.value = parse.data.station_ssid or translate("n/a")
else
	dv3.value = translate("n/a")
end

dv4 = s:option(DummyValue, "station_interface", translate("Station Interface"))
dv4.template = "travelmate/runtime"
if parse ~= nil then
	dv4.value = parse.data.station_interface or translate("n/a")
else
	dv4.value = translate("n/a")
end

dv5 = s:option(DummyValue, "station_radio", translate("Station Radio"))
dv5.template = "travelmate/runtime"
if parse ~= nil then
	dv5.value = parse.data.station_radio or translate("n/a")
else
	dv5.value = translate("n/a")
end

dv6 = s:option(DummyValue, "last_rundate", translate("Last rundate"))
dv6.template = "travelmate/runtime"
if parse ~= nil then
	dv6.value = parse.data.last_rundate or translate("n/a")
else
	dv6.value = translate("n/a")
end

-- Extra options

e = m:section(NamedSection, "global", "travelmate", translate("Extra options"),
translate("Options for further tweaking in case the defaults are not suitable for you."))

e1 = e:option(Value, "trm_radio", translate("Radio selection"),
	translate("Restrict travelmate to a dedicated radio, e.g. 'radio0'"))
e1.rmempty = true

e2 = e:option(Value, "trm_maxretry", translate("Connection Limit"),
	translate("How many times should travelmate try to connect to an Uplink"))
e2.default = 3
e2.datatype = "range(1,10)"
e2.rmempty = false

e3 = e:option(Value, "trm_maxwait", translate("Interface Timeout"),
	translate("How long should travelmate wait for a successful wlan interface reload"))
e3.default = 30
e3.datatype = "range(5,60)"
e3.rmempty = false

e4 = e:option(Value, "trm_timeout", translate("Overall Timeout"),
	translate("Timeout in seconds between retries in 'automatic' mode"))
e4.default = 60
e4.datatype = "range(5,300)"
e4.rmempty = false

return m
