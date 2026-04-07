#!/bin/bash
# log.sh - Unified interface for git log scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    cat << EOF
Usage: $(basename "$0") <COMMAND> [OPTIONS]

Unified interface for git log scripts.

COMMANDS:
    complete    Full commit log of current branch (HEAD)
    branch      Compare current branch with a base branch
    tag         Show commits from last tag to HEAD

GENERAL OPTIONS:
    -h, --help  Show this help message

EXAMPLES:
    $(basename "$0") complete
    $(basename "$0") branch main
    $(basename "$0") tag
EOF
    exit 0
}

# Show help if no arguments or help requested
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

COMMAND="$1"
shift

case "$COMMAND" in
    complete)
        exec "$SCRIPT_DIR/log-complete.sh" "$@"
        ;;
    branch)
        exec "$SCRIPT_DIR/log-branch.sh" "$@"
        ;;
    tag)
        exec "$SCRIPT_DIR/log-tag.sh" "$@"
        ;;
    *)
        echo "Error: Unknown command: $COMMAND"
        echo ""
        show_help
        ;;
esac