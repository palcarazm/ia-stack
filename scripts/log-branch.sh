#!/bin/bash
# log-branch.sh - Compare current branch with a base branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/log-branch.md"
BASE_BRANCH=""

show_help() {
    cat << EOF
Usage: $(basename "$0") <base_branch> [OPTIONS]

Compare current branch with a base branch and show commits that differ.

ARGUMENTS:
    base_branch         The branch to compare against (required)

OPTIONS:
    -h, --help          Show this help message

EXAMPLES:
    $(basename "$0") main
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        *)
            if [ -z "$BASE_BRANCH" ]; then
                BASE_BRANCH="$1"
                shift
            else
                echo "Error: Unknown option: $1"
                show_help
            fi
            ;;
    esac
done

# Validate base branch is provided
if [ -z "$BASE_BRANCH" ]; then
    echo "Error: No base branch specified"
    echo ""
    show_help
fi

OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Unable to determine current branch (are you in a git repo?)" | tee -a "$OUTPUT_FILE"
    exit 1
fi

# Validate base branch exists
if ! git show-ref --verify --quiet refs/heads/"$BASE_BRANCH"; then
    echo "Error: Base branch '$BASE_BRANCH' does not exist" | tee -a "$OUTPUT_FILE"
    exit 1
fi

# Validate branches are different
if [ "$BASE_BRANCH" = "$CURRENT_BRANCH" ]; then
    echo "Error: Base branch and current branch are the same ('$CURRENT_BRANCH')" | tee -a "$OUTPUT_FILE"
    exit 1
fi

add_header "$OUTPUT_FILE" "Git Branch Comparison"
add_separator "$OUTPUT_FILE" "Comparison Info"

echo "- **Base branch:** \`$BASE_BRANCH\`" >> "$OUTPUT_FILE"
echo "- **Current branch:** \`$CURRENT_BRANCH\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

add_separator "$OUTPUT_FILE" "Commits in $CURRENT_BRANCH (not in $BASE_BRANCH)"

COMMITS=$(git log "$BASE_BRANCH..$CURRENT_BRANCH" --pretty=format:"%h | %ad | %an | %B---%n" --date=short 2>/dev/null)

if [ -z "$COMMITS" ]; then
    echo "No different commits found between branches" >> "$OUTPUT_FILE"
else
    echo '```bash' >> "$OUTPUT_FILE"
    echo "$COMMITS" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

COMMIT_COUNT=$(git rev-list --count "$BASE_BRANCH..$CURRENT_BRANCH" 2>/dev/null || echo "0")
echo "**Commits count:** $COMMIT_COUNT" | tee -a "$OUTPUT_FILE"

echo "✅ File generated in: $OUTPUT_FILE"