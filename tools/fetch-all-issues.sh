#!/bin/bash
# fetch-all-issues.sh - Fetch all open GitHub issues from a repository
# Outputs: List of issues with number, title, body, labels, and metadata to a markdown file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/issues.md"
REPO=""
TOKEN=""
PER_PAGE=100
MAX_ISSUES=""

show_help() {
    cat << EOF
Usage: $(basename "$0") --repo <repo> [OPTIONS]

Fetch ALL open GitHub issues (including pagination) and save to markdown file.

REQUIRED:
    -r, --repo REPO      Repository in format "owner/name" (e.g., palcarazm/ia-stack)

OPTIONS:
    -h, --help           Show this help message
    -t, --token TOKEN    GitHub Personal Access Token (required for private repos, increases rate limit)
    -m, --max N          Maximum number of issues to fetch (default: all)
    --per-page N         Issues per page (default: 100, max: 100)

EXAMPLES:
    # Fetch all open issues from public repo
    $(basename "$0") --repo "palcarazm/ia-stack"

    # Fetch up to 50 issues from private repo with token
    $(basename "$0") --repo "my-company/private-repo" --token "ghp_xxxx" --max 50

ENVIRONMENT VARIABLES:
    GITHUB_TOKEN    Can be set instead of using --token
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -r|--repo)
            shift
            REPO="$1"
            shift
            ;;
        -t|--token)
            shift
            TOKEN="$1"
            shift
            ;;
        -m|--max)
            shift
            MAX_ISSUES="$1"
            shift
            ;;
        --per-page)
            shift
            PER_PAGE="$1"
            shift
            ;;
        *)
            echo "❌ Error: Unknown option: $1"
            show_help
            ;;
    esac
done

# Validate required arguments
if [ -z "$REPO" ]; then
    echo "❌ Error: --repo is required"
    show_help
fi

# Validate per-page (max 100)
if [ "$PER_PAGE" -gt 100 ]; then
    echo "⚠️  Warning: --per-page cannot exceed 100. Setting to 100."
    PER_PAGE=100
fi

# Use GITHUB_TOKEN from environment if --token not provided
if [ -z "$TOKEN" ] && [ -n "$GITHUB_TOKEN" ]; then
    TOKEN="$GITHUB_TOKEN"
fi

# Validate repo format
if [[ "$REPO" != *"/"* ]] || [[ "$REPO" == *"/"*"/"* ]]; then
    echo "❌ Error: Invalid repo format. Use 'owner/repo' (e.g., palcarazm/ia-stack)"
    exit 1
fi

# Build curl command with auth
API_URL="https://api.github.com/repos/$REPO/issues?state=open&per_page=$PER_PAGE&sort=created&direction=asc"
CURL_BASE="curl -s"
if [ -n "$TOKEN" ]; then
    CURL_BASE="$CURL_BASE -H \"Authorization: token $TOKEN\""
fi

echo "📡 Fetching open issues from $REPO..."

# Function to fetch a single page
fetch_page() {
    local page=$1
    local url="$API_URL&page=$page"
    eval "$CURL_BASE \"$url\""
}

# First, get total count (from first page headers or a single issue fetch)
echo "📊 Counting open issues..."

# Fetch first page to get pagination info
FIRST_PAGE_RESPONSE=$(fetch_page 1)

# Check for API errors
if echo "$FIRST_PAGE_RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$FIRST_PAGE_RESPONSE" | jq -r '.message')
    echo "❌ GitHub API Error: $ERROR_MSG"
    
    if echo "$ERROR_MSG" | grep -q "Not Found"; then
        echo "   Repository '$REPO' not found"
    elif echo "$ERROR_MSG" | grep -q "API rate limit"; then
        echo "   Rate limit exceeded. Add a token with --token or set GITHUB_TOKEN"
    fi
    exit 1
fi

# Check if response is an array
if ! echo "$FIRST_PAGE_RESPONSE" | jq -e 'type == "array"' > /dev/null 2>&1; then
    echo "❌ Error: Unexpected API response format"
    exit 1
fi

# Get total count by checking if we got fewer than PER_PAGE items
ISSUE_COUNT=$(echo "$FIRST_PAGE_RESPONSE" | jq 'length')
if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo "✅ No open issues found in $REPO"
    
    # Create empty output file
    OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")
    add_header "$OUTPUT_FILE" "GitHub Issues - $REPO (Open)"
    cat >> "$OUTPUT_FILE" << EOF

**No open issues found.**

EOF
    echo "✅ Empty issues file saved to: $OUTPUT_FILE"
    exit 0
fi

# Pagination logic
ALL_ISSUES="$FIRST_PAGE_RESPONSE"
PAGE=2
TOTAL_FETCHED=$ISSUE_COUNT

echo "   Page 1: $ISSUE_COUNT issues"

