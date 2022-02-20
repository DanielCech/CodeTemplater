#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/codetemplater Bin
cp -rf .build/x86_64-apple-macosx/debug/codetemplater /usr/local/bin
tar -czf Bin/codetemplater.tar.gz Bin/codetemplater
shasum -a 256 Bin/codetemplater.tar.gz