#!/bin/bash
# bundle.sh - Bundle all files from specified directories into a single markdown file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

# Default values
DEFAULT_DIRS="."
DIRECTORIES="$DEFAULT_DIRS"
OUTPUT_RELATIVE="../../outputs/bundle.md"

# Excluded patterns (uses find's -path matching)
EXCLUDED_PATTERNS=(
    ".git"
    "node_modules"
    "debug"
    "outputs"
    "out"
    "tmp"
    "*.tmp"
    "dist"
    "logs"
    "*.log"
    "coverage"
    ".husky"
    ".vscode"
)

build_find_excludes() {
    local excludes=""
    for pattern in "${EXCLUDED_PATTERNS[@]}"; do
        excludes="$excludes -not -path \"*/$pattern/*\" -not -path \"*/$pattern\""
    done
    echo "$excludes"
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Bundle all files from specified directories into a single markdown file.
Excludes: $(echo "${EXCLUDED_PATTERNS[*]}") by default.

OPTIONS:
    -h, --help              Show this help message
    -d, --dirs DIRECTORIES  Directories to process (space-separated)
                            Default: "$DEFAULT_DIRS"
    -e, --exclude PATTERN   Additional exclude pattern (can be used multiple times)

EXAMPLES:
    $(basename "$0") --dirs "./src ./docs"
    $(basename "$0") -d "./scripts"
    $(basename "$0") --exclude "*.md" --exclude "docs" # Also exclude markdown files and docs dir
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--dirs)
            shift
            DIRECTORIES="$1"
            shift
            ;;
        -e|--exclude)
            shift
            ADDITIONAL_EXCLUDES+=("$1")
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_help
            ;;
    esac
done

# Initialize output file
OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")
add_header "$OUTPUT_FILE" "Project Files Bundle"

echo "**Bundled directories:** \`${DIRECTORIES}"\` | tee -a "$OUTPUT_FILE"
echo "**Excluded patterns:** \`${EXCLUDED_PATTERNS[*]} ${ADDITIONAL_EXCLUDES[*]}"\` | tee -a "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Build find command with all excludes
for dir in $DIRECTORIES; do
    # Remove trailing slash if present
    dir="${dir%/}"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "⚠️  Warning: Directory '$dir' does not exist, skipping" | tee -a "$OUTPUT_FILE"
        continue
    fi
    
    echo "## Processing: \`$dir\`" | tee -a "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Build find command with excludes
    find_cmd="find \"$dir\" -type f"
    
    # Add default excludes
    for pattern in "${EXCLUDED_PATTERNS[@]}"; do
        find_cmd="$find_cmd -not -path \"*/$pattern/*\" -not -path \"*/$pattern\""
    done
    
    # Add additional excludes from command line
    for pattern in "${ADDITIONAL_EXCLUDES[@]}"; do
        find_cmd="$find_cmd -not -path \"*/$pattern/*\" -not -path \"*/$pattern\""
    done
    
    # Execute find and process files
    eval "$find_cmd" | while read -r file; do
        # Calculate relative path (remove leading "./" if present)
        relative_path="${file#./}"
        
        # Get file extension for syntax highlighting hint
        extension="${relative_path##*.}"
        case "$extension" in
            sh|bash|zsh) lang="bash" ;;
            js|ts) lang="javascript" ;;
            jsx|tsx) lang="jsx" ;;
            json) lang="json" ;;
            md) lang="markdown" ;;
            yml|yaml) lang="yaml" ;;
            css) lang="css" ;;
            html) lang="html" ;;
            py) lang="python" ;;
            *) lang="" ;;
        esac
        
        echo "- File \`$relative_path\`:" | tee -a "$OUTPUT_FILE"
        if [ -n "$lang" ]; then
            echo "\`\`\`$lang" >> "$OUTPUT_FILE"
        else
            echo '```' >> "$OUTPUT_FILE"
        fi
        cat "$file" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
done

echo "✅ File generated in: $OUTPUT_FILE"