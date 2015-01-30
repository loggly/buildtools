#!/bin/sh
branch=$1

basedir=$(dirname $0)
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

git log --date=raw -n 1 --pretty=fuller $branch | awk '/CommitDate:/ { print $2 + (60 * substr($1, 1, 3)) }'
