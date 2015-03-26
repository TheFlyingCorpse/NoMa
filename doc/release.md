# Release Checklist

Update doc/CHANGELOG.txt with latest changes from https://www.netways.org/projects/noma/roadmap

Update `doc/AUTHORS` and `.mailmap` file

    git log --use-mailmap | grep ^Author: | cut -f2- -d' ' | sort | uniq > doc/AUTHORS

Update version

    vim configure.ac
    autoconf

Create tarball

    VERSION=2.1.0
    git archive --format=tar --prefix=noma-$VERSION/ tags/v$VERSION | gzip >noma-$VERSION.tar.gz
    md5sum noma-$VERSION.tar.gz > noma-$VERSION.tar.gz.md5

