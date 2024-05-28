#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux run "$CURRENT_DIR/scripts/instrument-bind-key.sh"
