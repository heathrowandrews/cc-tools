#!/usr/bin/env bash
# install.sh — Install cc-tools to ~/.local/bin

set -euo pipefail

INSTALL_DIR="${1:-$HOME/.local/bin}"
SCRIPTS=(cc-grid cc-hub cc-hub-hook cc-snap cc-start)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  Installing cc-tools to $INSTALL_DIR"
echo ""

mkdir -p "$INSTALL_DIR"

for script in "${SCRIPTS[@]}"; do
    cp "$SCRIPT_DIR/$script" "$INSTALL_DIR/$script"
    chmod +x "$INSTALL_DIR/$script"
    echo "  -> $INSTALL_DIR/$script"
done

echo ""

# Check if install dir is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "  NOTE: $INSTALL_DIR is not in your PATH."
    echo "  Add this to your shell profile (~/.zshrc or ~/.bashrc):"
    echo ""
    echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
fi

echo "  Done! Run 'cc-start' to launch the command center."
echo ""
echo "  Don't forget to set up Claude Code hooks — see README.md"
echo ""
