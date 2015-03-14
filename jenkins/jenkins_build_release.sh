#!/usr/bin/env bash
# Jenkins Chopper release build script
# ------------------------------------------------------------------------------------------------
# Format conventions:
#   DEB package name: loggly-{component}_{git commit timestamp}.{git commit id}.{git branch}_all.deb
#            Example: loggly-alerter_1426135750.2ee1550.master_all.deb
#
#   S3 package path:  s3://loggly-release-packages/infra-{version}/{platform}/
#           Example:  s3://loggly-release-packages/infra-sprint31/aws/
#           Example:  s3://loggly-release-packages/infra-sprint31/sv4/
#
# Build environment variable
#   WORKSPACE:        chopper build location.
#                     Example: WORKSPACE=/var/lib/jenkins/jobs/Pipeline-master-sv4/ws/chopper
#   PLATFORM:         SV4 or AWS
#   SPRINT_NUMBER:    Sprint number (Jenkins build job parameter)
#                     Example: SPRINT_NUMBER=32
#
# ------------------------------------------------------------------------------------------------

#########################
# Assuming that Jenkins sets initial work directory to $WORKSPACE
#########################

#########################
# Common defs.
#########################
usage() {
  echo "Usage: $0 <option>"
  echo "Options:"
  echo "  -h                         Print help info"
  echo "  --build                    Trigger Maven build"
  echo "  --publish-repo <REPO_ID>   Publish DEBs to repo, REPO_ID:(qaBE|stagingBE)"
  echo "  --publish-s3               Publish DEBs to S3 bucket"
}


build() {
    # Build, but skip tests since we already ran them in the staging job.
    rm -rf $JOB_HOME/ws/chopper/build/target
    cd $JOB_HOME/ws/chopper
    mvn -Dmaven.repo.local=$JOB_HOME/m2 -Dmaven.test.skip=true clean install
}

publish_repo() {
    # Build final deb packages.
    cd $JOB_HOME/ws/chopper/build
    ./package_all.sh $PACKAGE_NAME

    # Publish to DEB repo
    cd $JOB_HOME/ws/chopper/build/target
    debs=`ls *.deb`
    for d in $debs
    do
         /home/loggly/push2repoBE.sh -i $REPO_BACKEND $d
    done
}

publish_s3() {
    # Copies DEB packages to respective S3 bucket
    /home/loggly/push2s3bucket.sh $PLATFORM
}


#########################
# Execute script.
#########################
DO_BUILD=0
PUBLISH_REPO=0
PUBLISH_S3=0

while [ -n "$1" ]; do
  case "$1" in
    -h)
      usage; exit 0;;
    --build)
      shift; DO_BUILD=1;;
    --publish-repo)
      shift; PUBLISH_REPO=1; REPO_BACKEND=$1; shift;;
    --publish-s3)
      shift; PUBLISH_S3=1;;
    *)
      usage; exit 1;;
  esac
done


echo "DO_BUILD=$DO_BUILD"
echo "PUBLISH_REPO=$PUBLISH_REPO"
echo "PUBLISH_S3=$PUBLISH_S3"
echo "REPO_BACKEND=$REPO_BACKEND"


JOB_HOME=$WORKSPACE/../..

timestamp=`git log --date=raw -n 1 --pretty=fuller | awk '/CommitDate:/ { print $2 + (60 * substr($1, 1, 3)) }'`
commit=`git log --pretty=format:'%h' --abbrev-commit -1`
PACKAGE_NAME=master
export DEB_VERSION_TEMP=$timestamp.$commit.$PACKAGE_NAME
# this is to inject env variables for post build step for rundeck
echo DEB_VERSION=$(echo $DEB_VERSION_TEMP) > propsfile


if [ "$DO_BUILD" -ne "0" ]; then
    build
else
    echo "Skipping DEB repo publishing"
fi


if [ "$PUBLISH_REPO" -ne "0" ]; then
    publish_repo
else
    echo "Skipping DEB repo publishing"
fi


if [ "$PUBLISH_S3" -ne "0" ]; then
    publish_s3
else
    echo "Skipping S3 publishing"
fi
