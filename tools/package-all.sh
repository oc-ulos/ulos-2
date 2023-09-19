#!/bin/bash
# package everything

git submodule foreach $PWD/tools/package.sh
tools/package.sh

tools/push-repos.sh

echo Run tools/setup-repos.sh to switch back to dev.
