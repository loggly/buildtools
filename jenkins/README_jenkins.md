This package contains tools we use for builds on Jenkins

Conventions on Jenkins:
-------------
- Locations on Jenkins:
    - Tools:            /home/loggly/buildtools
    - Local DEB repos:  /opt/loggly/repo
    - Repo names are:
        * loggly-backend-staging  - Ops staging
        * loggly-backend-qa       - QA repo


- S3 credentials:
    * staging REPO
    > S3BUCKETNAME='loggly-repo-staging-backend'
    > S3CFG='/var/lib/jenkins/publish_debs/.s3cfg-staging'

    * QA REPO:
    > S3BUCKETNAME='loggly-repo-qa-backend'
    > S3CFG='/var/lib/jenkins/publish_debs/.s3cfg-qa'

    * S3 bucket:
    > S3BUCKETNAME='loggly-repo-qa-backend'
    > S3CFG='/var/lib/jenkins/publish_debs/.s3cfg-qa'

S3 tools
-------------
On Jenkins it is s3cmd
