#!/bin/bash
target="../Gutenberg/processed_full_texts/"
pushd "$target"
cat *.txt > merged.txt
popd