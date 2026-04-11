#!/bin/bash
# validate.sh - Run project validation (lint, build, test, etc.)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/validate.md"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run project validation and generate a markdown report file.

OPTIONS:
    -h, --help          Show this help message

EXAMPLE:
    $(basename "$0")
EOF
    exit 0
}

# Markdown package section formatter
# usage: format_package_section "engines" >> "$OUTPUT_FILE"
format_package_section() {
    local section="$1"
    
    sed -n '/"'$section'": {/,/^  }/p' package.json | \
        grep -E '^\s+"[^"]+":' | \
        grep -v '"'$section'":' | \
        sed 's/^\s*"//' | \
        sed 's/",*$//' | \
        sed 's/": /: /' | \
        sed 's/^/- /' | \
        sed 's/,\s*$//' | \
        sed 's/"/`/g'
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
add_header "$OUTPUT_FILE" "Project Validation Report"

# ============================================
# System Information
# ============================================
echo "## System Information" | tee -a "$OUTPUT_FILE"
format_package_section "engines" | tee -a "$OUTPUT_FILE"
echo "- TypeScript: \`$(npm list typescript --depth=0 2>/dev/null | grep typescript | sed 's/.*@//')\`" | tee -a "$OUTPUT_FILE"
echo "- Jest: \`$(npm list jest --depth=0 2>/dev/null | grep jest | sed 's/.*@//')\`" | tee -a "$OUTPUT_FILE"
echo "- Cypress: \`$(npm list cypress --depth=0 2>/dev/null | grep cypress | sed 's/.*@//')\`" | tee -a "$OUTPUT_FILE"
echo "- ESLint: \`$(npm list eslint --depth=0 2>/dev/null | grep eslint | sed 's/.*@//')\`" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Available npm scripts
# ============================================
echo "## Available npm scripts" | tee -a "$OUTPUT_FILE"
format_package_section "scripts" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Project structure
# ============================================
echo "## Project structure" | tee -a "$OUTPUT_FILE"
echo '```bash' >> "$OUTPUT_FILE"
git ls-tree -r --name-only HEAD | tree --fromfile | tee -a "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Clean Install
# ============================================
echo "## Clean Install" | tee -a "$OUTPUT_FILE"
echo '```bash' >> "$OUTPUT_FILE"
npm ci --include=optional --include=peer | tee -a "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Type Check (tsc --noEmit)
# ============================================
echo "## Type Check (tsc --noEmit)" | tee -a "$OUTPUT_FILE"
if npm list typescript --depth=0 &> /dev/null; then
    TYPE_CHECK_OUTPUT=$(npx tsc --noEmit 2>&1)
    if [ -z "$TYPE_CHECK_OUTPUT" ]; then
        echo "✅ No type errors detected" | tee -a "$OUTPUT_FILE"
    else
        echo '```bash' >> "$OUTPUT_FILE"
        echo "$TYPE_CHECK_OUTPUT" | tee -a "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    fi
else
    echo "TypeScript not available" | tee -a "$OUTPUT_FILE"
fi
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Linter warnings
# ============================================
echo "## Linter results (including warnings)" | tee -a "$OUTPUT_FILE"
LINT_OUTPUT=$(npm run lint -- --max-warnings=100 2>&1)
if echo "$LINT_OUTPUT" | grep -q "✖"; then
    echo '```bash' >> "$OUTPUT_FILE"
    echo "$LINT_OUTPUT" | tee -a "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
else
    echo "✅ No linting errors or warnings" | tee -a "$OUTPUT_FILE"
fi
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Build recording times
# ============================================
echo "## Build recording times" | tee -a "$OUTPUT_FILE"
START=$(date +%s%3N)
echo '```bash' >> "$OUTPUT_FILE"
npm run build 2>&1 | tee -a "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
BUILD_EXIT_CODE=$?
END=$(date +%s%3N)
DURATION=$((END - START))
echo "Build exit code: $BUILD_EXIT_CODE" | tee -a "$OUTPUT_FILE"
echo "Build duration: ${DURATION}ms" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Tests recording times
# ============================================
echo "## Tests recording times" | tee -a "$OUTPUT_FILE"
START=$(date +%s%3N)
echo '```bash' >> "$OUTPUT_FILE"
npm run test 2>&1 | tee -a "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
TEST_EXIT_CODE=$?
END=$(date +%s%3N)
DURATION=$((END - START))
echo "Test exit code: $TEST_EXIT_CODE" | tee -a "$OUTPUT_FILE"
echo "Test duration: ${DURATION}ms" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Dependency conflicts
# ============================================
echo "## Dependency conflicts (if any)" | tee -a "$OUTPUT_FILE"
CONFLICTS=$(npm ls --depth=0 2>&1 | grep -E "(UNMET|invalid|deduped)" || true)
if [ -z "$CONFLICTS" ]; then
    echo "✅ No dependency conflicts detected" | tee -a "$OUTPUT_FILE"
else
    echo '```bash' >> "$OUTPUT_FILE"
    echo "$CONFLICTS" | tee -a "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
fi
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Generated build artifacts
# ============================================
echo "## Generated build artifacts" | tee -a "$OUTPUT_FILE"
echo '```bash' >> "$OUTPUT_FILE"
tree js css dist | tee -a "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# ============================================
# Final
# ============================================
echo "File generated in: $OUTPUT_FILE"