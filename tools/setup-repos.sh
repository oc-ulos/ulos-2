#!/bin/bash

git submodule foreach "git switch dev || git switch main; true"
