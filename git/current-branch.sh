#!/bin/sh

branch="$(git branch | egrep '^\*' | cut -b '3-')"

# Jenkins' Git plugin uses detached heads with no branch, but it
# also sets GIT_BRANCH in environment.
if [ "$branch" = "(no branch)" ] ; then
  branch=$GIT_BRANCH
fi

if [ "$branch" = "" ] ; then
  branch="unknown-branch"
fi

echo "$branch"
