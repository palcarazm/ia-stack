#!/bin/bash
# log-tag.sh - Compare commits from last tag to HEAD

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/log-tag.md"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Show commits from the last git tag to HEAD.

OPTIONS:
    -h, --help          Show this help message

EXAMPLE:
    $(basename "$0")
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
            echo "Error: Unknown option: $1"
            show_help
            ;;
    esac
done

OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")

# Get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
    echo "Error: No previous tag found" | tee -a "$OUTPUT_FILE"
    echo "Please create a tag before running this script." >> "$OUTPUT_FILE"
    exit 1
fi

add_header "$OUTPUT_FILE" "Git Tag Comparison"
add_separator "$OUTPUT_FILE" "Comparison Info"

echo "- **Last tag:** \`$LAST_TAG\`" >> "$OUTPUT_FILE"
echo "- **Target:** \`HEAD\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

add_separator "$OUTPUT_FILE" "Commits from $LAST_TAG to HEAD"

echo '```bash' >> "$OUTPUT_FILE"
git log "$LAST_TAG..HEAD" --pretty=format:"%h | %ad | %an | %B---%n" --date=short >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

COMMIT_COUNT=$(git rev-list --count "$LAST_TAG..HEAD" 2>/dev/null || echo "0")
echo "**Commits count:** $COMMIT_COUNT" | tee -a "$OUTPUT_FILE"

echo "✅ File generated in: $OUTPUT_FILE"