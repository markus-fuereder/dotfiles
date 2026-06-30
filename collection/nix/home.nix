{ config, pkgs, lib, vars, ... }:
{
  # Home Manager =======================================================================================================
  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.11";
    username = "${vars.username}";
    homeDirectory = "/Users/${vars.username}";
    packages = with pkgs; [
      claude-code
    ];

    sessionPath = [
      "$HOME/.local/bin"
    ];
    file.".local/bin/claude".source = "${pkgs.claude-code}/bin/claude";

    # set colima as docker context
    activation.colima = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Run in a subshell so the PATH change stays local: exporting it here would
      # leak into later activation steps (e.g. linkGeneration), putting BSD
      # /usr/bin/readlink ahead of Nix coreutils and breaking `readlink -e`.
      # Keep /usr/bin after $PATH so coreutils still wins inside the subshell too.
      (
        export PATH="${lib.makeBinPath [ pkgs.docker pkgs.colima ]}:$PATH:/usr/bin"
        $DRY_RUN_CMD ${pkgs.colima}/bin/colima start --vm-type vz
        $DRY_RUN_CMD ${pkgs.docker}/bin/docker context use colima
      )
    '';
    # uv-managed global CLI tools
    activation.uv = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Subshell keeps PATH/SDKROOT local so they don't bleed into later
      # activation steps (matching the colima block above).
      (
        export PATH="/Users/markus/.local/bin:$PATH"
        # Command Line Tools clang can't auto-detect the SDK after an OS upgrade,
        # so native build backends (e.g. watchdog's C extension) fail to find
        # system headers like <assert.h>. Point them at the active SDK explicitly.
        export SDKROOT="$(/usr/bin/xcrun --show-sdk-path)"
        # Pin to Python 3.13 so packages with C extensions (watchdog) resolve to
        # prebuilt wheels instead of compiling from source on the bleeding-edge 3.14.
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'graphifyy[gemini]' --force
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'headroom-ai[proxy,mcp]'
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'markitdown[pdf, docx, pptx, xlsx, xls]'
      )
    '';
  };

  # ZSH ================================================================================================================
  #! Keep this, otherwise home-manager will not create the ~/.zshrc file and programs like vscode will not source it.
  programs.zsh = {
    enable = true;
  };

  # VSCode =============================================================================================================
  programs.vscode = {
    enable = true;
  };
}
