#!/bin/bash
# output_helper.sh - Helper functions for output file management

# Get the directory of the caller of the function that called this helper
# This is useful for output file management when the output file path needs to be relative to the caller's location
get_caller_dir() {
    local source="${BASH_SOURCE[1]}"
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    echo "$(cd -P "$(dirname "$source")" && pwd)"
}

# Initialize an output file with a path relative to the caller
# Usage: init_output_file "relative/path/to/file.md"
init_output_file() {
    local relative_path="$1"
    local caller_dir="$(get_caller_dir)"
    local full_path="$caller_dir/$relative_path"
    local dir_path="$(dirname "$full_path")"
    
    mkdir -p "$dir_path"
    > "$full_path"
    echo "$full_path"
}

# Add a common header to output files
# Usage: add_header "$OUTPUT_FILE" "Report Title"
add_header() {
    local output_file="$1"
    local title="$2"
    
    echo "# $title" >> "$output_file"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
    echo "" >> "$output_file"
}

# Append a section separator
# Usage: add_separator "$OUTPUT_FILE" "Section Name"
add_separator() {
    local output_file="$1"
    local section_name="$2"
    
    echo "" >> "$output_file"
    echo "## $section_name" >> "$output_file"
    echo "-----------------------------------------" >> "$output_file"
    echo "" >> "$output_file"
}