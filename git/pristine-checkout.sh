#!/bin/sh

set -e
basedir=$(dirname $0)

branch=$1
destination=$2
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)
[ -z "$destination" ] && destination="build"

echo "git fetch..."
git fetch

# XXX git archive --prefix vs tar -C, which one is better?

echo "Putting pristine copy of $(sh $basedir/upstream.sh $branch) in $destination"
git archive --format=tar --prefix=$destination/ $branch | tar -xf -
