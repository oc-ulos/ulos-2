#!/bin/bash
# Assemble a ULOS 2 release using UPT packages.

set -e

base=$(realpath $(dirname $(dirname $0)))
liblua=$base/liblua
runner=$(realpath $(dirname $0)/ulos-runner)
export OS=ulos2

uptcmd () {
  cmd=$1
  shift
  $runner $liblua $base/upt/src/bin/$cmd.lua -c "$@"
}

printf "=> Building packages\n"

printf "==> Cynosure 2 build configuration\n"
cd cynosure-2; scripts/genuptconf.lua; cd ..

packages=$(echo cldr config coreutils cynosure-2 liblua reknit upt vbls \
  installer)

for pkg in $packages; do
  printf "==> $pkg\n"
  cd $pkg
  uptcmd uptb #>/dev/null
  cd ..
done

printf "=> Installing packages to fakeroot\n"
rm -rf build; mkdir -p build

for pkg in $packages; do
  uptcmd upti $pkg/*.mtar --rootfs $PWD/build/
done

mkdir -p build/etc/upt/cache
cp config/*.mtar build/etc/upt/cache/ulos2-config.mtar

# still gotta do this manually
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

# make `passwd` setuid
cat > build/bin/.passwd.lua.attr << EOF
mode:35309
created:$(date +"%s")
EOF
