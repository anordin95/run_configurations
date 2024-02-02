function parse_git_dirty {
    STATUS="$(git status 2> /dev/null)"
    if [[ $? -ne 0 ]]; then printf "-"; return; else printf "["; fi
    if echo ${STATUS} | grep -c "renamed:"         &> /dev/null; then printf ">"; else printf ""; fi
    if echo ${STATUS} | grep -c "branch is ahead:" &> /dev/null; then printf "!"; else printf ""; fi
    if echo ${STATUS} | grep -c "new file::"       &> /dev/null; then printf "+"; else printf ""; fi
    if echo ${STATUS} | grep -c "Untracked files:" &> /dev/null; then printf "?"; else printf ""; fi
    if echo ${STATUS} | grep -c "modified:"        &> /dev/null; then printf "*"; else printf ""; fi
    if echo ${STATUS} | grep -c "deleted:"         &> /dev/null; then printf "-"; else printf ""; fi
    printf "]"
}

# Get the current git branch.
parse_git_branch() {
    git rev-parse --abbrev-ref HEAD 2> /dev/null
}

# PS1 is the environment variable bash displays as the prompt.
# Whereas PROMPT_COMMAND is an environment variable invoked as a function 
# immediately prior to the prompt being read from PS1 & displayed. 
# For example, PROMPT_COMMAND could contain "ddos https://google.com", so
# the terminal would ddos Google each time your it generates a prompt! 
generate_bash_prompt() {
    BLUE='\[\e[38;5;27m\]'
    CYAN='\[\e[38;5;87m\]'
    WHITE='\[\e[38;5;231m\]'
    YELLOW='\[\e[38;5;226m\]'
    RED='\[\e[38;5;196m\]'
    RESET='\[\e[0m\]'
    ORANGE='\[\e[38;5;208m\]'
    export PS1="${ORANGE}[$(pyenv version-name)]${RESET} ${CYAN}\W${RESET} ${WHITE}\t ${RESET} ${YELLOW}\$(parse_git_branch)${RED}\$(parse_git_dirty)${RESET} \n \$ "
}
PROMPT_COMMAND="generate_bash_prompt;${PROMPT_COMMAND}"
