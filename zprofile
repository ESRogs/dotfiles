# Homebrew's environment, on Apple Silicon or Intel
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then
        eval "$("$brew" shellenv)"
        break
    fi
done

export PATH="$HOME/.local/bin:$PATH"
