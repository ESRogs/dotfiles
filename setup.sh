#!/bin/bash
# Setup script for dotfiles
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Symlink gitconfig
if [ -L ~/.gitconfig ]; then
    echo "~/.gitconfig is already a symlink, skipping"
elif [ -f ~/.gitconfig ]; then
    echo "~/.gitconfig exists as a file. Back it up and remove it first."
    exit 1
else
    ln -s "$DOTFILES_DIR/gitconfig" ~/.gitconfig
    echo "Linked gitconfig"
fi

# Symlink aliases
if [ -L ~/.aliases ]; then
    echo "~/.aliases is already a symlink, skipping"
elif [ -f ~/.aliases ]; then
    echo "~/.aliases exists as a file. Back it up and remove it first."
    exit 1
else
    ln -s "$DOTFILES_DIR/aliases" ~/.aliases
    echo "Linked aliases"
fi

# Add source line to shell rc if not present
for rc in ~/.bashrc ~/.zshrc; do
    if [ -f "$rc" ]; then
        if ! grep -q "source ~/.aliases" "$rc"; then
            echo "" >> "$rc"
            echo "# Load custom aliases" >> "$rc"
            echo "[ -f ~/.aliases ] && source ~/.aliases" >> "$rc"
            echo "Added source line to $rc"
        fi
    fi
done

echo "Done!"
