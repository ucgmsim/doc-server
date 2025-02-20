#!/bin/sh

DOCS_DIR="/docs"
REPOS_DIR="/repos"
mkdir -p "$DOCS_DIR" "$REPOS_DIR"

echo "Updating repositories from repos.txt..."
while read -r line; do
    [ -z "$line" ] && continue  # Skip empty lines

    repo_name=$(echo "$line" | cut -d'@' -f1 | xargs)  # Extract repo name (trim spaces)
    repo_ref=$(echo "$line" | cut -d'@' -f2 | xargs)  # Extract ref (trim spaces)

    repo_path="$REPOS_DIR/$repo_name"

    if [ -d "$repo_path/.git" ]; then
        echo "Updating $repo_name..."
        git -C "$repo_path" fetch --quiet
        git -C "$repo_path" checkout "$repo_ref" --quiet
        git -C "$repo_path" pull --quiet
    else
        echo "Cloning $repo_name..."
        git clone --quiet "https://github.com/ucgmsim/$repo_name.git" "$repo_path"
        git -C "$repo_path" checkout "$repo_ref" --quiet
    fi

done < /repos.txt

echo "Generating documentation with pydoctor..."
rm -rf "$DOCS_DIR/*"
cd "$REPOS_DIR"
for repo in "$REPOS_DIR"/*; do
    [ -d "$repo" ] || continue  # Skip if not a directory
    repo_name=$(basename "$repo")
    echo "$repo/$repo_name"
done | xargs pydoctor --project-name "QuakeCoRE" --html-output="$DOCS_DIR" --docformat=numpy --project-version="$(date +%Y-%m-%dT%H:%M)" --intersphinx=https://docs.python.org/3/objects.inv
