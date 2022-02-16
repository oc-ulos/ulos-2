#!/bin/bash

git submodule foreach foreach git add .
git submodule foreach git commit

git add .
if [ "$#" -lt 0 ] ; then
  git commit
fi
