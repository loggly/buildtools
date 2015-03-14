#!/usr/bin/env bash
# Jenkins Chopper QA build script
# ------------------------------------------------------------------------------------------------
#
# Build environment variable
#   WORKSPACE:        chopper build location.
#                     Example: WORKSPACE=/var/lib/jenkins/jobs/Pipeline-sv4/ws/chopper
#   EC2_ID:           EC2 instance for running single node test. AWS and SV4 builds use separate instances for tests:
#                       AWS: i-f509fda5
#                       SV4: i-2f78bec2
# ------------------------------------------------------------------------------------------------

# Assuming that Jenkins sets initial work directory to $WORKSPACE

JOB_HOME=$WORKSPACE/../..

mvn -Dmaven.repo.local=$JOB_HOME/m2 clean install
cd test/jenkins
./single-node.sh --LOCAL_WS $JOB_HOME/ws --EC2_ID ${EC2_ID}
