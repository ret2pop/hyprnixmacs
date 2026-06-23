# [[file:../../config/nix.org::*Label Commit][Label Commit:1]]
set -e

if [ "$INTERNAL_GIT_ACTION" = "1" ]; then
    exit 0
fi
export INTERNAL_GIT_ACTION=1

GIT_CMD="git -c core.hooksPath=/dev/null"

PARENTS=$(git log -1 --format=%P)
if [ $(echo "$PARENTS" | wc -w) -gt 1 ]; then
    exit 0
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
LABEL_DIR="$REPO_ROOT/data"
LABEL_FILE="$LABEL_DIR/boot-label.txt"
mkdir -p "$LABEL_DIR"

apply_label() {
    local MSG="$1"
    if [ ! -f "$LABEL_FILE" ] || [ "$(cat "$LABEL_FILE")" != "$MSG" ]; then
        printf "%s" "$MSG" > "$LABEL_FILE"
        $GIT_CMD add "$LABEL_FILE"
    fi
}

ORIGINAL_MSG=$(git log -1 --pretty=%B)

FILE_COUNT=$(git diff-tree --no-commit-id --name-only -r HEAD | grep -v "^data/boot-label\.txt$" | wc -l)

if git diff-tree --no-commit-id --name-only -r HEAD | grep -q "^flake\.lock$"; then
    HAS_FLAKE_LOCK=1
else
    HAS_FLAKE_LOCK=0
fi

if [ "$HAS_FLAKE_LOCK" = "1" ] && [ "$FILE_COUNT" -gt 1 ] && git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    $GIT_CMD reset --soft HEAD~1
    
    $GIT_CMD restore --staged flake.lock
    
    apply_label "$ORIGINAL_MSG"
    $GIT_CMD commit -m "$ORIGINAL_MSG" --no-verify
    
    $GIT_CMD add flake.lock
    apply_label "bump flake lock"
    $GIT_CMD commit -m "bump flake lock" --no-verify
else
    TARGET_MSG="$ORIGINAL_MSG"
    
    if [ "$HAS_FLAKE_LOCK" = "1" ]; then
        TARGET_MSG="bump flake lock"
    fi
    
    apply_label "$TARGET_MSG"
    $GIT_CMD commit --amend -m "$TARGET_MSG" --no-verify
fi
# Label Commit:1 ends here
