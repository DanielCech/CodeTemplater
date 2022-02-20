#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/codeTemplater Bin
cp -rf .build/x86_64-apple-macosx/debug/codeTemplater /usr/local/bin
