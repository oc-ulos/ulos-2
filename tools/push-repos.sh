#!/bin/bash

push () {
  cd $1
  git add .
  git commit
  git push
  cd ..
}

push cynosure-2
push cle-toolchain

git add .
git commit
git push
