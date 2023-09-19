#!/bin/bash

git submodule foreach "git add $1 .; true"
git submodule foreach "git commit; true"

git add $1 .
git commit
