#!/bin/bash

# Read the current version from the GitHub repository secret
CURRENT_VERSION=$(echo ${{ secrets.DOCKER_IMAGE_VERSION }})
echo "Current version: $CURRENT_VERSION"

if [ -z "$CURRENT_VERSION" ]; then
  # No version found, default to 0.0.0
  CURRENT_VERSION="0.0.0"
fi

# Determine the type of version increment based on commit messages or other criteria
# In this example, we check if there are any breaking changes, new features, or bug fixes
BREAKING_CHANGES=$(git log --format=%B -n 1 | grep -i -e 'MAJOR' -e 'BREAKING' -e 'BREAKS' -e 'BREAK' -e 'BREAKS' -e 'BREAKING CHANGE' -e 'BREAKING CHANGES')
NEW_FEATURES=$(git log --format=%B -n 1 | grep -i -e 'MINOR' -e 'FEATURE' -e 'FEATURES' -e 'FEAT' -e 'FEATS' -e 'ADD' -e 'ADDS' -e 'ADDED' -e 'CREATE' -e 'CREATES' -e 'CREATED' -e 'MAKE' -e 'MAKES' -e 'MADE')
BUG_FIXES=$(git log --format=%B -n 1 | grep -i -e 'PATCH' -e 'FIX ' -e 'FIXES ' -e 'FIXED ' -e 'CLOSE ' -e 'CLOSES ' -e 'CLOSED ' -e 'RESOLVE ' -e 'RESOLVES ' -e 'RESOLVED ' -e 'SOLVE ' -e 'SOLVES ' -e 'SOLVED ' -e 'ISSUE ' -e 'ISSUES ' -e 'ISSUED ')
# Determine the version increment based on the detected changes
if [ -n "$BREAKING_CHANGES" ]; then
  # Increment MAJOR for breaking changes
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1+1 ".0.0"}')
elif [ -n "$NEW_FEATURES" ]; then
  # Increment MINOR for new features
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1 "." $2+1 ".0"}')
elif [ -n "$BUG_FIXES" ]; then
  # Increment PATCH for bug fixes
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1 "." $2 "." $3+1}')
else
  # No specific changes detected, default to incrementing PATCH
  NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1+1 "." $2 "." $3}')
fi

# Set the new version to the GitHub repository secret $DOCKER_IMAGE_VERSION
echo "DOCKER_IMAGE_VERSION=$NEW_VERSION" >> $GITHUB_ENV