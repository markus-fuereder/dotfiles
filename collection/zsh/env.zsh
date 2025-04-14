#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#! No need to rebuild the nix flake, this will be sourced when the shell starts
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

export BIN=/run/current-system/sw/bin/
export BREW_HOME=/opt/homebrew

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