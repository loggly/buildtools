#!/bin/bash
# Copies DEB packages to respective S3 bucket
# Format conventions:
#   Version# format: sprint{XX}
#   Build# format: {version}-{platform}
#   Examples:
#       sprint31-aws
#       sprint31-sv4
#
#   S3 path convention: s3://loggly-release-packages/infra-{version}/{platform}/
#   Examples
#       s3://loggly-release-packages/infra-sprint31/aws/
#       s3://loggly-release-packages/infra-sprint31/sv4/
#
# Build environment variable
#   WORKSPACE           - chopper build location.
#                       Ex: WORKSPACE=/var/lib/jenkins/jobs/Pipeline-master-sv4/ws/chopper
#   SPRINT_NUMBER       - Sprint number (Jenkins build job parameter)
#                       Ex: SPRINT_NUMBER=32
#


status=''
# Set user to jenkins
if [ $(whoami) != "jenkins" ]; then
  #echo "Switching users to 'jenkins'"
  exec sudo -u jenkins $0 "$@"
fi

PUSHDATE=`date +%Y%m%d-%H%M%S`
LOGDIR='/var/lib/jenkins/publish_debs/logs'
LOG="$LOGDIR/backend_copy_debs_to_s3-log.$PUSHDATE"
PLATFORM=sv4
DEBS_DIR="${WORKSPACE}/build/target"
S3_PATH="s3://loggly-release-packages/infra-sprint${SPRINT_NUMBER}/${PLATFORM}/"
S3_CFG="/var/lib/jenkins/publish_debs/.s3cfg-s3debsbucket"


# Generate log header
echo "DEBS-to-S3 COPY REPORT - $PUSHDATE" >> $LOG
echo '#=====================================================' >> $LOG
echo "Release#:     $SPRINT_NUMBER" >> $LOG
echo "Local path:   $DEBS_DIR" >> $LOG
echo "S3 Repo:      $S3_PATH" >> $LOG
echo ' ' >> $LOG
echo "Syncing local DEBs to $S3_PATH..." >> $LOG
s3cmd -c $S3_CFG sync $DEBS_DIR/ $S3_PATH >> $LOG
status=$?
echo ' ' >> $LOG

echo "status: $status"
exit $status

