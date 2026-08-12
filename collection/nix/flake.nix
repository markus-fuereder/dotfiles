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

    # Nixvim ---------------------------------------------------------------------------------------
    # Declarative Neovim: plugins, options and keymaps are all Nix, materialised into a
    # store-immutable config. No runtime plugin manager, so no lockfile to drift.
    # Deliberately NO `inputs.nixpkgs.follows` here — upstream recommends against overriding it,
    # and nixvim's `main` branch already targets nixpkgs-unstable, which this flake tracks. Since
    # home-manager runs with `useGlobalPkgs`, the module builds against our pkgs either way; the
    # cost of not following is one extra nixpkgs entry in flake.lock, not duplicate builds.
    nixvim = {
      url = "github:nix-community/nixvim";
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
    , nixvim
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
            # imports list rather than a bare `import ./home.nix`, so the nixvim home-manager
            # module lands in the same user config that home.nix extends.
            users.${username} = {
              imports = [
                ./home.nix
                nixvim.homeModules.nixvim
              ];
            };
          };
          users.users.${username}.home = "/Users/${username}";
        }
      ];
    };
  };
}
