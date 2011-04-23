#!/bin/sh
# Opinionated builds from git.

# Expected usage:
# package.sh <dir_or_file> ...

set -e
branch=$1
basedir=$(dirname $0)
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

name="$(sh $basedir/name.sh)"
branch=$(sh $basedir/current-branch.sh)
upstream=$(sh $basedir/upstream.sh)
revision="$(sh $basedir/last-commit-timestamp.sh $upstream)"

dir=build
sh $basedir/pristine-checkout.sh $branch $dir
if [ $# -eq 0 ] ; then
  # Package up the entire directory by default
  set -- . 
fi

prefix="/opt/loggly/$name"

[ -f $dir/Makefile ] && make -C $dir artifact
[ -f $dir/build.xml ] && (cd $dir; ant artifact)

pkgname=loggly-$name
pkgversion=$revision.$branch
echo "Building deb package for $pkgname=$pkgversion"
fpm -s dir -t deb --prefix $prefix -n $pkgname -v $pkgversion -C $dir "$@"
