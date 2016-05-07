#!/bin/sh
set -e
log() { echo -e "\033[36m$@\033[39m"; }

# Special treatment for the "master" branch to deploy to /documentation instead
# of /master
target="${CI_BRANCH}"
if [ "${CI_BRANCH}" = "master" ]; then
	target="documentation"
fi

# Where do we want to generate the site at?
destination="/site/$target"
if [ "${destination}" != "/site/" ]; then
	rm -rf "${destination}" && mkdir -p "${destination}"
fi

# Jet release notes and current version
jet_source="/site/.jet"
if [ -f "_data/jet.yml" ]; then
	sed -i'' -e "s|^version:.*|version: $(cat ${jet_source}/version)|" "_data/jet.yml"
fi
if [ -f "_posts/docker/jet/2015-07-16-release-notes.md" ]; then
	cat "${jet_source}/release-notes" >> "_posts/docker/jet/2015-07-16-release-notes.md"
fi
rm -rf "${jet_source}"

# Compile the site
log "Building with base URL /${target}"
sed -i'' -e "s|^baseurl:.*|baseurl: /${target}|" _config.yml
bundle exec jekyll build --destination "${destination}" 2>&1| tee build.log

# Fail if the build log from Jekyll contains any Deprecations
! cat build.log | grep "Deprecation" -c
