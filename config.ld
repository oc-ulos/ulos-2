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
format = "markdown"

convert_opt = false

manual_url = "https://lua.org/manual/5.3/manual.html"

local upat = "http://www.kernel.org/doc/man-pages/online/pages/man%s/%s.%s.html"

custom_see_handler('^([%w_]+)%((%d)%)$',function(name,section)
    local url = upat:format(section,name,section)
    local name = name .. '(' ..section..')'
    return name, url
end)
