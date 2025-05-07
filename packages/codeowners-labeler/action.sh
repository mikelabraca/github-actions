#!/bin/bash

set -e

# env vars
# GITHUB_TOKEN
echo "CODEOWNERS_PATH=$CODEOWNERS_PATH"

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

    # Check if any PR file matches the pattern
    for file in $PR_FILES; do
      if [[ "$file" =~ $pattern ]]; then
        # Add the labels for the matching pattern
        for owner in $owners; do
          gh pr label $PR_NUMBER --add "$owner" --repo "$REPO" --token "$GITHUB_TOKEN"
        done
      fi
    done
  done < "$CODEOWNERS_PATH"
else
  echo "No CODEOWNERS file found in the repository."
  exit 1
fi