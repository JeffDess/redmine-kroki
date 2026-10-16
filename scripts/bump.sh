#!/usr/bin/env bash

if ! which convco &>/dev/null; then
  echo 'ERROR: You need to install convco to run this script (nix develop)'
  exit 1
fi

if [ "$(git branch --show-current)" != 'main' ]; then
  echo 'ERROR: Version must be bumped from the main branch'
  exit 1
fi

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo 'ERROR: Commit or stash your changes before bumping the version'
  exit 1
fi

CURRENT=$(convco version)

if ! convco check "v$CURRENT..HEAD"; then
  echo "ERROR: Fix commit messages since v$CURRENT before bumping"
  exit 1
fi

VERSION=$(convco version --bump "$@") || exit 1

if [ "$VERSION" = "$CURRENT" ]; then
  echo "ERROR: No commits since v$CURRENT warrant a new version"
  exit 1
fi

INIT=src/init.rb
sed -i "s/^  version '.*'$/  version '$VERSION'/" "$INIT"

if ! grep -q "^  version '$VERSION'$" "$INIT"; then
  echo "ERROR: Could not update the version in $INIT"
  git checkout -- "$INIT"
  exit 1
fi

git commit -q -m "chore: bump v$VERSION" -- "$INIT" || exit 1
git tag "v$VERSION" || exit 1

echo "Bumped v$CURRENT -> v$VERSION"
echo "Publish with: git push origin main v$VERSION"
