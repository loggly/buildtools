#!/bin/sh

basedir=$(dirname $0)
branch=$1

[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

remote=$(git config --get branch.$branch.remote)

if [ -z "$remote" ] ; then
  echo "No remote for branch: $branch"
  exit 2
fi

upstream=$(git config --get branch.$branch.merge)

echo $remote/$(basename $upstream)

