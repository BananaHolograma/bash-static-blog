#!/usr/bin/env bash

GREP_COMMAND='grep' # GNU Linux grep command by default

function is_macOs() {
    [[ "$OSTYPE" == 'darwin'* ]]
}

if is_macOs; then
    GREP_COMMAND='ggrep'
    if ! command -v "$GREP_COMMAND" >/dev/null 2>&1; then
        echo -e "GNU grep is required. Install it with 'brew install grep'" >&2
        exit 1
    fi
fi

CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
MARKDOWN_FILES=$(find "$CURRENT_DIR/content" -type f -iname '*.md' -print | xargs -0)

function generate_html_from_markdown() {
    local markdown_path=$1
    local base_dir=$(echo "$markdown_path" | sed 's|/content/.*||')
    local templates_path="$base_dir/content/templates"

    local html_path=$(echo "$markdown_path" | sed 's|.*/content/||' | sed 's/\.md$/.html/')
    local output_path="$base_dir/src/blog/$html_path"

    mkdir -p "$(dirname "$output_path")"
    pandoc --read=markdown --table-of-contents --toc-depth=2 --preserve-tabs --standalone --template="$templates_path"/article.html --listings "$markdown_path" --highlight-style=espresso -o "$output_path"

    echo -e "Generated article from $markdown_path"
}

function generate_html_articles() {
    local markdown_files=$1

    while IFS= read -r  markdown_file; do
        generate_html_from_markdown "$markdown_file"
    done <<< "$markdown_files"
}

function generate_blog_index() {
    local articles=$1
    local index_html_file="$CURRENT_DIR/src/index.html"
 
    # Delete content inside this two comments

    # Insert the updated article list
    local html=''
    while IFS= read -r  file; do
        if [ -f "$file" ]; then 
            title=$(extract_frontmatter_property "$file" "title")
            date=$(extract_frontmatter_property "$file" "date")
            year=$(echo "$date" | $GREP_COMMAND -o '[0-9]\{4\}')
            path=$(echo "/blog/$year/$(basename "$file")" | sed 's/\.md$/.html/')

            html+="<li><a href=\"$path\">$title</a><span class=\"date\">$date</span></li>\n"
        fi 
    done <<< "$articles"

    ed "$index_html_file"<<EOF
    /^\s*<!--\s*START\s*-->\s*$
    +,/^\s*<!--\s*END\s*-->\s*$/-1d
    -r !sed -n '/^\s*<!--\s*START\s*-->\s*$/,/^\s*<!--\s*END\s*-->\s*$/p' $html|grep -v '^#'
    w
    q
EOF

}

function extract_frontmatter_property() {
    local markdown_file=$1
    local property=$2
    
    if [ -f "$markdown_file" ]; then 
        frontmatter=$(awk '/^---*$/{p=!p;next}p' "$markdown_file")
        echo "$frontmatter" | $GREP_COMMAND -E "^${property}: (.*)" | sed 's/^[^:]*:\s*//'
    else 
        echo ''
    fi 
}

#generate_html_articles "$MARKDOWN_FILES"
generate_blog_index "$MARKDOWN_FILES"