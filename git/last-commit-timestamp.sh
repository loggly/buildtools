branch=$1

if [ -z "$branch" ] ; then
  echo "No branch specified?"
  exit 1
fi

git log --date=raw -n 1 $branch | awk '/Date:/ { print $2 + (60 * $3) }'
