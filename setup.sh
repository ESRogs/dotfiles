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

echo "Done!"
