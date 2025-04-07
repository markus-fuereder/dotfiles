# nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"
# darwin-rebuild switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"

{
  # INPUTS =========================================================================================
  inputs = {
    # Nix Packages ---------------------------------------------------------------------------------
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    # Nix Darwin -----------------------------------------------------------------------------------
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager ---------------------------------------------------------------------------------
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew -------------------------------------------------------------------------------------
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-fvm = {
      url = "github:leoafarias/homebrew-fvm";
      flake = false;
    };

    # Mac App Util ---------------------------------------------------------------------------------
    mac-app-util = {
      # https://github.com/hraban/mac-app-util
      # url = "github:hraban/mac-app-util";
      url = "github:markus-fuereder/nix-mac-app-util";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  # OUTPUTS ========================================================================================
  outputs = inputs @ {
      self
    , nixpkgs
    , nix-darwin
    , home-manager
    , nix-homebrew, homebrew-core, homebrew-cask, homebrew-fvm
    , mac-app-util
    , nix-vscode-extensions
  }: let username = "markus"; in
  {
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."shared".pkgs;
    darwinConfigurations."shared" = nix-darwin.lib.darwinSystem {
      modules = [
        ./config.nix
        ./darwin.nix
        mac-app-util.darwinCustomModules.default
        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs.vars.username = username;
            users.${username} = import ./home.nix;
          };
          users.users.${username}.home = "/Users/${username}";
        }
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            user = username;
            enableRosetta = true;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "leoafarias/homebrew-fvm" = homebrew-fvm;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }


      ];
    };

    # nixpkgs.overlays = [
    #       nix-vscode-extensions.overlays.default
    #     ];
  };
}
