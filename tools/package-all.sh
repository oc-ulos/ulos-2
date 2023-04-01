#!/bin/bash
# package everything

git submodule foreach $PWD/tools/package.sh
tools/package.sh
