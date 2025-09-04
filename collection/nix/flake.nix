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
            extraSpecialArgs.vars.username = username;
            users.${username} = import ./home.nix;
          };
          users.users.${username}.home = "/Users/${username}";
        }
      ];
    };
  };
}
