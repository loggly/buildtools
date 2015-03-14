#!/bin/bash
#
# This script takes a package name as an argument and adds it to
# to a designated local reprepro repository. Then the designated
# repository is synced to a repository in Amazon S3. Once the
# sync completes, the script finishes by listing the updated
# repo directory from the local copy of the repository.
#
# v1.2.2 push2repoBE.sh
# 2015-03-12 vkroz
#  - changed name back to push2repoBE.sh
#  - integrated into jenkins_build_release.sh script
#
# v1.2.1 push2repoBE.sh
# 2014-06-17 goldsby
#  - use getopts
#  - add -i flag: exit 0 if file already exists in repo
#
# v1.2 push2repoBE.sh
# 2014-03-13 joey
#  - added selective logging
#  - fixes jenkins user permissions
#  - backend staging/qa repo split
#  - added basic email notifications
#
# v1.1 - publish-frontend-staging.sh
# 2013-11-08 leslie
#  - publishing to new S3 repos
#  - frontend/backend split

status=''
# Set user to jenkins
if [ $(whoami) != "jenkins" ]; then
  #echo "Switching users to 'jenkins'"
  exec sudo -u jenkins $0 "$@"
fi

if [ -z "$GOT_LOCK" ]; then
  #echo "Grabbing lockfile..."
  exec flock -w 10 -x "/var/lib/jenkins/publish_debs/publish.lock" env GOT_LOCK=1 $0 "$@"
fi

# Set report Variables
PUSHDATE=`date +%Y%m%d-%H%M%S`
LOGDIR='/var/lib/jenkins/publish_debs/logs'

# Get options
while getopts "i" opt "$@"; do
    case $opt in
        i)
            IGNORE_DUPLICATE=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Set core variables based on designated repo
if [ "${@:$OPTIND+0:1}" = 'stagingBE' ]; then
    OPS='BACKEND'
    LOG="$LOGDIR/backend_staging_push-log.$PUSHDATE"
    REPONAME='loggly-backend-staging'
    REPOBASEDIR='/opt/loggly/repo/loggly-backend-staging'
    S3BUCKETNAME='loggly-repo-staging-backend'
    S3CFG='/var/lib/jenkins/publish_debs/.s3cfg-staging'
elif [ "${@:$OPTIND+0:1}" = 'qaBE' ]; then
    OPS='BACKEND'
    LOG="$LOGDIR/backend_qa_push-log.$PUSHDATE"
    REPONAME='loggly-backend-qa'
    REPOBASEDIR='/opt/loggly/repo/loggly-backend-qa'
    S3BUCKETNAME='loggly-repo-qa-backend'
    S3CFG='/var/lib/jenkins/publish_debs/.s3cfg-qa'
else
    echo "Usage: $0 <repo> <yourpackage.deb>"
    exit 1
fi

# Assign .deb to variable or exit
if [ -z "${@:$OPTIND+1:1}" ]; then
    echo "Usage: $0 <repo> <yourpackage.deb>"
    exit 1
else
    PKGFILE=${@:$OPTIND+1:1}
fi


# Generate log header
echo "$OPS PUSH REPORT - $PUSHDATE" >> $LOG
echo '#=====================================================' >> $LOG
echo "Local Repo: $REPONAME" >> $LOG
echo "S3 Repo: $S3BUCKETNAME" >> $LOG
echo ' ' >> $LOG
echo "Package: $PKGFILE" >> $LOG

# Set variables for the repo subdirectories
package_name="$(dpkg-deb --show --showformat='${Package}\n' "$PKGFILE")"
if echo "$package_name" | grep '/^lib' ; then
  subdir=lib$(echo "$package_name" | cut -b1)
else
  subdir=$(echo "$package_name" | cut -b1)
fi

# Add package to designated repo and sync local repo to appropriate S3 repo
dir="$REPOSUBDIR/pool/main/$subdir/$package_name"
target="${REPOBASEDIR}/${dir}/$(basename $PKGFILE)"
repotarget="${REPOBASEDIR}/${dir}/"
echo "Target Directory: $repotarget" >> $LOG
echo '#-----------------------------------------------------' >> $LOG
echo ' ' >> $LOG
if [ -f "$target" ]; then
  echo "A package with the same file name is already in this repository. Aborting copy."
  if [ -n "$IGNORE_DUPLICATE" ]; then
    exit 0
  else
    exit 1
  fi
else
  echo "Adding $PKGFILE to local repo: $REPONAME..." >> $LOG
  reprepro --keepunreferencedfiles -C main -Vb $REPOBASEDIR  includedeb $REPONAME $PKGFILE >> $LOG
  status=$?
  echo ' ' >>$LOG
  echo "Syncing local repo: $REPONAME to S3 repo: $S3BUCKETNAME..." >> $LOG
  s3cmd -c $S3CFG sync $REPOBASEDIR/ s3://$S3BUCKETNAME >> $LOG
  status=$?
  echo ' ' >> $LOG
fi

echo " status: $status"


if [ $status -eq 0 ]; then
   echo "$PKGFILE successfully pushed to $REPONAME" >> $LOG

   # Mail update notification and print confirmation to screen
   echo -e "$PKGFILE has been successfully pushed to $REPONAME\nPush Log: $LOG" | mail -s "$REPONAME repo has been  UPDATED!" infra@loggly.com,techops@loggly.com -aFrom:"Jenkins<jenkins@loggly.com>"
   echo "$PKGFILE has been successfully pushed to $REPONAME"
   echo "Push Log: $LOG"
else
   echo "$PKGFILE push to $REPONAME failed!!" >> $LOG

   # Mail update notification and print confirmation to screen
   echo -e "$PKGFILE push to $REPONAME has failed!! \nPush Log: $LOG" | mail -s "$REPONAME repo has been  UPDATED, and will require manual fix.!" infra@loggly.com,techops@loggly.com -aFrom:"Jenkins<jenkins@loggly.com>"
   echo "$PKGFILE push to $REPONAME has failed!!"
   echo "Push Log: $LOG"
fi

# Cat log file for rundeck's benefit
cat $LOG
