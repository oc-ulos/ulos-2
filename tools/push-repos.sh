#!/bin/bash

push () {
  cd $1
  git add .
  git commit
  git push
  cd ..
}

git submodule foreach "git add .; true"
git submodule foreach "git commit; true"
git submodule foreach "git push; true"

git add .
git commit
git push
