#!/bin/bash

git submodule foreach "git add .; true"
git submodule foreach "git commit $@; true"

git add .
git commit "$@"

git submodule foreach "(git push; true) &"
echo $(jobs -p)
while ! [ -z $(jobs -p) ]; do wait; done
#git push
