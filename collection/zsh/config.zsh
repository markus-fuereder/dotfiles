#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#! No need to rebuild the nix flake, this will be sourced when the shell starts
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Environment variables ================================================================================================
touch /etc/dotfiles/collection/zsh/env.zsh
source /etc/dotfiles/collection/zsh/env.zsh

# PATH =================================================================================================================
touch /etc/dotfiles/collection/zsh/path.zsh
source /etc/dotfiles/collection/zsh/path.zsh

# SECRETS ==============================================================================================================
touch /etc/dotfiles/collection/zsh/secrets.zsh
source /etc/dotfiles/collection/zsh/secrets.zsh

# ZSH configuration file ===============================================================================================
# Flags ----------------------------------------------------------------------------------------------------------------
# setopt correct # ............................................................................... Auto correct mistakes
setopt autocd # .................................................................................. Auto change directory
setopt nocheckjobs # ................................................. # Don't warn about running processes when exiting
setopt histignorealldups # ................................................................ Ignore duplicates in history
setopt interactivecomments # ........................................................ Allow comments in interactive mode

# Styles ---------------------------------------------------------------------------------------------------------------
# Autocompletion .......................................................................................................
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # ................................ Case insensitive completion
zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" # .................................. Set colors for completion
zstyle ':completion:*' rehash true # ........................................ Automatically find new executables in path

# Key bindings ---------------------------------------------------------------------------------------------------------
bindkey -e # ........................................... Default to standard emacs bindings, regardless of editor string
bindkey "^K"      kill-whole-line # ............................................................................. ctrl-k
bindkey "^R"      history-incremental-search-backward # ......................................................... ctrl-r
bindkey "^A"      beginning-of-line # ........................................................................... ctrl-a
bindkey "^E"      end-of-line # ................................................................................. ctrl-e
bindkey  "^[[3~"  delete-char # ................................................................................. ctrl-d
bindkey "^D"      delete-char # ................................................................................. ctrl-d
bindkey "^F"      forward-char # ................................................................................ ctrl-f
bindkey "^B"      backward-char # ............................................................................... ctrl-b
bindkey "[B"      history-search-forward # .................................................................. down arrow
bindkey "[A"      history-search-backward # ................................................................... up arrow

# Login message --------------------------------------------------------------------------------------------------------
touch ~/.hushlogin # .......................................................................... Don't show login message
