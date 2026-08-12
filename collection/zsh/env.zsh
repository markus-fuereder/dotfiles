#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#! No need to rebuild the nix flake, this will be sourced when the shell starts
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Terminal =============================================================================================================
# xterm-256color, not plain xterm: nvim reads terminfo for undercurl (LSP diagnostics) and italics,
# which the 8-colour xterm entry doesn't advertise. Truecolor still comes from kitty's COLORTERM.
export TERM=xterm-256color

# EDITOR ===============================================================================================================
# nvim is configured declaratively via nixvim (collection/nix/nvim). This is what git, commitizen
# and gh open for commit messages and interactive edits.
export EDITOR=nvim
export VISUAL=nvim

export BIN=/run/current-system/sw/bin/
export BREW_HOME=/opt/homebrew

# XDG ==================================================================================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# FVM - Flutter Version Management =====================================================================================
export FVM_CACHE_PATH=$HOME/.fvm/versions

# JAVA =================================================================================================================
export JAVA_BIN="$(readlink -f $BIN/java)"
export JAVA_HOME=${JAVA_BIN:h:h}
# export OPEN_JDK=$BREW_HOME/opt/openjdk@17
# export JDK_HOME=$OPEN_JDK/bin
# export JAVA_HOME=$OPEN_JDK/libexec/openjdk.jdk/Contents/Home
# export PATH=$JDK_HOME:$JAVA_HOME:$PATH

# ANDROID ==============================================================================================================
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools
export ANDROID_TOOLS=$ANDROID_HOME/tools
export ANDROID_CMD_TOOLS=$ANDROID_HOME/cmdline-tools/latest/bin
export ANDROID=$ANDROID_PLATFORM_TOOLS:$ANDROID_TOOLS:$ANDROID_CMD_TOOLS

# PYENV ================================================================================================================
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# --no-rehash: startup rehash races when shells get killed mid-run (d2-driver/tmux) and strands the .pyenv-shim lock; rehash manually after pyenv/pip installs
eval "$(pyenv init - --no-rehash zsh)"

# RUBY =================================================================================================================
export RUBY_HOME="$(readlink -f $BIN/ruby)"
export GEM_HOME=$HOME/.ruby/gems
mkdir -p $GEM_HOME

# NPM ==================================================================================================================
export NPM_HOME=$HOME/.npm-global
export NPM_GLOBAL_BIN=$NPM_HOME/bin

# TMUX ================================================================================================================
export TMUX_PLUGIN_MANAGER_PATH=$HOME/.tmux/plugins

# FNM / NVM ===========================================================================================================
export FNM_LOGLEVEL=quiet

# Anthropic & Claude
export CLAUDE_FLOW_ENCRYPT_AT_REST=1
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=58
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=100000000
export CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION=9999
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1

export CLAUDE_CMD="headroom wrap claude --code-memory none --memory"


# AWS
export AWS_REGION=eu-central-1
export AWS_DEFAULT_REGION=eu-central-1

# Domain Delivery Driver
export D2_DRIVER_POLL_SECONDS="30"
export D2_DRIVER_CLAUDE_CMD="$CLAUDE_CMD"
export D2_DRIVER_WORKTREE_DIR=".worktrees"
export D2_DRIVER_BRANCH_PREFIX="d2-driver/"
export D2_DRIVER_TMUX_SESSION="d2d"
export D2_DRIVER_RELAUNCH_COOLDOWN_MS="600000"
export D2_DRIVER_MIN_WINDOW_LIFETIME_MS="10000"
export D2_DRIVER_NOTIFY_USERS="architect"
# export D2_DRIVER_CLAUDE_MODEL="opus[1m]"
# export D2_DRIVER_CLAUDE_VERSIO="2.1.220"


