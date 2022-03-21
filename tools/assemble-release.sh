#!/bin/bash
# Assemble a ULOS release.  Once ULOS's structure is a bit
# more fleshed out there will be a Lua script available to
# do this from within ULOS itself. Because self-hosting is
# cool :)

printf "=> Removing old build files..."
rm -rf build cynosure-2/kernel.lua
