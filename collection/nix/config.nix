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
        # Hardware -----------------------------------------------------------------------------------------------------
        karabiner-elements # ................................................................... Keyboard remapping tool

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
        wget # .................................................................................... HTTP client cli tool

        # CLI Tools ----------------------------------------------------------------------------------------------------
        neofetch # .......................................................................... Display system information
        vim # .............................................................................................. Text editor
        git # .......................................................................................... Version control
        lazygit # .................................................................................. Terminal UI for git
        gitmoji-cli # ................................................................................ Emoji CLI for git
        commitizen # ........................................................................... CLI for commit messages
        mkalias # ....................................................................................... Create aliases
        bat # .................................................................................... Replacement for `cat`
        lsd # ..................................................................................... Replacement for `ls`
        # eza # ................................................................................... Replacement for `ls`
        zoxide # .................................................................................. Replacement for `cd`
        fzf # ............................................................................................. Fuzzy finder
        pay-respects # ................................................. Correct previous console command like "thefuck"
        jless # ............................................................................................ JSON viewer
        ripgrep # .............................................................................. Search files with regex
        imagemagick # .......................................................................... Image manipulation tool
        gzip # ................................................................................... File compression tool
        mas # ..................................................................... Mac App Store command line interface

        # Development Tools --------------------------------------------------------------------------------------------
        fnm # ............................................................................. fast Node.js version manager
        yarn # ................................................................................. Node.js package manager
        pyenv # ................................................................................. Python version manager
        fastlane # .................................................................... Mobile app build automation tool
        openjdk17 # ............................................................................... Java Development Kit
        docker # .................................................................................... Container platform
        postman # ...................................................................................... API development
        gitleaks # .......................................................................................... GitHub CLI
        act # ....................................................................................... GitHub Actions CLI
        stripe-cli # ........................................................................................ Stripe CLI

        # Editors & IDEs -----------------------------------------------------------------------------------------------
        vscode # .................................................................................... Visual Studio Code
        # beekeeper-studio # .................................................................. Database management tool

        # Languages ----------------------------------------------------------------------------------------------------
        ruby_3_4 # ........................................................................... Ruby programming language

        # Apps ---------------------------------------------------------------------------------------------------------
        # _1password-gui # ............................................................................ Password manager
        # rectangle-pro # .................................................................. Window management for macOS
        obsidian # ................................................................ Note-taking and knowledge management
        appcleaner # ......................................................................... App uninstaller for macOS
        slack # ................................................................................ Team collaboration tool

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
        "cocoapods" # ............................................................................... Dependency manager
      ];
      casks = [
        "imageoptim" # ......................................................................... Image optimization tool
        "istat-menus" # ......................................................................... System monitoring tool
        "intellij-idea-ce" # .......................................................... Java IDE for Android development
        "android-studio" # ............................................................. Android development environment
        "bambu-studio" # ......................................................... 3D printing slicer for Bambu printers
        "rectangle-pro" # .................................................................. Window management for macOS
      ];
      masApps = {
        "Amphetamine" = 937984704; # .................................................................... Keep Mac awake
        "Bitwarden" = 1352778147; # ................................................................... Password manager
        "The Unarchiver" = 425424353; # ............................................................... Unarchiving tool
        "Velja" = 1607635845; # .............................................................. Browser routing for macOS
        "Pure Paste" = 1611378436; # .......................................................... Paste without formatting
        "Shareful" = 1522267256; # ........................................................ Share files and links easily
      };
    };

    # ALIASES ==========================================================================================================
    environment.shellAliases = {
        nix-count-garbage = "nix-store --gc --print-dead | wc -l";
        nix-rebuild = "sudo darwin-rebuild switch --flake \"$(readlink -f ~/.config/nix)#shared\"";
        sync-dotfiles = "git -C /etc/dotfiles pull";
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
        flutter="fvm flutter";
        gcd="git checkout develop";
        gfd="git fetch upstream develop:develop";
    };
}