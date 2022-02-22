#!/bin/bash

git submodule foreach "git add .; true"
git submodule foreach "git commit; true"

git add .
if [ "$#" -lt 0 ] ; then
  git commit
fi
