#!/bin/bash

INPUT_DIR="./doc/diagrams"

# Check if mmdc is installed
if ! command -v mmdc &> /dev/null; then
echo "Error: Mermaid CLI (mmdc) is not installed."
echo "Use command npm install -g @mermaid-js/mermaid-cli to install it."
exit 1
fi

# Loop through all .mmd files in the folder
for file in "$INPUT_DIR"/*.mmd; do
  [ -e "$file" ] || continue # Skip if no .mmd files
  base_name=$(basename "$file" .mmd)
  output_file="$INPUT_DIR/$base_name.svg"
  echo "Generating SVG for $file -> $output_file"
  mmdc -i "$file" -o "$output_file"
done
