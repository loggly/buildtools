#!/bin/sh
branch=$1
destination=$2

basedir=$(dirname $0)

if [ -z "$branch" -o -z "$destination" ] ; then
  echo "Usage: $0 <branch> <destination>"
  exit 1
fi

echo "git fetch..."
git fetch

# XXX git archive --prefix vs tar -C, which one is better?

echo "Putting pristine copy of $(sh $basedir/upstream.sh $branch) in $destination"
git archive --format=tar --prefix=$destination/ $branch | tar -xf -
