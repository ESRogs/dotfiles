# dotfiles

My personal configuration files for zsh and git, on macOS or Linux.

## Setup

Setup needs git, bash and zsh. On a Mac, install [Homebrew](https://brew.sh) first, which also installs git:

```bash
git clone https://github.com/ESRogs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Optional tools

Each of these tools turns on a few more features:

| Tool | What it enables |
|---|---|
| [gh](https://cli.github.com) | the `pr` and `ci` git aliases, and GitHub logins through `gh` (run `gh auth login`) |
| [git-lfs](https://git-lfs.com) | repos that use Git LFS, which fail to check out without it |
| [uv](https://docs.astral.sh/uv/) | the `py` alias |
| [Starship](https://starship.rs) | the `pstar` prompt |
| [VS Code](https://code.visualstudio.com) | the `vs` alias |
| tmux, btop, watch | nothing in these files; they're tools I use everywhere |

On a Mac, run `brew bundle` in this folder to install them all. On Linux, use your package manager or each tool's own installer.

## Contents

- `gitconfig` - Git aliases, git-lfs, and `gh` as the credential helper for GitHub
- `zshrc` - Completions, colors, aliases, and the prompt
- `zprofile` - Homebrew's environment if Homebrew is installed, and `~/.local/bin` on `PATH`
- `aliases` - Shell aliases
- `Brewfile` - The optional tools, for `brew bundle` on a Mac

`setup.sh` adds an `[include]` of this repo's `gitconfig` at the top of `~/.gitconfig`. Other settings, such as `user.name` and `user.email`, stay in `~/.gitconfig` and override this repo's settings. If they aren't set yet, `setup.sh` asks for them.

`setup.sh` adds a line to `~/.zprofile` that sources this repo's `zprofile`, and two lines to `~/.zshrc` that set `GIT_PROMPT_DIR` and source this repo's `zshrc`. Settings for one machine only can stay in `~/.zprofile` and `~/.zshrc`.

The lines that `setup.sh` adds to these files use the repo's full path. To move the repo, delete those lines and run `setup.sh` again from the new folder.

## Prompt

The default prompt is [git-prompt.zsh](https://github.com/woefe/git-prompt.zsh). It shows a ✔ or ✘ for the last command's exit status, the current directory, the git status, and the time. `setup.sh` asks which folder to clone it into, with `~/code/git-prompt.zsh` as the default, and checks out version 2.4.0. Run `pstar` to switch to [Starship](https://starship.rs) in the current shell, and `pgit` to switch back.
