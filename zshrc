autoload -Uz compinit
compinit

autoload -U colors && colors

[ -f ~/.aliases ] && source ~/.aliases

alias rezsh="source ~/.zprofile && source ~/.zshrc"

# Prompt: git-prompt.zsh (default) or Starship.
# pstar and pgit save the choice in prompt_style_file, which new shells read when they start.
# GIT_PROMPT_DIR is the folder that git-prompt.zsh is cloned into. setup.sh sets it in ~/.zshrc.
prompt_style_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/prompt-style"

# Choose the prompt once per shell, so that rezsh keeps this shell's prompt.
# Use Starship only if it's the saved choice and it's installed.
if [[ -z "${prompt_style:-}" ]]; then
    prompt_style="git"
    if [[ -f "$prompt_style_file" && -r "$prompt_style_file" && "$(<"$prompt_style_file")" == "starship" ]] && (( $+commands[starship] )); then
        prompt_style="starship"
    fi
fi

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

# Save the prompt style in $1 for new shells, then replace this shell with a new one, keeping a login shell a login shell.
# Refuse while jobs exist, since the new shell can't resume them.
switch_prompt() {
    if (( ${#jobstates} )); then
        echo "Finish or fg your jobs first" >&2
        return 1
    fi
    # Write to a temporary file and rename it, so that a shell starting meanwhile never reads a partly written file
    mkdir -p "${prompt_style_file:h}" &&
        print -r -- "$1" >| "$prompt_style_file.$$" &&
        mv -f "$prompt_style_file.$$" "$prompt_style_file" || return
    if [[ -o login ]]; then
        exec zsh -l
    else
        exec zsh
    fi
}

pstar() {
    if ! (( $+commands[starship] )); then
        echo "Starship isn't installed" >&2
        return 1
    fi
    switch_prompt starship
}

pgit() {
    switch_prompt git
}

if [[ "$prompt_style" == "starship" ]]; then
    # Set up Starship once per shell, since each setup wraps the previous one's key handler
    (( $+functions[prompt_starship_precmd] )) || eval "$(starship init zsh)"
else
    use_git_prompt
fi
