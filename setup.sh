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

# Git reads ~/.config/git/config before ~/.gitconfig. If only the first of
# these exists, put the include there, so that its settings still win.
global_gitconfig="$HOME/.gitconfig"
xdg_gitconfig="${XDG_CONFIG_HOME:-$HOME/.config}/git/config"
if [ ! -e "$global_gitconfig" ] && [ -f "$xdg_gitconfig" ]; then
    global_gitconfig="$xdg_gitconfig"
fi

# Include this repo's gitconfig at the top of the global git config. The rest
# of that file keeps settings that belong to one person or machine, such as
# user.name and user.email, and overrides this repo's settings.
if git config --global --get-all include.path | grep -qxF "$DOTFILES_DIR/gitconfig"; then
    echo "The global git config already includes $DOTFILES_DIR/gitconfig, skipping"
else
    # Quote the path for git, so that characters such as # stay part of it
    quoted_path="${DOTFILES_DIR//\\/\\\\}"
    quoted_path="${quoted_path//\"/\\\"}"
    new_gitconfig="$(mktemp)"
    printf '[include]\n\tpath = "%s"\n' "$quoted_path/gitconfig" > "$new_gitconfig"
    if [ -e "$global_gitconfig" ]; then
        cat "$global_gitconfig" >> "$new_gitconfig"
    fi
    cat "$new_gitconfig" > "$global_gitconfig"
    rm "$new_gitconfig"
    echo "Added an include of $DOTFILES_DIR/gitconfig to the top of $global_gitconfig"
fi

# Ask for the git identity if the global git config doesn't have one yet,
# counting files that it includes
for key in user.name user.email; do
    if [ -z "$(git config --global --includes "$key")" ]; then
        read -r -p "Git $key (Enter to skip): " value || { value=""; echo; }
        if [ -n "$value" ]; then
            git config --global "$key" "$value"
        else
            echo "Skipped. Set it later with: git config --global $key <value>"
        fi
    fi
done

# Link ~/.aliases to this repo's aliases, replacing a broken link
if [ -L ~/.aliases ] && [ ~/.aliases -ef "$DOTFILES_DIR/aliases" ]; then
    echo "~/.aliases already links to $DOTFILES_DIR/aliases, skipping"
elif [ -L ~/.aliases ] && [ ! -e ~/.aliases ]; then
    ln -sf "$DOTFILES_DIR/aliases" ~/.aliases
    echo "Replaced the broken ~/.aliases link with a link to $DOTFILES_DIR/aliases"
elif [ -e ~/.aliases ]; then
    echo "~/.aliases already exists, so this repo's aliases aren't linked. Move it aside and run setup.sh again to link them."
else
    ln -s "$DOTFILES_DIR/aliases" ~/.aliases
    echo "Linked aliases"
fi

# Append a line to a file unless the file already has it. If the file doesn't
# end with a newline, add one first, so that the line starts on its own.
add_line() {
    local file="$1" line="$2"
    if ! grep -qxF "$line" "$file" 2>/dev/null; then
        if [ -s "$file" ] && [ -n "$(tail -c 1 "$file")" ]; then
            echo >> "$file"
        fi
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
zshrc_sets_prompt_dir="${GIT_PROMPT_DIR:+yes}"
if [ -z "$GIT_PROMPT_DIR" ]; then
    default="$HOME/code/git-prompt.zsh"
    read -r -p "Folder for git-prompt.zsh [$default]: " GIT_PROMPT_DIR || true
    GIT_PROMPT_DIR="${GIT_PROMPT_DIR:-$default}"
fi
GIT_PROMPT_DIR="${GIT_PROMPT_DIR/#\~/$HOME}"
GIT_PROMPT_DIR="${GIT_PROMPT_DIR/#\$HOME/$HOME}"
case "$GIT_PROMPT_DIR" in
    /*) ;;
    *) GIT_PROMPT_DIR="$PWD/$GIT_PROMPT_DIR" ;;
esac
GIT_PROMPT_VERSION="v2.4.0"
if [ -r "$GIT_PROMPT_DIR/git-prompt.zsh" ]; then
    echo "$GIT_PROMPT_DIR already has git-prompt.zsh, skipping"
elif [ -e "$GIT_PROMPT_DIR" ]; then
    echo "$GIT_PROMPT_DIR has no git-prompt.zsh, so the prompt will leave out git status"
elif ! git -c advice.detachedHead=false clone --branch "$GIT_PROMPT_VERSION" https://github.com/woefe/git-prompt.zsh "$GIT_PROMPT_DIR"; then
    echo "Couldn't clone git-prompt.zsh, so the prompt will leave out git status. Run setup.sh again to retry."
fi

# Load this repo's zprofile and zshrc from ~/.zprofile and ~/.zshrc,
# which keep any settings for one machine only
add_line ~/.zprofile "source \"$DOTFILES_DIR/zprofile\""
if [ -z "$zshrc_sets_prompt_dir" ]; then
    add_line ~/.zshrc "export GIT_PROMPT_DIR=\"$GIT_PROMPT_DIR\""
fi
add_line ~/.zshrc "source \"$DOTFILES_DIR/zshrc\""

echo "Done!"
echo ""
echo "Open a new shell to load the changes."
