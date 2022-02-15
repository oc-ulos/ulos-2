#!/bin/bash

pull () {
  cd $1
  git pull
  cd ..
}

git pull
pull cynosure-2
pull cle-toolchain
