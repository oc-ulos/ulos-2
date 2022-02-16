#!/bin/bash

push () {
  cd $1
  git add .
  git commit
  git push
  cd ..
}

git submodule foreach git add .
git submodule foreach git commit
git submodule foreach git push

git add .
git commit
git push
