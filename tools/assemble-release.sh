#!/bin/bash
# Assemble a ULOS release.  Once ULOS's structure is a bit
# more fleshed out there will be a Lua script available to
# do this from within ULOS itself. Because self-hosting is
# cool :)

printf "=> Removing old build files...\n"
rm -rf build cynosure-2/kernel.lua

printf "=> Creating base directory structure\n"
mkdir -p build/{boot,bin,lib,etc/ulos,usr/lib}

printf "=> Assembling Cynosure 2\n"
cd cynosure-2
lua scripts/build.lua | tail -n 1
cd ..

printf "=> Assembling the Cynosure Loader\n"
cd cldr
lua scripts/preproc.lua src/main.lua cldr.lua | tail -n 1
cd ..

printf "=> Copying in files\n"
cp cldr/cldr.lua build/init.lua
cp config/cldr.cfg build/boot/cldr.cfg
cp config/{inittab,fstab,os-release} build/etc/
cp config/profile.lua build/etc/
cp cynosure-2/kernel.lua build/boot/cynosure.lua
cp reknit/init.lua build/bin/
cp -r liblua/src/ build/lib/lua
mv build/lib/{lua/,}package.lua
cp coreutils/src/* build/bin/
cp -r luash/{bin,lib,etc} build/
cp -r liblua/lang build/etc/

printf "=> Done!\n"
