# Silence Zsh warning on Mac OSX
export BASH_SILENCE_DEPRECATION_WARNING=1

# Set the default command for viewing.
# psql, for example, uses the PAGER variable.
export PAGER='less --chop-long-lines -N'

# Default to vim
export EDITOR=vim

# Bash defaults to storing the most recent 500 commands. Increase that.
export HISTFILESIZE=10000
export HISTSIZE=10000

# Significantly increase the maximum number of open file descriptors.
ulimit -n 2148