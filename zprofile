# Homebrew's environment, on Apple Silicon or Intel
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then
        eval "$("$brew" shellenv)"
        break
    fi
done

export PATH="$HOME/.local/bin:$PATH"

# Keep only the first copy of each PATH entry, so that sourcing this file again adds no duplicates
typeset -U path
