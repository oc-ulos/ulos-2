#!/bin/bash
# merge 'dev' to 'release' branch

set -e

ref=$(git rev-parse HEAD)
git checkout release
git merge $ref --no-ff --no-commit
