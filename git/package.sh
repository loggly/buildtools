#!/bin/sh

# Expected usage:
# package.sh <dir_or_file> ...

branch=$1
basedir=$(dirname $0)
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

name="loggly-$(sh $basedir/name.sh)"
revision="$(sh $basedir/last-commit-timestamp.sh")
branch=$(sh $basedir/current-branch.sh)
upstream=$(sh $basedir/upstream.sh)

dir=build
sh $basedir/pristine-checkout.sh $upstream $dir
if [ $# -eq 0 ] ; then
  # Package up the entire directory by default
  set -- . 
fi

fpm -s dir -t deb -n $name -v $revision.$branch -C $dir "$@"
