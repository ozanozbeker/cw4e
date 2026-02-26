#!/bin/bash
set -euo pipefail

uv run marimo export html-wasm marimo/playground.py -o "$QUARTO_PROJECT_OUTPUT_DIR/playground" --mode run --force
