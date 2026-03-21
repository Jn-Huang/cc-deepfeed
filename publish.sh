#!/bin/bash
# Publish feeds/ to gh-pages branch for GitHub Pages serving.
# Called after each research cycle.
# Usage: bash publish.sh [base-url]
#   If base-url is provided, also generates index.html and OPML.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
FEEDS_DIR="$PROJECT_DIR/feeds"

if [ ! -d "$FEEDS_DIR" ] || [ -z "$(ls -A "$FEEDS_DIR"/*.xml 2>/dev/null)" ]; then
    echo "No feed XML files found in feeds/. Nothing to publish."
    exit 0
fi

# Generate index.html and OPML if base URL is provided
BASE_URL="${1:-}"
if [ -n "$BASE_URL" ]; then
    python "$PROJECT_DIR/feed.py" index-html --base-url "$BASE_URL"
    python "$PROJECT_DIR/feed.py" opml --base-url "$BASE_URL"
fi

# Create a temporary directory for the gh-pages content
TMPDIR=$(mktemp -d)
cp "$FEEDS_DIR"/*.xml "$TMPDIR/"
[ -f "$FEEDS_DIR/index.html" ] && cp "$FEEDS_DIR/index.html" "$TMPDIR/"
[ -f "$FEEDS_DIR/index.opml" ] && cp "$FEEDS_DIR/index.opml" "$TMPDIR/"

# Switch to gh-pages branch, update, switch back
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git stash --include-untracked -q 2>/dev/null || true

# Create gh-pages branch if it doesn't exist
if ! git rev-parse --verify gh-pages >/dev/null 2>&1; then
    git checkout --orphan gh-pages
    git rm -rf . >/dev/null 2>&1 || true
else
    git checkout gh-pages
fi

# Copy feeds and commit
cp "$TMPDIR"/* .
git add *.xml 2>/dev/null || true
git add index.html index.opml 2>/dev/null || true
if git diff --cached --quiet; then
    echo "No changes to publish."
else
    git commit -m "Update feeds $(date +%Y-%m-%d)"
fi

git push origin gh-pages
echo "Published feeds to gh-pages."

# Return to original branch
git checkout "$CURRENT_BRANCH"
git stash pop -q 2>/dev/null || true
rm -rf "$TMPDIR"

# Ping WebSub hub so feed readers (Feedly etc.) fetch updates immediately
curl -s -o /dev/null -X POST "https://pubsubhubbub.appspot.com/" \
    -d "hub.mode=publish&hub.url=https://xingjianz.com/rss-research/daily-briefings.xml" || true
echo "Pinged WebSub hub."
