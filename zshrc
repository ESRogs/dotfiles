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
# Keep the style inside this shell, so that programs started from it, such as a tmux server, use their own default
typeset +x PROMPT_STYLE

use_git_prompt() {
    local script="${GIT_PROMPT_DIR:-$HOME/code/git-prompt.zsh}/git-prompt.zsh"
    local git_status=''
    if [[ -r "$script" ]]; then
        ZSH_GIT_PROMPT_SHOW_STASH=1
        source "$script"
        git_status=' $(gitprompt)'
    else
        echo "Can't find $script, so the prompt leaves out git status" >&2
    fi
    PROMPT='%(?.%F{green}✔.%F{red}✘)%f %F{yellow}%~%f'"$git_status"'
%F{white}%T%f %# '
}

# Replace this shell with a new zsh that uses the prompt style in $1, keeping a login shell a login shell.
# Refuse while jobs exist, since the new shell can't resume them.
restart_with_prompt() {
    if (( ${#jobstates} )); then
        echo "Finish or fg your jobs first" >&2
        return 1
    fi
    if [[ -o login ]]; then
        PROMPT_STYLE="$1" exec zsh -l
    else
        PROMPT_STYLE="$1" exec zsh
    fi
}

pstar() {
    if ! (( $+commands[starship] )); then
        echo "Starship isn't installed" >&2
        return 1
    fi
    restart_with_prompt starship
}

pgit() {
    restart_with_prompt git
}

if [[ "$PROMPT_STYLE" == "starship" ]] && (( $+commands[starship] )); then
    # Set up Starship once per shell, since each setup wraps the previous one's key handler
    (( $+functions[prompt_starship_precmd] )) || eval "$(starship init zsh)"
else
    use_git_prompt
fi
