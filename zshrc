autoload -Uz compinit
compinit

autoload -U colors && colors

[ -f ~/.aliases ] && source ~/.aliases

# Prompt: git-prompt.zsh (default) or Starship.
# Set PROMPT_STYLE=starship before this file runs to start with Starship,
# or run pstar / pgit to switch in the current shell.
# GIT_PROMPT_DIR is the folder that git-prompt.zsh is cloned into. setup.sh sets it in ~/.zshrc.
PROMPT_STYLE="${PROMPT_STYLE:-git}"

use_git_prompt() {
    local script="${GIT_PROMPT_DIR:-$HOME/code/git-prompt.zsh}/git-prompt.zsh"
    local git_status=''
    if [[ -r "$script" ]]; then
        source "$script"
        ZSH_GIT_PROMPT_SHOW_STASH=1
        git_status=' $(gitprompt)'
    else
        echo "Can't find $script, so the prompt leaves out git status"
    fi
    PROMPT='%(?.%{$fg[green]%}✔.%{$fg[red]%}✘)%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%}'"$git_status"'
%{$fg[white]%}%T%{$reset_color%} %# '
}

pstar() {
    if ! (( $+commands[starship] )); then
        echo "Starship isn't installed"
        return 1
    fi
    PROMPT_STYLE="starship"
    eval "$(starship init zsh)"
    echo "Switched to Starship prompt"
}

pgit() {
    PROMPT_STYLE="git"
    use_git_prompt
    echo "Switched to git-prompt.zsh"
}

if [[ "$PROMPT_STYLE" == "starship" ]] && (( $+commands[starship] )); then
    eval "$(starship init zsh)"
else
    use_git_prompt
fi
