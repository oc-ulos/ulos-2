#!/bin/bash

commit () {
  cd $1
  git add .
  git commit
  cd ..
}

commit cynosure-2
commit cle-toolchain

git add .
if [ "$#" -lt 0 ] ; then
  git commit
fi
