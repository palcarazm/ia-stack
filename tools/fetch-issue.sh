#!/bin/bash
# fetch-issue.sh - Fetch GitHub issue details using curl + jq
# Outputs: issue number, title, and body to a markdown file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output_helper.sh"

OUTPUT_RELATIVE="../../outputs/issue.md"
REPO=""
ISSUE_NUMBER=""
TOKEN=""

show_help() {
    cat << EOF
Usage: $(basename "$0") --repo <repo> --issue <number> [OPTIONS]

Fetch GitHub issue details (number, title, body) and save to markdown file.

REQUIRED:
    -r, --repo REPO      Repository in format "owner/name" (e.g., palcarazm/ia-stack)
    -i, --issue NUMBER   Issue number to fetch

OPTIONS:
    -h, --help           Show this help message
    -t, --token TOKEN    GitHub Personal Access Token (required for private repos)
                         If not provided, only public repos are accessible

EXAMPLES:
    # Fetch from public repo
    $(basename "$0") --repo "palcarzm/ia-stack" --issue 1

    # Fetch from private repo with token
    $(basename "$0") --repo "my-company/private-repo" --issue 42 --token "ghp_xxxx"

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
        -i|--issue)
            shift
            ISSUE_NUMBER="$1"
            shift
            ;;
        -t|--token)
            shift
            TOKEN="$1"
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_help
            ;;
    esac
done

# Validate required arguments
if [ -z "$REPO" ]; then
    echo "❌ Error: --repo is required"
    show_help
fi

if [ -z "$ISSUE_NUMBER" ]; then
    echo "❌ Error: --issue is required"
    show_help
fi

# Use GITHUB_TOKEN from environment if --token not provided
if [ -z "$TOKEN" ] && [ -n "$GITHUB_TOKEN" ]; then
    TOKEN="$GITHUB_TOKEN"
fi

# Validate repo format (should contain exactly one '/')
if [[ "$REPO" != *"/"* ]] || [[ "$REPO" == *"/"*"/"* ]]; then
    echo "❌ Error: Invalid repo format. Use 'owner/repo' (e.g., palcarzm/ia-stack)"
    exit 1
fi

# Build curl command
API_URL="https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER"
CURL_CMD="curl -s"

if [ -n "$TOKEN" ]; then
    CURL_CMD="$CURL_CMD -H \"Authorization: token $TOKEN\""
fi

# Fetch issue data
echo "📡 Fetching issue #$ISSUE_NUMBER from $REPO..."

RESPONSE=$(eval "$CURL_CMD \"$API_URL\"")

# Check for API errors
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    echo "❌ GitHub API Error: $ERROR_MSG"
    
    if echo "$ERROR_MSG" | grep -q "Not Found"; then
        echo "   Issue #$ISSUE_NUMBER not found in $REPO"
    elif echo "$ERROR_MSG" | grep -q "API rate limit"; then
        echo "   Rate limit exceeded. Add a token with --token or set GITHUB_TOKEN"
    fi
    exit 1
fi

# Extract fields
TITLE=$(echo "$RESPONSE" | jq -r '.title // "No title"')
BODY=$(echo "$RESPONSE" | jq -r '.body // ""')
STATE=$(echo "$RESPONSE" | jq -r '.state // "unknown"')
AUTHOR=$(echo "$RESPONSE" | jq -r '.user.login // "unknown"')
CREATED_AT=$(echo "$RESPONSE" | jq -r '.created_at // ""' | cut -d'T' -f1)
HTML_URL=$(echo "$RESPONSE" | jq -r '.html_url // ""')

# Check if issue exists (if title is null, issue doesn't exist)
if [ "$TITLE" = "null" ] || [ -z "$TITLE" ]; then
    echo "❌ Error: Issue #$ISSUE_NUMBER does not exist in $REPO"
    exit 1
fi

# Initialize output file
OUTPUT_FILE=$(init_output_file "$OUTPUT_RELATIVE")
add_header "$OUTPUT_FILE" "GitHub Issue #$ISSUE_NUMBER"

# Write issue metadata
cat >> "$OUTPUT_FILE" << EOF

| Field | Value |
|-------|-------|
| **Repository** | \`$REPO\` |
| **Issue #** | $ISSUE_NUMBER |
| **Title** | $TITLE |
| **State** | $STATE |
| **Author** | @$AUTHOR |
| **Created** | $CREATED_AT |
| **URL** | [$HTML_URL]($HTML_URL) |

---

## Description

EOF

# Write issue body (handle empty body)
if [ -z "$BODY" ] || [ "$BODY" = "null" ]; then
    echo "_No description provided._" >> "$OUTPUT_FILE"
else
    echo "$BODY" >> "$OUTPUT_FILE"
fi

echo "✅ Issue saved to: $OUTPUT_FILE"
echo ""
echo "📋 Summary:"
echo "   Repo:    $REPO"
echo "   Issue:   #$ISSUE_NUMBER"
echo "   Title:   $TITLE"
echo "   State:   $STATE"
echo "   Author:  @$AUTHOR"
