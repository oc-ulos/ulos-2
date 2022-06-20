local argv = require("argcompat").command("example", ...)

local getopt = require("getopt")

local options, usage, condense = getopt.build {
  { "Show this help message", false, "h", "help" },
  { "Be verbose",             false, "v", "verbose" },
  { "Print version and exit", false, "V", "version" }
}

local args, opts = getopt.getopt({
  options = options,
  exit_on_bad_opt = false,
}, argv)

condense(opts)

if opts.h then
  io.stderr:write(string.format([[
usage: example [options]

options:
%s
]], usage))
  os.exit(0)
end

print(table.unpack(args))
