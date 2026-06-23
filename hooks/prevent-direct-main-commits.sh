# [[file:../../config/nix.org::*Block Direct Main Commits][Block Direct Main Commits:1]]
BRANCH=$(git branch --show-current)
GIT_DIR=$(git rev-parse --git-dir)
if [ "$BRANCH" = "main" ] && [ ! -f "$GIT_DIR/MERGE_HEAD" ]; then
    echo "Direct commits to 'main' are blocked."
    echo "Please commit to a feature branch and merge it into main."
    exit 1
fi
# Block Direct Main Commits:1 ends here
