#!/bin/sh

git branch | egrep '^\*' | cut -b '3-'
