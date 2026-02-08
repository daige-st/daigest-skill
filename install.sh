#!/bin/bash
set -e

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/.claude/skills/daigest"

mkdir -p "$(dirname "$TARGET_DIR")"
ln -sfn "$SKILL_DIR" "$TARGET_DIR"

echo "Installed daigest skill → $TARGET_DIR"
