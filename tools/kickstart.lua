-- Kickstart the ULOS 2 install process

local ov = rawget(_G, "_OSVERSION")

local function printf(...)
  io.write(string.format(...))
end

local function fail(...)
  io.stderr:write("failed: ", string.format(...), "\n")
  os.exit(1)
end

if not (ov and ov:match("OpenOS")) then
  fail("this program requires OpenOS", 0)
end

local args = {...}

local url = "http://ulos.pickardayune.com/v2/ulos2-" .. args[1] .. ".lua"

local component = require("component")
local internet = component.list("internet")()
local computer = require("computer")
local fs = require("filesystem")

local function promptYN(thing, yes, no)
  printf("%s ", thing)
  local p = "[" .. (yes and "Y" or "y") .. "/" .. (no and "N" or "n") .. "] "
  local input
  repeat
    io.write(p)
    input = io.read("l")
  until (yes or no) or input:match("^[ynYN]$")

  if input == "" and yes then input = "y" end

  return input == "Y" or input == "y"
end

local function promptText(thing, default, canBeEmpty, verify)
  local input
  repeat
    if default then
      printf("%s [%s]: ", thing, default)
    else
      printf("%s: ", thing)
    end

    input = io.read("*l")
  until (verify and verify(input)) or canBeEmpty or #input > 0

  return input
end

local root = fs.get("/").address
local filesystems = {}
for addr in component.list("filesystem") do
  if addr ~= computer.tmpAddress() and
      not component.invoke(addr, "isReadOnly") then
    filesystems[#filesystems+1] = addr
  end
end

print([[
This tool will assist you in setting up the first stage of the ULOS 2
installation process.]])

local addr
while true do
  print("\nThe following filesystems are available:")

  for i=1, #filesystems do
    printf("%2d. %s\n", i, filesystems[i])
  end

  local num = tonumber(promptText("Select one", nil, false, function(x)
    return filesystems[tonumber(x) or 0]
  end))

  print("\n\27[31mAll data on the selected device will be erased.")
  print("\27[31mProceed with caution.\27[37m")
  if promptYN(string.format("Continue with %s?", filesystems[num]:sub(1,8)),
      true, false) then
    addr = filesystems[num]
    break
  end
end

local path = "/install"
if addr == root then
  -- preload wget's needed libs so we can remove everything
  require("internet")
  require("shell")
  require("text")
  path = "/"
else
  fs.mount(addr, path)
end

local wget = assert(loadfile("/bin/wget.lua"))

os.execute("rm -r "..path.."/*")

if not wget(url, path.."/init.lua") then
  print("The media creation process has failed.")
  if addr == root then
    print("\27[31m"..[[
Your system has been rendered unrecoverable. Use an OpenOS floppy disk to
reinstall and try again.]].."\27[37m")
    while true do coroutine.yield() end
  end
end

print("Setting media label")
component.invoke(addr, "setLabel", "ULOS 2 Installer")

print("The media creation process has succeded.")

if computer.setBootAddress then
  computer.setBootAddress(addr)
end

if addr == root then
  io.write("Rebooting in ")
  for i=5, 1, -1 do
    io.write(i.."...")
    rawget(os, "sleep")(1)
  end
  computer.shutdown(true)
elseif promptYN("Reboot now?", true, false) then
  computer.shutdown(true)
end
