# dotfiles

My personal configuration files.

## Setup

```bash
git clone https://github.com/ESRogs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Contents

- `gitconfig` - Git aliases and settings

`setup.sh` adds an `[include]` of this repo's `gitconfig` to `~/.gitconfig`. Other settings, such as `user.name` and `user.email`, stay in `~/.gitconfig`. If they aren't set yet, `setup.sh` asks for them.
