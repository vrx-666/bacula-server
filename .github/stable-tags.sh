#!/usr/bin/env bash
# Stable version, build number and tag list for one DB variant.
# Shared by stable.yml (build) and promote.yml (retag a tested RC), so both
# publish exactly the same tags. Needs full git history (fetch-depth: 0).
#
#   .github/stable-tags.sh <postgresql|sqlite3>   -> version/build/tags into $GITHUB_OUTPUT
set -euo pipefail
DB=$1

# VERSION holds <bacula_version>.<build_seed>, e.g. 15.20
SEED=$(tr -d '[:space:]' < VERSION)
VER=${SEED%.*}                                       # 15
BUILD_START=${SEED##*.}                              # 20
BASE_COMMIT=$(git log -1 --format=%H -- VERSION)     # last commit that touched VERSION
COMMITS=$(git rev-list --count "${BASE_COMMIT}..HEAD")
BUILD=$((BUILD_START + COMMITS))                     # bX, resets when VERSION is bumped
echo "version=$VER" >> "$GITHUB_OUTPUT"
echo "build=$BUILD" >> "$GITHUB_OUTPUT"
echo "Bacula version: $VER, build number: b$BUILD"

DH=pwa666/bacula-server
GH=ghcr.io/vrx-666/bacula-server
if [ "$DB" = "postgresql" ]; then
  LIST="$DH:${VER}-postgresql-latest $DH:${VER}-postgresql $DH:${VER}-postgresql-b${BUILD} $GH:${VER}-postgresql $GH:${VER}-postgresql-b${BUILD}"
else
  # sqlite3 is the default variant -> it also gets the generic :<VER>-latest tag
  LIST="$DH:${VER}-sqlite3 $DH:${VER}-sqlite3-latest $DH:${VER}-sqlite3-b${BUILD} $DH:${VER}-latest $GH:${VER}-sqlite3 $GH:${VER}-sqlite3-b${BUILD}"
fi
{
  echo "tags<<EOF"
  for t in $LIST; do echo "$t"; done
  echo "EOF"
} >> "$GITHUB_OUTPUT"
