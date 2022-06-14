#!/bin/bash
# Assemble a ULOS release.  Once ULOS's structure is a bit
# more fleshed out there will be a Lua script available to
# do this from within ULOS itself. Because self-hosting is
# cool :)

set -e

printf "=> Removing old build files...\n"
rm -rf build cynosure-2/kernel.lua /tmp/cynosure2buildoutput

printf "=> Creating base directory structure\n"
mkdir -p build/{boot,bin,lib,etc/ulos,usr/lib,usr/bin}

export OS="ulos2"

printf "=> Assembling Cynosure 2\n"
cp config/kconfig cynosure-2/.config
cd cynosure-2
lua scripts/build.lua
cd ..

printf "=> Assembling the Cynosure Loader\n"
cd cldr
lua scripts/preproc.lua src/main.lua cldr.lua
cd ..

printf "=> Copying in files\n"
cp cldr/cldr.lua build/init.lua
cp config/cldr.cfg build/boot/cldr.cfg
cp config/{inittab,fstab,os-release,passwd,group,profile} build/etc/
cp cynosure-2/kernel.lua build/boot/cynosure.lua
cp reknit/init.lua build/bin/
cp -r liblua/src/ build/lib/lua
mv build/lib/{lua/,}package.lua
cp coreutils/src/* build/bin/
# compatibility with scripts starting with #!/usr/bin/env
mv build/bin/env build/usr/bin/env
#cp -r luash/{bin,lib,etc} build/
cp vbls/src/vbls.lua build/bin/sh.lua
cp -r liblua/lang build/etc/
mkdir -p build/root

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

if [ "$1" = "cpio" ]; then
  cpio=$(command -v cpio)
  if ! [ "$cpio" ]; then
    printf "=> cpio utility not found - cannot continue\n"
    exit 1
  fi
  printf "=> Assembling release CPIO\n"
  cd build
  find . -type f | $cpio -o > ../ulos2.cpio
  cd ..
fi

if [ "$1" = "ocvm" ]; then
  ocvm ..
fi

printf "=> Done!\n"
