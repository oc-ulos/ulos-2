#!/bin/bash
# Assemble a ULOS 2 release using UPT packages.

set -e

base=$(realpath $(dirname $(dirname $0)))
liblua=$base/liblua
runner=$(realpath $(dirname $0)/ulos-runner)

uptcmd () {
  $runner $liblua $base/upt/src/bin/$1.lua -c "$@"
}

printf "=> Building packages\n"

packages=$(echo cldr config coreutils cynosure-2 liblua reknit upt vbls)

for pkg in $packages; do
  printf "==> $pkg\n"
  cd $pkg
  uptcmd uptb >/dev/null
  cd ..
done

printf "=> Installing packages to fakeroot\n"
rm -rf build; mkdir -p build

for pkg in $packages; do
  uptcmd upti $pkg/*.mtar --rootfs $PWD/build/
done

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
