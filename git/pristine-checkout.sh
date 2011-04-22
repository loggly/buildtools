#!/bin/sh
branch=$1
destination=$2

git fetch
# XXX git archive --prefix vs tar -C, which one is better?
git archive --format=tar --prefix=$destination/ $branch | tar -xf -
