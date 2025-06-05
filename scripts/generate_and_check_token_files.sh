#!/bin/bash

# Exit on error
set -e

echo "=== Starting token generation and validation process ==="

echo "Step 1: Generating token files..."
dart lib/src/theme/design_tokens/design_token_parser.dart

echo "Step 2: Auto-fixing common issues..."
echo "Fixing core_design_tokens.dart..."
dart fix --apply lib/src/theme/design_tokens/core_design_tokens.dart
echo "Fixing light_theme_design_tokens.dart..."
dart fix --apply lib/src/theme/design_tokens/light_theme_design_tokens.dart
echo "Fixing dark_theme_design_tokens.dart..."
dart fix --apply lib/src/theme/design_tokens/dark_theme_design_tokens.dart
echo "Fixing component_design_tokens.dart..."
dart fix --apply lib/src/theme/design_tokens/component_design_tokens.dart

echo "Step 3: Formatting generated files..."
dart format --set-exit-if-changed .

echo "Step 4: Analyzing generated files for remaining issues..."
ANALYZE_OUTPUT=$(dart analyze lib/src/theme/design_tokens/core_design_tokens.dart lib/src/theme/design_tokens/light_theme_design_tokens.dart lib/src/theme/design_tokens/dark_theme_design_tokens.dart lib/src/theme/design_tokens/component_design_tokens.dart)
echo "$ANALYZE_OUTPUT"

echo "Step 5: Running token parser tests..."
flutter test test/theme/design_token_parser_test.dart

echo "=== Token generation and validation process completed ==="

# Only print these if there were issues found
if [[ ! "$ANALYZE_OUTPUT" =~ "No issues found!" ]]; then
  echo ""
  echo "Next steps:"
  echo "1. If any issues were found during analysis, you have two options:"
  echo "   a. For style issues that can be auto-fixed, the script has already applied fixes."
  echo "   b. For other issues, fix them in the generator code (lib/src/theme/design_tokens/design_token_parser.dart)."
  echo "2. Run this script again to regenerate the files with your fixes."
  echo ""
  echo "This workflow ensures that your generated files are always properly formatted and"
  echo "free of issues, while keeping the fixes in the generator where they belong."
fi
