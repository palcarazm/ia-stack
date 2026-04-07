#!/bin/bash
# log-complete.sh - Generate complete commit log of current branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/log.md"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Generate a complete commit log of the current branch (HEAD).

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
add_header "$OUTPUT_FILE" "Complete Git Log"

echo '```bash' >> "$OUTPUT_FILE"
git log HEAD --pretty=format:"%h | %ad | %an | %B---%n" --date=short >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "**Total commits:** $COMMIT_COUNT" | tee -a "$OUTPUT_FILE"

echo "✅ File generated in: $OUTPUT_FILE"