# dotfiles

My personal configuration files for zsh and git, on macOS or Linux.

## Setup

Setup needs git, bash and zsh:

```bash
git clone https://github.com/ESRogs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

On a fresh Mac, running `git` for the first time offers to install Apple's Command Line Tools, which include git. On Linux, run `chsh -s "$(command -v zsh)"` if zsh isn't your login shell yet, then log out and back in.

## Optional tools

Each of these tools turns on a few more features:

| Tool | What it enables |
|---|---|
| [gh](https://cli.github.com) | the `pr` and `ci` git aliases, which work on the current branch's pull request. `gh auth login` also offers to set up git to log in to GitHub through `gh`. |
| [git-lfs](https://git-lfs.com) | repos that use Git LFS. Run `git lfs install` once to download LFS files on every checkout, or `git lfs install --skip-smudge` to keep the small pointer files until you run `git lfs pull` in a repo. |
| [uv](https://docs.astral.sh/uv/) | the `py` alias |
| [Starship](https://starship.rs) | the `pstar` prompt |
| [VS Code](https://code.visualstudio.com) | the `vs` alias, which needs VS Code's `code` command on `PATH` |
| tmux, btop, watch | nothing in these files; they're tools I use everywhere |

On a Mac, install [Homebrew](https://brew.sh), then run `brew bundle` in this folder, in a shell opened after installing Homebrew and running `setup.sh`, to install them all. On Linux, use your package manager or each tool's own installer.

## Contents

- `gitconfig` - Git aliases and settings
- `zshrc` - Completions, colors, aliases, `rezsh` to reload the zsh config, and the prompt
- `zprofile` - Homebrew's environment if Homebrew is installed, and `~/.local/bin` on `PATH`
- `aliases` - Shell aliases
- `Brewfile` - The optional tools, for `brew bundle` on a Mac

`setup.sh` adds an `[include]` of this repo's `gitconfig` at the top of `~/.gitconfig`, or of `~/.config/git/config` if only that file exists. Other settings, such as `user.name` and `user.email`, stay in `~/.gitconfig` and override this repo's settings. If they aren't set yet, `setup.sh` asks for them, and pressing Enter skips them.

`setup.sh` adds a line to `~/.zprofile` that sources this repo's `zprofile`, and two lines to `~/.zshrc` that set `GIT_PROMPT_DIR` and source this repo's `zshrc`. Settings for one machine only can stay in `~/.zprofile` and `~/.zshrc`.

`setup.sh` also links `~/.aliases` to this repo's `aliases`, and if `~/.bashrc` exists, adds a line to it that sources `~/.aliases`.

The lines that `setup.sh` adds to `~/.gitconfig`, `~/.zprofile` and `~/.zshrc` use the repo's full path. To move the repo, move the folder, delete those lines, and run `setup.sh` again from the new folder. It replaces the `~/.aliases` link too, which moving the folder breaks.

## Prompt

The default prompt is [git-prompt.zsh](https://github.com/woefe/git-prompt.zsh). It shows a ✔ or ✘ for the last command's exit status, the current directory, the git status, and the time. `setup.sh` asks which folder to clone it into, with `~/code/git-prompt.zsh` as the default, and checks out version 2.4.0. Run `pstar` to switch to [Starship](https://starship.rs), and `pgit` to switch back. Each one restarts the current shell with the chosen prompt and saves the choice in `~/.local/state/dotfiles/prompt-style` (or under `$XDG_STATE_HOME` if that's set), so that new shells start with it too. Shells that are already open keep their prompt until they restart. Neither command switches while the shell has jobs, since the new shell couldn't resume them.
