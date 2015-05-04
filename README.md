# !!! THIS IS DEPRECATED PROJECT !!!
We should revisit it and catch with current state of arts:
- all builds are managed by Jenkins server at infrabuild host
- continues deployment is documented here: https://loggly.jira.com/wiki/display/Engineering/Builds%2C+Continuous+Integration+and+Deployment

---------------


# Destination: Package

We have crap in git.

We deploy packages.

Git -> Packages? <https://github.com/jordansissel/fpm>

# What?

If you run 'package.sh' from a git repo, it will create a debian package of
that repo.

Additionally, if you have a Makefile or build.xml in the root of your repo,
those will be run with the 'artifact' target, like:

    % make artifact

    # or
    
    % ant artifact

These are optional and are only executed if the files necessary exist.

The output will be a .deb versioned <timestamp>.<branch>. 'timestamp' is the
last-commit timestamp on the upstream (remote) repo. Branch is your current branch

The name of the package is based on the name of the git repository.

# Example:

    % sh git/package.sh           
    git fetch...
    Putting pristine copy of origin/master in build
    Building deb package for loggly-buildtools=1303475359.master
    ["rsync", "-a", ".", "/home/jls/projects/buildtools/build-deb-loggly-buildtools_1303475359.master_amd64.deb/tarbuild/opt/loggly/buildtools/."]
    opt
    Created /home/jls/projects/buildtools/loggly-buildtools_1303475359.master_amd64.deb

    
Now inspect the package:

    % dpkg -c loggly-buildtools_1303475359.master_amd64.deb
    drwxr-xr-x root/root         0 2011-04-22 17:21 ./
    drwxr-xr-x root/root         0 2011-04-22 17:21 ./opt/
    drwxr-xr-x root/root         0 2011-04-22 17:21 ./opt/loggly/
    drwxr-xr-x root/root         0 2011-04-22 17:13 ./opt/loggly/buildtools/
    -rw-r--r-- root/root         0 2011-04-22 17:13 ./opt/loggly/buildtools/README
    drwxr-xr-x root/root         0 2011-04-22 17:13 ./opt/loggly/buildtools/git/
    -rw-r--r-- root/root       167 2011-04-22 17:13 ./opt/loggly/buildtools/git/last-commit-timestamp.sh
    -rw-r--r-- root/root       241 2011-04-22 17:13 ./opt/loggly/buildtools/git/name.sh
    ... etc ...

