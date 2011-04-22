#!/bin/sh

branch=$1
basedir=$(dirname $0)
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

remote=$(git config --get branch.$branch.remote)
url=$(git config --get remote.$remote.url)

echo $url | sed -re 's,.*/([^/]*)\..*$,\1,'
