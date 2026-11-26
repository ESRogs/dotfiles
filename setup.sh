#!/bin/bash
# Setup script for dotfiles
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Include this repo's gitconfig from ~/.gitconfig, which keeps settings
# that belong to one person or machine, such as user.name and user.email
if git config --global --get-all include.path | grep -qxF "$DOTFILES_DIR/gitconfig"; then
    echo "~/.gitconfig already includes $DOTFILES_DIR/gitconfig, skipping"
else
    git config --global --add include.path "$DOTFILES_DIR/gitconfig"
    echo "Added an include of $DOTFILES_DIR/gitconfig to ~/.gitconfig"
fi

# Ask for the git identity if ~/.gitconfig doesn't have one yet
for key in user.name user.email; do
    if [ -z "$(git config --global "$key")" ]; then
        value=""
        while [ -z "$value" ]; do
            read -r -p "Git $key: " value || { echo "No input. Set it with: git config --global $key <value>"; exit 1; }
        done
        git config --global "$key" "$value"
    fi
done

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
echo ""
echo "Run 'source ~/.aliases' or restart your shell to load aliases."
