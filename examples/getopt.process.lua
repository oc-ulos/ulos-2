local argv = require("argcompat").command("example", ...)

local getopt = require("getopt")

local args, opts, usage = getopt.process {
  { "Show this help message", false, "h", "help" },
  { "Be verbose",             false, "v", "verbose" },
  { "Print version and exit", false, "V", "version" },
  exit_on_bad_opt = false,
  args = argv,
}

if opts.h then
  io.stderr:write(string.format([[
usage: example [options]

options:
%s
]], usage))
  os.exit(0)
end

print(table.unpack(args))
