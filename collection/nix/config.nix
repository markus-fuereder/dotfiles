{ pkgs, config, ... }:
    # let
    #  pkgs = import (builtins.fetchGit {
    #      # Descriptive name to make the store path easier to identify
    #      name = "my-old-revision";
    #      url = "https://github.com/NixOS/nixpkgs/";
    #      ref = "refs/heads/nixpkgs-24.05-darwin";
    #      rev = "cca4f8e59e9479ced4f02f33530be367220d5826";
    #  }) {};
    # _1password-gui-override = pkgs._1password-gui;
    # in
{
    # SYSTEM =======================================================================================
    # The `system.stateVersion` option is not defined in your
    # nix-darwin configuration. The value is used to conditionalize
    # backwards‐incompatible changes in default settings. You should
    # usually set this once when installing nix-darwin on a new system
    # and then never change it (at least without reading all the relevant
    # entries in the changelog using `darwin-rebuild changelog`).
    system.stateVersion = 6; # Do not change this

    # NIX ==========================================================================================
    nix.settings.experimental-features = "nix-command flakes";

    # NIX PKGS =====================================================================================
    nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = "aarch64-darwin";
    };

    # ZSH ==========================================================================================
    programs.zsh = {
        enable = true;
    };



    # PACKAGES =====================================================================================
    environment.systemPackages = with pkgs; [
        # Fonts ------------------------------------------------------------------------------------
        fira-code
        meslo-lgs-nf

        # Terminal emulator and shell --------------------------------------------------------------
        kitty
        zsh-autosuggestions
        zsh-syntax-highlighting

        # CLI Tools --------------------------------------------------------------------------------
        neofetch # ...................................................... Display system information
        vim # .......................................................................... Text editor
        git # ...................................................................... Version control
        lazygit # .............................................................. Terminal UI for git
        mkalias # ................................................................... Create aliases
        bat # ................................................................ Replacement for `cat`
        lsd # ................................................................. Replacement for `ls`
        # eza # ............................................................... Replacement for `ls`
        zoxide # .............................................................. Replacement for `cd`
        fzf # .......................................................................... Fuzzy finder
        pay-respects # ............................. Correct previous console command like "thefuck"
        ripgrep # ........................................................... Search files with regex
        imagemagick # ...................................................... Image manipulation tool
        mas # ................................................. Mac App Store command line interface

        # Development Tools ------------------------------------------------------------------------
        fnm # ......................................................... fast Node.js version manager

        # Apps -------------------------------------------------------------------------------------
        # _1password-gui # .......................................................... Password manager
        # rectangle-pro # ................................................ Window management for macOS
        obsidian # ............................................ Note-taking and knowledge management
        firefox # ....................................................................... Web browser
        google-chrome # ................................................................ Web browser

    ];

    # ALIASES ======================================================================================
    environment.shellAliases = {
        rebuild = "darwin-rebuild switch --flake \"$(readlink -f ~/.config/nix)#shared\"";
        cat = "bat";
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -a";
        lla = "lsd -la";
        grep = "rg";
    };

    # HOMEBREW =====================================================================================
    # homebrew = {
    #   # Homebrew needs to be installed on its own!
    #   enable = true;
    #   onActivation.cleanup = "zap";
    #   brews = [
    #     "imagemagick"
    #     "mas"
    #   ];
    #   casks = [
    #     "imageoptim"
    #     "firefox"
    #     "the-unarchiver"
    #     # "istat-menus"
    #     # "amphetamine"
    #   ];
    #   masApps = {
    #     "1Password" = 1333542190;
    #   };
    # };

    # Docs: https://daiderd.com/nix-darwin/manual/index.html
    
}