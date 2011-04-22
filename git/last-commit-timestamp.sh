branch=$1

basedir=$(dirname $0)
[ -z "$branch" ] && branch=$(sh $basedir/current-branch.sh)

git log --date=raw -n 1 $branch | awk '/Date:/ { print $2 + (60 * $3) }'
