#!/bin/bash
# Assemble a ULOS release.  Once ULOS's structure is a bit
# more fleshed out there will be a Lua script available to
# do this from within ULOS itself. Because self-hosting is
# cool :)

printf "=> Removing old build files...\n"
rm -rf build cynosure-2/kernel.lua

printf "=> Creating base directory structure\n"
mkdir -p build/{boot,bin,lib,etc/ulos,usr/lib,usr/bin}

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
# compatibility with scripts starting with #!/usr/bin/env
mv build/bin/env build/usr/bin/env
cp -r luash/{bin,lib,etc} build/
cp -r liblua/lang build/etc/

printf "=> Setting file permissions\n"
for f in $(find build); do
  if [ $f != "build" ]; then
    mode=33188
    if [ -d $f ]; then
      mode=16804
    fi
    cat > $(dirname $f)/.$(basename $f).attr << EOF
mode:$mode
created:$(date +"%s")
EOF
  fi
done

printf "=> Marking programs executable\n"
for f in $(ls build/bin); do
  if [ "${f:1:1}" != "." ]; then
    cat > build/bin/.$f.attr << EOF
mode:33261
created:$(date +"%s")
EOF
  fi
done

for f in $(ls build/usr/bin); do
  if [ "${f:1:1}" != "." ]; then
    cat > build/usr/bin/.$f.attr << EOF
mode:33261
created:$(date +"%s")
EOF
  fi
done

printf "=> Done!\n"
