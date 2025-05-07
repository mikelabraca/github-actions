#!/bin/bash

set -e

# Get the PR number and repo
PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
REPO=$(jq --raw-output .repository.full_name "$GITHUB_EVENT_PATH")

# Get the list of files changed in the PR
PR_FILES=$(gh pr view $PR_NUMBER --json files -q ".files[].filename")

# If CODEOWNERS file exists, read it
if [ -f "$CODEOWNERS_PATH" ]; then
  while IFS= read -r line; do
    # Skip empty lines or comments
    if [[ -z "$line" || "$line" == \#* ]]; then
      continue
    fi

    # Split the line into pattern and owners
    pattern=$(echo "$line" | awk '{print $1}')
    owners=$(echo "$line" | sed 's/^[^ ]* //')

    echo "Start checking changes..."
    echo "   Files=$PR_FILES"

    # Check if any PR file matches the pattern
    for file in $PR_FILES; do
      echo "Checking owner of file: $file"
      if [[ "$file" =~ $pattern ]]; then
        # Add the labels for the matching pattern
        for owner in $owners; do
          echo "Adding owner=$owner for file: $file"
          gh pr label $PR_NUMBER --add "$owner" --repo "$REPO" --token "$GITHUB_TOKEN"
        done
      fi
    done
  done < "$CODEOWNERS_PATH"
else
  echo "No CODEOWNERS file found at path: [$CODEOWNERS_PATH]"
  exit 1
fi