# Keep fetching while we got a full page AND haven't hit max
while [ "$ISSUE_COUNT" -eq "$PER_PAGE" ]; do
    # Check if we've hit max_issues
    if [ -n "$MAX_ISSUES" ] && [ "$TOTAL_FETCHED" -ge "$MAX_ISSUES" ]; then
        echo "   Reached max issues limit ($MAX_ISSUES)"
        break
    fi
    
    NEXT_PAGE=$(fetch_page $PAGE)
    ISSUE_COUNT=$(echo "$NEXT_PAGE" | jq 'length')
    
    if [ "$ISSUE_COUNT" -gt 0 ]; then
        ALL_ISSUES=$(echo "$ALL_ISSUES" "$NEXT_PAGE" | jq -s 'add')
        TOTAL_FETCHED=$((TOTAL_FETCHED + ISSUE_COUNT))
        echo "   Page $PAGE: $ISSUE_COUNT issues (total: $TOTAL_FETCHED)"
        PAGE=$((PAGE + 1))
    else
        break
    fi
done

# Apply max limit if specified
if [ -n "$MAX_ISSUES" ] && [ "$TOTAL_FETCHED" -gt "$MAX_ISSUES" ]; then
    echo "⚠️  Limiting to $MAX_ISSUES issues (fetched $TOTAL_FETCHED total)"
    ALL_ISSUES=$(echo "$ALL_ISSUES" | jq ".[0:$MAX_ISSUES]")
    TOTAL_FETCHED=$MAX_ISSUES
fi

echo ""
echo "✅ Fetched $TOTAL_FETCHED open issues"

# Initialize output file
OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")
add_header "$OUTPUT_FILE" "GitHub Issues - $REPO (Open)" "Repository: \`$REPO\`
Issue Type: Open Issues
Total Count: $TOTAL_FETCHED
Fetched Date: $(date '+%Y-%m-%d %H:%M:%S')"

# Counter for issues
ISSUE_NUM=1
ISSUE_COUNT_TYPE_ISSUES=0
ISSUE_COUNT_TYPE_PRS=0

# Iterate through issues and write each one
while read -r issue; do
    NUMBER=$(echo "$issue" | jq -r '.number')
    TITLE=$(echo "$issue" | jq -r '.title // "No title"')
    STATE=$(echo "$issue" | jq -r '.state // "unknown"')
    AUTHOR=$(echo "$issue" | jq -r '.user.login // "unknown"')
    CREATED_AT=$(echo "$issue" | jq -r '.created_at // ""' | cut -d'T' -f1)
    UPDATED_AT=$(echo "$issue" | jq -r '.updated_at // ""' | cut -d'T' -f1)
    HTML_URL=$(echo "$issue" | jq -r '.html_url // ""')
    BODY=$(echo "$issue" | jq -r '.body // ""')
    LABELS=$(echo "$issue" | jq -r '[.labels[].name] | join(", ")')
    
    # Determine issue type (pull request or regular issue)
    IS_PR=$(echo "$issue" | jq -r '.pull_request != null')
    if [ "$IS_PR" = "true" ]; then
        ISSUE_COUNT_TYPE_PRS=$((ISSUE_COUNT_TYPE_PRS + 1))
        ISSUE_TYPE="Pull Request"
        continue
    else
        ISSUE_COUNT_TYPE_ISSUES=$((ISSUE_COUNT_TYPE_ISSUES + 1))
        ISSUE_TYPE="Issue"
    fi
    
    # Write issue section
    cat >> "$OUTPUT_FILE" << EOF
## $ISSUE_TYPE #$NUMBER: $TITLE

| Field | Value |
|-------|-------|
| **Number** | #$NUMBER |
| **State** | $STATE |
| **Author** | @$AUTHOR |
| **Created** | $CREATED_AT |
| **Updated** | $UPDATED_AT |s
| **Labels** | ${LABELS:-_None_} |
| **URL** | [$HTML_URL]($HTML_URL) |

### Description

EOF
    
    # Write issue body
    if [ -z "$BODY" ] || [ "$BODY" = "null" ]; then
        echo "_No description provided._" >> "$OUTPUT_FILE"
    else
        echo "$BODY" | sed 's/^/> /' >> "$OUTPUT_FILE"
    fi
    
    # Add separator between issues (except last)
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    
    ISSUE_NUM=$((ISSUE_NUM + 1))
done < <(echo "$ALL_ISSUES" | jq -c '.[]')

echo ""
echo "✅ All issues saved to: $OUTPUT_FILE"
echo ""
echo "📊 Summary:"
echo "   Repo:           $REPO"
echo "   Fetched:        $TOTAL_FETCHED open issues & pull requests"
echo "   Issues:         $ISSUE_COUNT_TYPE_ISSUES open issues"
echo "   Pull Requests:  $ISSUE_COUNT_TYPE_PRS open pull requests"
echo "   Output:         $OUTPUT_FILE"