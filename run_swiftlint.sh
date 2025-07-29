#!/bin/bash

# SwiftLint Runner Script for Fishbowl Project
# Run this script to check code quality and style consistency

set -e

echo "🔍 Running SwiftLint checks for Fishbowl project..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed. Please install it first:"
    echo "   brew install swiftlint"
    echo "   or download from: https://github.com/realm/SwiftLint/releases"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f ".swiftlint.yml" ]; then
    echo "❌ .swiftlint.yml not found. Make sure you're in the project root directory."
    exit 1
fi

echo "📋 SwiftLint version: $(swiftlint version)"

# Run SwiftLint with different modes
echo ""
echo "🔍 Running basic lint check..."
swiftlint lint --reporter xcode

echo ""
echo "🔧 Running autocorrect (safe fixes)..."
swiftlint autocorrect

echo ""
echo "📊 Generating lint report..."
swiftlint lint --reporter json > swiftlint_report.json
echo "   Report saved to: swiftlint_report.json"

echo ""
echo "📈 Summary:"
swiftlint lint --reporter summary

echo ""
echo "✅ SwiftLint analysis complete!"
echo ""
echo "📝 To integrate with Xcode:"
echo "   1. Select your project in Xcode"
echo "   2. Go to Build Phases"
echo "   3. Add a new 'Run Script Phase'"
echo "   4. Add this script: 'if which swiftlint >/dev/null; then swiftlint; fi'"
echo "" 