if [ -f ~/.dotfiles/git-completion.bash ]; then
    source ~/.dotfiles/git-completion.bash
fi

if [ -f ~/.bni/develop.rc ]; then
  source ~/.bni/develop.rc
fi

if [ -f ~/.dlrc ]; then
    source ~/.dlrc
fi

source /Users/anordin/src/run_configurations/environment-variables.bash
source /Users/anordin/src/run_configurations/aliases.bash
source /Users/anordin/src/run_configurations/generate-prompt.bash
source /Users/anordin/src/run_configurations/functions.bash

# Sections
# 1. Butterfly work-specifc initialization
# 2. Homebrew initialization
# 3. Postgres initialization
# 4. pyenv initialization

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
    eval "$(pyenv-virtualenv-init -)"
fi




