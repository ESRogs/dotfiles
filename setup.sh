#!/bin/bash
# Setup script for dotfiles
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# ~/.gitconfig must be a regular file, so that git config --global writes to
# this machine's settings. Replace a link to this repo's gitconfig, or a broken
# link, and stop at a link to any other file.
if [ -L ~/.gitconfig ]; then
    if [ ~/.gitconfig -ef "$DOTFILES_DIR/gitconfig" ] || [ ! -e ~/.gitconfig ]; then
        rm ~/.gitconfig
        touch ~/.gitconfig
        echo "Replaced the ~/.gitconfig link with a regular file"
    else
        echo "~/.gitconfig is a link to $(readlink ~/.gitconfig). Replace it with a regular file, then run setup.sh again."
        exit 1
    fi
fi

# Include this repo's gitconfig at the top of ~/.gitconfig. The rest of
# ~/.gitconfig keeps settings that belong to one person or machine, such as
# user.name and user.email, and overrides this repo's settings.
if git config --global --get-all include.path | grep -qxF "$DOTFILES_DIR/gitconfig"; then
    echo "~/.gitconfig already includes $DOTFILES_DIR/gitconfig, skipping"
else
    # Quote the path for git, so that characters such as # stay part of it
    quoted_path="${DOTFILES_DIR//\\/\\\\}"
    quoted_path="${quoted_path//\"/\\\"}"
    new_gitconfig="$(mktemp)"
    printf '[include]\n\tpath = "%s"\n' "$quoted_path/gitconfig" > "$new_gitconfig"
    if [ -e ~/.gitconfig ]; then
        cat ~/.gitconfig >> "$new_gitconfig"
    fi
    cat "$new_gitconfig" > ~/.gitconfig
    rm "$new_gitconfig"
    echo "Added an include of $DOTFILES_DIR/gitconfig to the top of ~/.gitconfig"
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

# Append a line to a file unless the file already has it
add_line() {
    local file="$1" line="$2"
    if ! grep -qxF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        echo "Added to $file: $line"
    fi
}

# bash loads the aliases directly; zsh loads them from this repo's zshrc
if [ -f ~/.bashrc ]; then
    add_line ~/.bashrc "[ -f ~/.aliases ] && source ~/.aliases"
fi

# Ask where git-prompt.zsh should go, unless ~/.zshrc already says, and clone it if missing
GIT_PROMPT_DIR="$(sed -n 's/^export GIT_PROMPT_DIR="\(.*\)"$/\1/p' ~/.zshrc 2>/dev/null | tail -n 1)"
if [ -z "$GIT_PROMPT_DIR" ]; then
    default="$HOME/code/git-prompt.zsh"
    read -r -p "Folder for git-prompt.zsh [$default]: " GIT_PROMPT_DIR || true
    GIT_PROMPT_DIR="${GIT_PROMPT_DIR:-$default}"
    GIT_PROMPT_DIR="${GIT_PROMPT_DIR/#\~/$HOME}"
fi
GIT_PROMPT_VERSION="v2.4.0"
if [ ! -d "$GIT_PROMPT_DIR" ]; then
    git -c advice.detachedHead=false clone --branch "$GIT_PROMPT_VERSION" https://github.com/woefe/git-prompt.zsh "$GIT_PROMPT_DIR"
fi

# Load this repo's zprofile and zshrc from ~/.zprofile and ~/.zshrc,
# which keep any settings for one machine only
add_line ~/.zprofile "source \"$DOTFILES_DIR/zprofile\""
add_line ~/.zshrc "export GIT_PROMPT_DIR=\"$GIT_PROMPT_DIR\""
add_line ~/.zshrc "source \"$DOTFILES_DIR/zshrc\""

echo "Done!"
echo ""
echo "Open a new shell to load the changes."
