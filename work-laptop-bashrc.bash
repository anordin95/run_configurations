source environment-variables.bash
source aliases.bash

# ==============================================================
# Butterfly work-specifc initialization
# ==============================================================

alias kmy="k get pods,jobs -l user=anordin"
alias kdmy="kubectl get jobs -l user=anordin --no-headers | cut -d ' ' -f1 | xargs -I _ kubectl delete job _"
alias dl-deploy='cd /Users/anordin/src/software/host/Modules/BNI.DLTools'
# Token authorization flow for access to Amazon Web Services ECR: Elastic Container Registry via the Docker CLI.
# More details here: https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html
alias ecr-login='docker login -u AWS -p $(aws ecr get-login-password) https://853813216061.dkr.ecr.us-east-1.amazonaws.com'

export DL_HOME=~/src/dl-dev
export EFS_DL_ROOT=/home/anordin/src
export DL_NB_KERNEL_TIMEOUT_SECONDS=$((3600*6)) 
export DL_NB_SERVER_TIMEOUT_SECONDS=$((3600*12))
# Building a pylibmc, python library mem-cached, wheel requires
# memcached C++ header files. Provide that information here.
export LIBMEMCACHED="/opt/homebrew/Cellar/libmemcached/1.0.18_2/"

aws_sso_login_if_necessary() {
    # If the get-caller-identity call fails, the response goes to stderr, not stdout. So re-route stderr to stdout.
    CALLER_IDENTITY_RESPONSE=$(aws sts get-caller-identity 2>&1)
    echo Running! CALLER_IDENTITY_RESPONSE: ${CALLER_IDENTITY_RESPONSE}
    if [[ 
        # CALLER_IDENTITY_RESPONSE varies for reasons I don't know. 
        # Handle both cases: 
        "${CALLER_IDENTITY_RESPONSE}" == *"Error loading SSO Token"* ||
        "${CALLER_IDENTITY_RESPONSE}" == *"expired"*
    ]];
    then
        # The aws sso login call is unable to launch Chrome, but it can open a tab in 
        # an already running Chrome application. 
        open -a "Google Chrome.app"
        aws sso login
    fi
}
# Run in a sub-shell, quietly and in the background to minimize latency overhead of 
# the call to aws. Also prevent noise from job output & thread control output. 
(aws_sso_login_if_necessary 1>/dev/null 2>&1 & )

# ==============================================================
# Homebrew initialization
# ==============================================================

# Homebrew environment variables. Generated via $ /opt/homebrew/bin/brew shellenv
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

# ==============================================================
# Postgres initialization
# ==============================================================

export PATH="$PATH:/opt/homebrew/opt/postgresql@15/bin"

# ==============================================================
# pyenv initialization
# ==============================================================

# Prevent pyenv-virtualenv from modifying PS1 i.e. the bash prompt.
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# pyenv init - generates a series of bash commands which the 
# eval command runs in the current shell.
eval "$(pyenv init -)"

# Pyenv-virtualenv initialization. 
# The if statement was added by me, not pyenv. It ensures pyenv-virtualenv is not loaded multiple times.
if [[ ${PYENV_VIRTUALENV_INIT} -ne 1 ]]; 
then
    $(pyenv-virtualenv-init -)
fi

################################################################################
# ODDS & ENDS
################################################################################
# - Remove unused directories.
# - Load Git tab-completion.
# - Increase open file handles limit.
# - Automatically authenticate to aws SSO.

# Remove unused directories after ensuring they are nearly empty.
# These directories are re-created on login by MacOS, so have to 
# remove each time! Some of them are auto-populated with 
# sub-directories, which is why check nearly empty 
# rather than totally empty.
unused_directories=("${HOME}/Music" "${HOME}/Documents")
for unused_directory in ${unused_directories[@]}
do
    # in KB, since we use -k on the du command.
    ALMOST_EMPTY_THRESHOLD_KB=20
    # [[ -a ... ]] True if the file (or directory) exists.
    if [[ -a ${unused_directory} && $(du -sk ${unused_directory} | awk '{print $1}') -lt ${ALMOST_EMPTY_THRESHOLD_KB} ]]; then
        rm -rf ${unused_directory}
    fi
done

# Load Git completion
# Note: $_ means the last argument to the previous command. 
# so . $_ translates to 'source .git-completion.bash' in this case.
test -f ~/.dotfiles/git-completion.bash && source $_

# Increase limit of maximum open file handles
ulimit -n 8192

################################################################################
# PROMPT GENERATION
################################################################################
# Get the current folder's git repo status.
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
    # Long form
    git rev-parse --abbrev-ref HEAD 2> /dev/null
    # Short form
    # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
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


################################################################################
# DL-Team Setup
################################################################################
# Copied from https://butterflynetwork.atlassian.net/wiki/spaces/SW/pages/2827223523/Development+Environment
# Note: `` backticks not '' apostrophes have similar behavior as $(), except they do not nest.

source ~/.dlrc

# For now I'm going to leave this commented out since I don't believe it's necessary.
# OPENSSLPATH=$(brew --prefix openssl@1.1)
# READLINEPATH=$(brew --prefix readline)
# XCRUNPATH=$(xcrun --show-sdk-path)
# export CFLAGS="-I$OPENSSLPATH/include -I$READLINEPATH/include -I$XCRUNPATH/usr/include"
# export LDFLAGS="-L$OPENSSLPATH/lib -L$READLINEPATH/lib -L$XCRUNPATH/usr/lib -L/usr/local/opt/zlib/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include"
# export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

################################################################################
# SOFTWARE REPO SETUP
################################################################################
# Include the following lines for use of the software-repo.
# Environment variables related to pyenv and compiler flags may be over-written.
# The pyenv installation and some other components required by software conflict with
# the dl-team's default setup.

# # BEGIN source-develop-rc
# if [ -f ~/.bni/develop.rc ]; then
#   source ~/.bni/develop.rc
# fi
# # END source-develop-rc
# # Software direnv setup
# eval "$(direnv hook bash)"
# BEGIN source-develop-rc
if [ -f ~/.bni/develop.rc ]; then
  source ~/.bni/develop.rc
fi
# END source-develop-rc
