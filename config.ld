file = {
  "cynosure-2/src/syscalls.lua",
  "liblua/src/",
  exclude = {
    "liblua/src/sha3.lua",
    "liblua/src/posix",
    "liblua/src/syscalls.lua"
  }
}

project = "ULOS 2"
title = "ULOS 2 Reference"
description = [[
![ULOS 2 Logo](../ulos2-logo.png) The ULOS 2 Reference Manual

This website contains documentation for all the libraries ULOS 2 provides.  Program documentation is contained within ULOS 2 and can be viewed by passing `--help` to any command.
]]

format = "markdown"
dir = "docs"

convert_opt = false

manual_url = "https://lua.org/manual/5.3/manual.html"

local upat = "http://www.kernel.org/doc/man-pages/online/pages/man%s/%s.%s.html"

custom_see_handler('^([%w_]+)%((%d)%)$',function(name,section)
    local url = upat:format(section,name,section)
    local name = name .. '(' ..section..')'
    return name, url
end)

kind_names = { topic = "Manual", module = "Libraries", script = "Commands" }
