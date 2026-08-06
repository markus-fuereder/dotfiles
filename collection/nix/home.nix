{ config, pkgs, lib, vars, ... }:
let
  # tmux theme — not in nixpkgs, so pin it from upstream.
  # TPM (loaded by tmux.conf) scans ~/.tmux/plugins and sources monokai.tmux.
  tmux-monokai-pro = pkgs.fetchFromGitHub {
    owner = "maxpetretta";
    repo = "tmux-monokai-pro";
    rev = "69e378e955ccd9afcb8ad1aa4011f71c80b892d9"; # 2026-02-18
    hash = "sha256-LlABLru2ODFq8dt6nqPT25lANxe4AAGK1wCqh8F6huM=";
  };

  # Keyboard-driven selection kitten for kitty — also not in nixpkgs. herdr's
  # copy mode only recolors the foreground, which is invisible over already
  # white text, so selection is done on kitty's side instead.
  kitty-grab = pkgs.fetchFromGitHub {
    owner = "yurikhan";
    repo = "kitty_grab";
    rev = "969e363295b48f62fdcbf29987c77ac222109c41"; # 2025-09-29
    hash = "sha256-DamZpYkyVjxRKNtW5LTLX1OU47xgd/ayiimDorVSamE=";
  };
in
{
  # Home Manager =======================================================================================================
  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.11";
    username = "${vars.username}";
    homeDirectory = "/Users/${vars.username}";
    packages = with pkgs; [
      # claude-code
    ];

    sessionPath = [
      "$HOME/.local/bin"
    ];

    # tmux theme plugin, dropped where TPM already looks (~/.tmux/plugins).
    file.".tmux/plugins/tmux-monokai-pro".source = tmux-monokai-pro;

    # kitty has no plugin directory to scan, so the location is arbitrary and
    # kitty.conf names it explicitly. It must stay outside ~/.config/kitty,
    # which is a symlink into the dotfiles repo.
    file.".local/share/kitty_grab".source = kitty-grab;

    # Global agent instructions — AGENTS.md is the canonical cross-agent file,
    # CLAUDE.md a thin shim (@AGENTS.md import + Claude-only bits). Claude Code
    # does not read AGENTS.md natively, hence the shim. Out-of-store symlinks,
    # NOT store copies: edits in /etc/dotfiles (incl. via /memory) apply
    # instantly without a rebuild, while every switch still (re)creates the
    # links. Both live in ~/.claude/ so the relative @AGENTS.md import resolves
    # whether Claude reads it through the link or its target.
    file.".claude/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/AGENTS.md";
    file.".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/dotfiles/collection/agents/CLAUDE.md";

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
        #
        # Every tool carries an exact `==` version. This is load-bearing, not cosmetic:
        # `uv tool install` without a specifier treats an already-installed tool as
        # satisfying an unpinned requirement and no-ops, so an unpinned line can never
        # move a version — it silently ratifies whatever is on the machine, including
        # out-of-band `uv tool install` runs. A changed specifier is what makes uv
        # converge; once it matches, re-switches are a genuine no-op (no `--force`
        # needed, which would otherwise reinstall on every activation).
        # To upgrade: bump the version here, don't run `uv tool install` by hand.
        # graphify extras: TS/JS/JSON grammars are core, so only hcl (terraform) and sql
        # need declaring. Keep this list byte-identical to the CI extractor's — CI writes
        # graph.json and this CLI only reads it, so they are a pinned writer/reader pair
        # (frameleap: .graphify-version + docs/environment-setup.md). No LLM-backend extra
        # belongs here: naming happens in CI, and the read-only verbs need no key.
        # Deliberately NOT adding `leiden`: graspologic is marked `python_version < "3.13"`
        # and caps at <3.13 itself, so on our pinned 3.13 the extra resolves to zero
        # packages and silently changes nothing — clustering stays on the Louvain fallback.
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'graphifyy[gemini,sql,terraform]==0.9.30'
        # headroom extras: `proxy` drives `wrap`/`proxy` (and already pulls the MCP deps,
        # so `mcp` is redundant today — kept to declare intent if upstream ever decouples).
        # `code` adds tree-sitter for AST-based compression, which the proxy enables by
        # default once the grammars exist (HEADROOM_CODE_AWARE_ENABLED defaults to 1); it
        # only handles c/cpp/csharp/go/java/js/python/rust/ts, which covers our TS/JS work.
        # Costs 2 MB to download but ~351 MB on disk, and can't be cherry-picked — the
        # compressor imports tree_sitter_language_pack directly. No model downloads.
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'headroom-ai[proxy,mcp,code]==0.33.0'
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python 3.13 'markitdown[pdf, docx, pptx, xlsx, xls]==0.1.6'
      )
    '';
    # Claude Code — official native installer, deliberately NOT pkgs.claude-code.
    # Two reasons nix can't own this one:
    #   1. Nix can't fetch "latest" purely — sandboxed builds need a fixed output hash.
    #   2. The native install self-updates in the background into
    #      ~/.local/share/claude/versions/, which a read-only store can't do.
    # So this is a bootstrap only: install once on a fresh machine, then Claude Code's own
    # auto-updater owns the version. The existence guard keeps re-switches from re-downloading.
    # Do NOT add home.file.".local/bin/claude" — that path is the launcher the installer manages.
    activation.claudeCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/.local/bin/claude" ]; then
        # Official install command, store-pinned. Append `stable` after the final `bash` to
        # track the ~1-week-old channel instead of every release.
        $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash
      fi
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
