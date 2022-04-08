-- silly little welcome script

local args = ...

local hand, err = io.open("/etc/os-release")
if not hand then
  io.stderr:write(args[0], ": cannot open /etc/os-release: ", err, "\n")
else
  local data = hand:read("a")
  hand:close()

  local name = data:match("PRETTY_NAME=\"(.-)\"")
  local color = data:match("ANSI_COLOR=\"(.-)\"")
  if name and color then
    print(string.format("Welcome to \27[%sm%s\27[m!", color, name))
  end
end
