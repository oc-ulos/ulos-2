#!/bin/bash

branch=${1:-dev}
git submodule foreach "git switch $branch; true"
git switch dev
