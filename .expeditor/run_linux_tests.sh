#!/bin/bash
#
# This script runs a passed in command, but first setups up the bundler caching on the repo

set -ue

export USER="root"

echo "--- dependencies"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8
S3_URL="s3://public-cd-buildkite-cache/${BUILDKITE_PIPELINE_SLUG}/${BUILDKITE_LABEL}"

pull_s3_file() {
    aws s3 cp "${S3_URL}/$1" "$1" || echo "Could not pull $1 from S3"
}

push_s3_file() {
    if [ -f "$1" ]; then
        aws s3 cp "$1" "${S3_URL}/$1" || echo "Could not push $1 to S3 for caching."
    fi
}

apt-get update -y
apt-get install awscli -y

echo "--- bundle install"
pull_s3_file "bundle.tar.gz"
pull_s3_file "bundle.sha256"

if [ -f bundle.tar.gz ]; then
  tar -xzf bundle.tar.gz
fi

if [ -n "${RESET_BUNDLE_CACHE:-}" ]; then
    rm bundle.sha256
fi

bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "--- bundle cache"
if test -f bundle.sha256 && shasum --check bundle.sha256 --status; then
    echo "Bundled gems have not changed. Skipping upload to s3"
else
    echo "Bundled gems have changed. Uploading to s3"
    shasum -a 256 Gemfile.lock > bundle.sha256
    tar -czf bundle.tar.gz vendor/
    push_s3_file bundle.tar.gz
    push_s3_file bundle.sha256
fi

echo "+++ bundle exec task"
bundle exec $@
