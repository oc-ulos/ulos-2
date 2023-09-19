#!/bin/bash

git submodule foreach "git switch dev; true"
git switch dev
