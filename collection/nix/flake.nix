# nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"
# darwin-rebuild switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"

{
  # INPUTS =========================================================================================
  inputs = {
    # Nix Packages ---------------------------------------------------------------------------------
    # Tracks nixpkgs-unstable. NOTE: flake.lock is gitignored, so this drifts to
    # HEAD on every lock refresh — a drift once pulled in a broken lima 2.1.4
    # (limactl ld crash) via colima; pin back to a release branch if that recurs.
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    # Nix Darwin -----------------------------------------------------------------------------------
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager ---------------------------------------------------------------------------------
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
