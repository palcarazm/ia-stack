#!/bin/bash
# diff.sh - Capture git diff --staged output to a markdown file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/diff.md"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Capture git diff --staged (staged changes) to a markdown file.

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
add_header "$OUTPUT_FILE" "Git Diff - Staged Changes"

echo '```bash' >> "$OUTPUT_FILE"
git diff --staged >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"

echo "✅ File generated in: $OUTPUT_FILE"