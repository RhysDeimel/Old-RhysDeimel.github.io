#!/bin/sh

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
  # git status
  # git checkout -b src
  git add content
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add origin https://${GH_TOKEN}@github.com/RhysDeimel/RhysDeimel.github.io.git > /dev/null 2>&1
  # git push --quiet --set-upstream origin-pages gh-pages 
  # git push
  echo "would push here"
  git push origin HEAD:src
}

setup_git
commit_website_files
upload_files