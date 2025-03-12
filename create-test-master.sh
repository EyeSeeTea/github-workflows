#!/bin/bash

# Get the current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

SOURCE_FILE=".github/workflows/master.yml"
TARGET_FILE=".github/workflows/test-master.yml"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ Error: $SOURCE_FILE not found!"
    exit 1
fi

cp "$SOURCE_FILE" "$TARGET_FILE"

# replace @master with @branch
sed -i "s#@master#@$BRANCH#g" "$TARGET_FILE"

if ! git diff --quiet "$TARGET_FILE"; then
    git add "$TARGET_FILE"
    echo "✅ Updated test-master.yml with branch: $BRANCH"
else
    echo "⚠️ No changes detected in test-master.yml"
fi
