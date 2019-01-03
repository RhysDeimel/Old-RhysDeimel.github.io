#!/bin/sh

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

echo "Adding any changes in content"
git add content
git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"

echo "Pushing any changes in content"
git push -u https://RhysDeimel:$GITHUB_TOKEN@github.com/RhysDeimel/RhysDeimel.github.io.git/ HEAD:src
