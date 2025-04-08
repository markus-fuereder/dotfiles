{ pkgs, config, ... }:
{
    # SYSTEM ===========================================================================================================
    # The `system.stateVersion` option is not defined in your nix-darwin configuration. The value is used to
    # conditionalize backwards‐incompatible changes in default settings. You should usually set this once when
    # installing nix-darwin on a new system and then never change it (at least without reading all the relevant entries
    # in the changelog using `darwin-rebuild changelog`).
    # So, do not change this value
    system.stateVersion = 6;

    # NIX ==============================================================================================================
    nix = {
        settings.experimental-features = "nix-command flakes";
        optimise.automatic = true;
        gc = {
            automatic = true;
            options = "--delete-older-than 1w";
        };
    };

    # NIX PKGS =========================================================================================================
    nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = "aarch64-darwin";
    };

    # ZSH ==============================================================================================================
    programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;
        enableFzfCompletion = true;
        enableFzfGit = true;
        enableFzfHistory = true;
        # Initialization script for zsh --------------------------------------------------------------------------------
        shellInit = ''
            # Powerlevel10k ............................................................................................
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            source /etc/dotfiles/collection/powerlevel10k/p10k.zsh
            if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

            # Autosuggestions ..........................................................................................
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

            # Syntax-Highlighting ......................................................................................
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

            # fnm / nvm autoload .......................................................................................
            eval "$(fnm env --use-on-cd --shell zsh)"

            # ZSH Config, flags, styles & environment variables ........................................................
            source /etc/dotfiles/collection/zsh/config.zsh

            # Environment ..............................................................................................
            source /etc/dotfiles/collection/zsh/env.zsh
        '';
    };

    # PACKAGES =========================================================================================================
    environment.systemPackages = with pkgs; [
        # Fonts --------------------------------------------------------------------------------------------------------
        meslo-lgs-nf # ..................................................................... Nerd Font for Powerlevel10k
        fira-code # ................................................................................... Programming font

        # Shell & Terminal ---------------------------------------------------------------------------------------------
        oh-my-zsh # .................................................................................. Framework for zsh
        zsh-powerlevel10k # ................................................................ Theme powerlevel10k for zsh
        zsh-autosuggestions # ........................................................... Plugin autosuggestions for zsh
        zsh-syntax-highlighting # ................................................... Plugin syntax highlighting for zsh
        kitty # ...................................................................................... Terminal emulator
        tmux # .................................................................................... Terminal multiplexer

        # CLI Tools ----------------------------------------------------------------------------------------------------
        neofetch # .......................................................................... Display system information
        vim # .............................................................................................. Text editor
        git # .......................................................................................... Version control
        lazygit # .................................................................................. Terminal UI for git
        mkalias # ....................................................................................... Create aliases
        bat # .................................................................................... Replacement for `cat`
        lsd # ..................................................................................... Replacement for `ls`
        # eza # ................................................................................... Replacement for `ls`
        zoxide # .................................................................................. Replacement for `cd`
        fzf # ............................................................................................. Fuzzy finder
        pay-respects # ................................................. Correct previous console command like "thefuck"
        ripgrep # .............................................................................. Search files with regex
        imagemagick # .......................................................................... Image manipulation tool
        mas # ..................................................................... Mac App Store command line interface

        # Development Tools --------------------------------------------------------------------------------------------
        fnm # ............................................................................. fast Node.js version manager
        # vscode # .................................................................................. Visual Studio Code
        vscode-with-extensions # .................................................................... Visual Studio Code
        # android-studio # ............................................................................ Android Studio IDE
        docker # .................................................................................... Container platform
        # beekeeper-studio # .................................................................... Database management tool
        postman # ...................................................................................... API development

        # Languages ----------------------------------------------------------------------------------------------------
        ruby # ............................................................................... Ruby programming language

        # Apps ---------------------------------------------------------------------------------------------------------
        # _1password-gui # ............................................................................ Password manager
        # rectangle-pro # .................................................................. Window management for macOS
        obsidian # ................................................................ Note-taking and knowledge management
        firefox # .......................................................................................... Web browser
        google-chrome # .................................................................................... Web browser
        appcleaner # ......................................................................... App uninstaller for macOS
    ];

    # HOMEBREW =========================================================================================================
    # brew cleanup && rm -f $ZSH_COMPDUMP
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
        upgrade = true;
      };
      brews = [
        "fvm" # ................................................................................ Flutter version manager
      ];
      casks = [
        "imageoptim" # ......................................................................... Image optimization tool
        "istat-menus" # ......................................................................... System monitoring tool
      ];
      masApps = {
        # "Amphetamine" = 937984704; # .................................................................... Keep Mac awake
        # "Bitwarden" = 1352778147; # ................................................................... Password manager
        # "The Unarchiver" = 425424353; # ............................................................... Unarchiving tool
        # "Velja" = 1607635845; # .............................................................. Browser routing for macOS
      };
    };

    # ALIASES ==========================================================================================================
    environment.shellAliases = {
        nix-count-garbage = "nix-store --gc --print-dead | wc -l";
        nix-rebuild = "darwin-rebuild switch --flake \"$(readlink -f ~/.config/nix)#shared\"";
        cat = "bat";
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -a";
        lla = "lsd -la";
        l = "lsd -la";
        grep = "rg";
        nvm = "fnm";
        lg = "lazygit";
        config_link="sh /etc/dotfiles/link.sh";
        config_pull="sh /etc/dotfiles/pull.sh";
    };

}