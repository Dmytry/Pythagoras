#!/bin/bash
self=$(dirname -- "$0")
out="$self/../../generated"
mkdir -p "$out"
"$self/../../scripts/export_all.py" --output "$out" --jobs 24 "$self/corners.scad" "$self/stickbot_balanced.scad"