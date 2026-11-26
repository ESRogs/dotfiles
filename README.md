# dotfiles

My personal configuration files for macOS with zsh.

## Setup

```bash
git clone https://github.com/ESRogs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Contents

- `gitconfig` - Git aliases, git-lfs, and `gh` as the credential helper for GitHub
- `zshrc` - Completions, colors, aliases, and the prompt
- `zprofile` - Homebrew's environment, and `~/.local/bin` on `PATH`
- `aliases` - Shell aliases

`setup.sh` adds an `[include]` of this repo's `gitconfig` to `~/.gitconfig`. Other settings, such as `user.name` and `user.email`, stay in `~/.gitconfig`. If they aren't set yet, `setup.sh` asks for them.

`setup.sh` adds a line to `~/.zprofile` that sources this repo's `zprofile`, and two lines to `~/.zshrc` that set `GIT_PROMPT_DIR` and source this repo's `zshrc`. Settings for one machine only can stay in `~/.zprofile` and `~/.zshrc`.

## Prompt

The default prompt is [git-prompt.zsh](https://github.com/woefe/git-prompt.zsh). It shows a ✔ or ✘ for the last command's exit status, the current directory, the git status, and the time. `setup.sh` asks which folder to clone it into, with `~/code/git-prompt.zsh` as the default. Run `pstar` to switch to [Starship](https://starship.rs) in the current shell, and `pgit` to switch back.
