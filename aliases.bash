# Git aliases
alias gs='git status'
alias gb='git branch'
alias ga='git add'

# Common aliases
alias pip="pip3"
alias python="python3"
alias path='echo ${PATH} | tr ":" "\n"'
alias k='kubectl'
alias p='python'
alias ls='exa --long'
# ls(m)odified
alias lsm="exa --long --sort=changed --reverse"
alias v="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias rm='rm -r'
alias less='less --chop-long-lines -N'

# --hidden: Search hidden files and directories. Otherwise, hidden files and directories are ignored.
# --no-ignore: Don’t respect ignore files.
# --ignore-case: Patterns are searched case insensitively.
alias fd='fd --hidden --no-ignore --ignore-case'
alias rg='rg --hidden --no-ignore --ignore-case'