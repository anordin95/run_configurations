#!/bin/bash
set -o pipefail

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(/opt/homebrew/bin/pyenv init -)"

# Remove unnecessary folders that are automatically created by MacOS on startup.
if [ -d "/Users/anordin/Music" ]; then
  rm -rf "/Users/anordin/Music"
fi
if [ -d "/Users/anordin/Movies" ]; then
  rm -rf "/Users/anordin/Movies"
fi

# For compilers to find openssl@1.1 you may need to set:
# https://stackoverflow.com/questions/64353172/pyenv-build-failed-os-x-10-15-7-using-python-build-20180424
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# get current status of git repo
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

parse_git_branch() {
  # Long form
  git rev-parse --abbrev-ref HEAD 2> /dev/null
  # Short form
  # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}

generate_prompt_command() {
  BLUE='\[\e[38;5;27m\]'
  CYAN='\[\e[38;5;87m\]'
  WHITE='\[\e[38;5;231m\]'
  YELLOW='\[\e[38;5;226m\]'
  RED='\[\e[38;5;196m\]'
  RESET='\[\e[0m\]'
  ORANGE='\[\e[38;5;208m\]'
  export PS1="${ORANGE}[$(pyenv version-name)]${RESET} ${CYAN}\W${RESET} ${WHITE}\t ${RESET} ${YELLOW}\$(parse_git_branch)${RED}\$(parse_git_dirty)${RESET} \n \$ "
}

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}generate_prompt_command"
# Silence Zsh warning on Mac OSX
export BASH_SILENCE_DEPRECATION_WARNING=1
# Set default behavior for python PED package
export PED_OPEN_DIRECTORIES=1
# export EDITOR='sublime'

# Increase limit of maximum open file handles
ulimit -n 8192


# Load Git completion
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# Git aliases
alias gs='git status'
alias gb='git branch'
alias ga='git add'
alias gc='git checkout'

# Common aliases & functions
alias pip='pip3'
path(){
  echo ${PATH} | tr ":" "\n"
}

alias k='kubectl'
alias ..='cd ..'
alias p='python'
alias s='sublime'
alias v="${HOME}/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias lsm='exa --long --sort=modified --reverse'
alias ls='exa --long'
alias jb='jupyter notebook --log-level=ERROR'
alias less='less --chop-long-lines --LINE-NUMBERS'

# MacOS requires sudo permissions to view processes that don't belong to the current user.
alias procs='sudo procs'

# Include hidden directories & files
# Include files that would otherwise be ignored by
# local or global .gitignore, .ignore, or .fdignore. 
alias fd='fd --hidden --no-ignore'

# Helper-function (kind of like an alias) to compile,
# invoke and clean-up a C program.
c(){
  clang -std=gnu17 -o tmp_binary $1 
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}

# On MacOS, the following binaries are all identical!
# /usr/bin/clang
# /usr/bin/clang++
# /usr/bin/c++
# /usr/bin/gcc
# The help page indicates they are all in-fact the clang compiler. 
# invoke and clean-up a C program.
# Despite their equality, my system fails to compile C++ files
# with the /usr/bin/clang compiler. 
c++(){
  clang++ -o tmp_binary --std=c++17 $1
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}



# Helper-function to determine if two binaries contain the same contents.
are_binaries_equal(){
  BINARY_PATH_ONE=$1
  BINARY_PATH_TWO=$2
  if [[ $(md5 -q ${BINARY_PATH_ONE}) == $(md5 -q ${BINARY_PATH_TWO}) ]];
    then echo 'Binaries are Equal!'
  else 
    echo 'Womp womp... Not Equal,'
  fi
}

convert_all_heic_files_to_jpeg(){
  magick mogrify -monitor -format jpeg *.HEIC && rm *.HEIC
}