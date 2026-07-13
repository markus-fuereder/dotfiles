# nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"
# darwin-rebuild switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"

{
  # INPUTS =========================================================================================
  inputs = {
    # Nix Packages ---------------------------------------------------------------------------------
    # Pinned to the stable release channel for reproducibility. The bare
    # `nixpkgs-unstable` branch drifted to HEAD on every rebuild (flake.lock is
    # gitignored), which pulled in a broken lima 2.1.4 (limactl ld crash) via colima.
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    # Nix Darwin -----------------------------------------------------------------------------------
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager ---------------------------------------------------------------------------------
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mac App Util ---------------------------------------------------------------------------------
    mac-app-util = {
      # https://github.com/hraban/mac-app-util
      url = "github:hraban/mac-app-util";
      # url = "github:markus-fuereder/nix-mac-app-util";
    };
  };

  # OUTPUTS ========================================================================================
  outputs = inputs @ {
      self
    , nixpkgs
    , nix-darwin
    , home-manager
    , mac-app-util
  }: let username = "markus"; in
  {
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."shared".pkgs;
    darwinConfigurations."shared" = nix-darwin.lib.darwinSystem {
      modules = [
        {
            system.primaryUser = username;
        }
        ./config.nix
        ./darwin.nix
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              vars = {
                username = username;
              };
            };
            users.${username} = import ./home.nix;
          };
          users.users.${username}.home = "/Users/${username}";
        }
      ];
    };
  };
}
