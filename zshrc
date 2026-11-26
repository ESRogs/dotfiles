autoload -Uz compinit
compinit

autoload -U colors && colors

[ -f ~/.aliases ] && source ~/.aliases

alias rezsh="source ~/.zprofile && source ~/.zshrc"

# Prompt: git-prompt.zsh (default) or Starship.
# To start with Starship, add : ${PROMPT_STYLE:=starship} to ~/.zshrc before the line that sources this file.
# pstar and pgit replace the current shell with a new one that uses the other prompt.
# GIT_PROMPT_DIR is the folder that git-prompt.zsh is cloned into. setup.sh sets it in ~/.zshrc.
PROMPT_STYLE="${PROMPT_STYLE:-git}"

use_git_prompt() {
    local script="${GIT_PROMPT_DIR:-$HOME/code/git-prompt.zsh}/git-prompt.zsh"
    local git_status=''
    if [[ -r "$script" ]]; then
        ZSH_GIT_PROMPT_SHOW_STASH=1
        source "$script"
        git_status=' $(gitprompt)'
    else
        echo "Can't find $script, so the prompt leaves out git status"
    fi
    PROMPT='%(?.%F{green}✔.%F{red}✘)%f %F{yellow}%~%f'"$git_status"'
%F{white}%T%f %# '
}

pstar() {
    if ! (( $+commands[starship] )); then
        echo "Starship isn't installed"
        return 1
    fi
    PROMPT_STYLE=starship exec zsh
}

pgit() {
    PROMPT_STYLE=git exec zsh
}

if [[ "$PROMPT_STYLE" == "starship" ]] && (( $+commands[starship] )); then
    # Set up Starship once per shell, since each setup wraps the previous one's key handler
    (( $+functions[prompt_starship_precmd] )) || eval "$(starship init zsh)"
else
    use_git_prompt
fi
