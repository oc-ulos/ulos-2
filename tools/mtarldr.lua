-- self-extracting mtar loader thingy: header --
-- this is designed for minimal overhead, not speed.
-- Expects an MTAR v1 archive.  Will not work with v0 or v2.
-- Modified to support Cynosure 2.

local fs = component.proxy(computer.getBootAddress())
local gpu = component.proxy(component.list("gpu")())
gpu.bind(gpu.getScreen() or (component.list("screen")()))

-- filesystem tree
local files = {
  ["/"] = {children = {}}
}

local handle = assert(fs.open("/init.lua", "r"))

local seq = {"|","/","-","\\"}
local si = 1

local w, h = gpu.maxResolution()
gpu.setResolution(gpu.maxResolution())
gpu.fill(1, 1, w, h, " ")
gpu.setForeground(0)
gpu.setBackground(0xFFFFFF)
local text = "Cynosure MTAR-FS Loader"
gpu.set(1, 1, (" "):rep(math.floor((w-#text)/2))..text..(" "):rep(math.ceil((w-#text)/2)))
gpu.setBackground(0)
gpu.setForeground(0xFFFFFF)

local function status(x, y, t, c)
  if c then gpu.fill(1, y+1, 50, 1, " ") end
  gpu.set(x, y+1, t)
end

local CHUNKS = 2048
local startoffset = 0
status(1, 1, "Seeking to data section...")
local last_time = computer.uptime()
while true do
  local chunk = fs.read(handle, CHUNKS)
  startoffset = startoffset + CHUNKS
  if chunk:match("\90") then
    startoffset = startoffset - (CHUNKS - chunk:find("\90"))
    fs.seek(handle, "set", startoffset)
    break
  end
  local t = computer.uptime()
  if t - last_time >= 0.1 then
    status(28, 1, seq[si])
    si = si + 1
    if not seq[si] then si = 1 end
    last_time = t
  end
end

assert(fs.read(handle, 1) == "\n") -- skip \n

local function split_path(path)
  local s = {}
  for _s in path:gmatch("[^\\/]+") do
    if _s == ".." then
      s[#s] = nil
    elseif s ~= "." then
      s[#s+1]=_s
    end
  end
  return s
end

local function clean_path(name)
  return table.concat(split_path(name), "/")
end

local function add_to_tree(name, offset, len)
  local cleaned = clean_path(name)
  local segments = split_path(name)

  for i=1, #segments do
    local path = table.concat(segments, "/", 1, i-1)
    files[path] = files[path] or {children = {}}
    local add = true

    for _, child in pairs(files[path].children) do
      if child == segments[i] then add = false  break end
    end
    
    if add then files[path].children[#files[path].children+1] = segments[i] end
  end

  files[cleaned] = {offset = offset, length = len}
end

local function read(n, offset, rdata)
  if offset then fs.seek(handle, "set", offset) end
  local to_read = n
  local data = ""
  while to_read > 0 do
    local n = math.min(2048, to_read)
    to_read = to_read - n
    local chunk = fs.read(handle, n)
    if rdata then data = data .. (chunk or "") end
  end
  return data
end

local function read_header()
  -- skip V1 header
  fs.read(handle, 3)
  local namelen = fs.read(handle, 2)
  if not namelen then
    return nil
  end
  namelen = string.unpack(">I2", namelen)
  local name = read(namelen, nil, true)
  local flendat = fs.read(handle, 8)
  if not flendat then return end
  local flen = string.unpack(">I8", flendat)
  local offset = fs.seek(handle, "cur", 0)
  local t = computer.uptime()
  if t - last_time >= 0.1 then
    status(25, 2, seq[si])
    si = si + 1
    if not seq[si] then si = 1 end
    last_time = t
  end
  fs.seek(handle, "cur", flen)
  add_to_tree(name, offset, flen)
  return true
end

status(1, 2, "Reading file headers... ")
repeat until not read_header()

-- create the mtar fs node --

local function find(f)
  local ent = files[clean_path(f)]
  if not ent then return nil, "file not found" end
  return ent
end

local obj = {}

function obj.exists(f)
  checkArg(1, f, "string")

  return not not find(f)
end

function obj.isDirectory(f)
  local n, e = find(f)

  if n then
    return not not n.children
  else
    return nil, e
  end
end

local function roerr()
  return nil, "device is read-only"
end

local function r0()
  return 0
end

obj.size = r0
obj.lastModified = r0
obj.remove = roerr
obj.makeDirectory = roerr

function obj.list(d)
  local n, e = find(d)

  if not n then return nil, e end
  if not n.children then return nil, "not a directory" end

  local f = {}

  for k, v in pairs(n.children) do
    f[#f+1] = tostring(v)
  end

  return f
end

local function ferr()
  return nil, "bad file descriptor"
end

local _handle = {}

function _handle:read(n)
  checkArg(1, n, "number")
  if self.fptr >= self.node.length then return nil end
  n = math.min(self.fptr + n, self.node.length)
  local data = read(n - self.fptr, self.fptr + self.node.offset, true)
  self.fptr = n
  if #data == 0 then return nil end
  return data
end

_handle.write = roerr

function _handle:seek(origin, offset)
  checkArg(1, origin, "string")
  checkArg(2, offset, "number", "nil")
  local n = (origin == "cur" and self.fptr) or (origin == "set" and 0) or
    (origin == "end" and self.node.length) or
    (error("bad offset to 'seek' (expected one of: cur, set, end, got "
      .. origin .. ")"))
  n = n + (offset or 0)
  if n < 0 or n > self.node.length then
    return nil, "cannot seek there"
  end
  self.fptr = n
  return n
end

function _handle:close()
  if self.closed then
    return ferr()
  end

  self.closed = true
end

function obj.open(f, m)
  checkArg(1, f, "string")
  checkArg(2, m, "string")

  if m:match("[w%+]") then
    return nil, "device is read-only"
  end

  local n, e = find(f)

  if not n then return nil, e end
  if n.children then return nil, "is a directory" end

  local new = setmetatable({
    name = f,
    node = n, --data = read(n.length, n.offset, true),
    mode = m,
    fptr = 0
  }, {__index = _handle})

  return new
end

function obj.read(h, a)
  return h:read(a)
end

function obj.write(h, d)
  return h:write(d)
end

function obj.seek(h, ...)
  return h:seek(...)
end

function obj.close(h)
  return h:close()
end

function obj.getLabel() return "mtarfs" end

obj.type = "filesystem"
obj.address = "mtarfs("..fs.address..")"

status(1, 3, "Loading kernel...")

local hdl = assert(obj.open("/boot/cynosure.lua", "r"))
local ldme = hdl:read(hdl.node.length)
hdl:close()

_G.mtarfs = obj--[[
setmetatable({}, {__index = function(t,k)
  return function(...)
    status(156-#k, 1, k)
    return obj[k](...)
  end
end})--]]

status(1, 4, "Final collectgarbage()...")
for i=1, 20 do
  computer.pullSignal(0)
end

assert(load(ldme, "=mtarfs:/boot/cynosure.lua", "t", _G))(
  "root=mtar", "init=/bin/init.lua", "loglevel=5")

-- concatenate mtar data past this line
--[=======[Z
