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
cp -n config/kconfig cynosure-2/.config || true

packages=$(echo cldr config coreutils cynosure-2 liblua reknit upt vbls \
  installer)

for pkg in $packages; do
  printf "==> $pkg\n"
  cd $pkg
  rm -f *.mtar
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

if [ "$1" = "mtar" ]; then
  printf "=> Generating self-extracting release image\n"
  mkdir build/{dev,proc,tmp,install}
  touch build/{dev,proc,tmp,install}/.keepme
  # slightly hacky way of starting the installer
  echo "clr:1:wait:/bin/clear.lua" >> build/etc/inittab
  echo "ins:1:wait:/bin/install.lua" >> build/etc/inittab
  find build -type f | tools/mtar.lua build > release.mtar
  cat tools/mtarldr.lua release.mtar tools/mtarldr_2.lua > \
    $OS-$(date +%y.%m).lua
  rm release.mtar
fi

# mark file permissions for the ocvm release
printf "=> Marking file permissions\n"
for f in $(find build/*); do
  if [ "${f:1:1}" != "." ]; then
    base=$(basename $f)
    dir=$(dirname $f)
    cat > $dir/.$base.attr << EOF
mode:33188
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

# make `passwd` and `sudo` setuid
cat > build/bin/.passwd.lua.attr << EOF
mode:35309
created:$(date +"%s")
EOF

cat > build/bin/.sudo.lua.attr << EOF
mode:35309
created:$(date +"%s")
EOF

if [ "$1" = "ocvm" ]; then
  printf "=> Launching OCVM"
  ocvm ..
fi

printf "=> Done!\n"
