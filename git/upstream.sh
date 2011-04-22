#!/bin/sh

branch=$1
if [ -z "$branch" ] ; then
  echo "No branch given?"
  exit 1
fi

remote=$(git config --get branch.$branch.remote)

if [ -z "$remote" ] ; then
  echo "No remote for branch: $branch"
  exit 2
fi

upstream=$(git config --get branch.$branch.merge)

echo $remote/$(basename $upstream)

