# dotfiles

My personal configuration files for zsh and git, on macOS or Linux.

## Setup

Setup needs git, bash and zsh:

```bash
git clone https://github.com/ESRogs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Optional tools

Everything works without these tools. Each one turns on a few more features:

| Tool | What it enables |
|---|---|
| [gh](https://cli.github.com) | the `pr` and `ci` git aliases, and GitHub logins through `gh` (run `gh auth login`) |
| [git-lfs](https://git-lfs.com) | repos that use Git LFS (run `git lfs install`) |
| [uv](https://docs.astral.sh/uv/) | the `py` alias |
| [Starship](https://starship.rs) | the `pstar` prompt |
| [VS Code](https://code.visualstudio.com) | the `vs` alias |
| tmux, btop, watch | nothing in these files; they're tools I use everywhere |

On a Mac, install [Homebrew](https://brew.sh), then run `brew bundle` in this folder to install them all. On Linux, use your package manager or each tool's own installer.

## Contents

- `gitconfig` - Git aliases, git-lfs, and `gh` as the credential helper for GitHub
- `zshrc` - Completions, colors, aliases, and the prompt
- `zprofile` - Homebrew's environment if Homebrew is installed, and `~/.local/bin` on `PATH`
- `aliases` - Shell aliases
- `Brewfile` - The optional tools, for `brew bundle` on a Mac

`setup.sh` adds an `[include]` of this repo's `gitconfig` to `~/.gitconfig`. Other settings, such as `user.name` and `user.email`, stay in `~/.gitconfig`. If they aren't set yet, `setup.sh` asks for them.

`setup.sh` adds a line to `~/.zprofile` that sources this repo's `zprofile`, and two lines to `~/.zshrc` that set `GIT_PROMPT_DIR` and source this repo's `zshrc`. Settings for one machine only can stay in `~/.zprofile` and `~/.zshrc`.

## Prompt

The default prompt is [git-prompt.zsh](https://github.com/woefe/git-prompt.zsh). It shows a ✔ or ✘ for the last command's exit status, the current directory, the git status, and the time. `setup.sh` asks which folder to clone it into, with `~/code/git-prompt.zsh` as the default. Run `pstar` to switch to [Starship](https://starship.rs) in the current shell, and `pgit` to switch back.
