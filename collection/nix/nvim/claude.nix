{ ... }:
{
  programs.nixvim = {
    # CLAUDE ===========================================================================================================
    # coder/claudecode.nvim, not a plain terminal wrapper: it implements the same WebSocket IDE
    # protocol as the VS Code extension. That is what makes Claude aware of the current file and
    # visual selection, lets @-mentions be pushed from the editor, and renders its edits as native
    # nvim diffs you accept or reject — rather than Claude guessing at context from a bare shell.
    plugins.claudecode = {
      enable = true;
      settings = {
        # Nix cannot read the environment at build time, so $CLAUDE_CMD is resolved in Lua at
        # runtime instead. env.zsh sets it to the headroom wrapper (matching the `cl` alias), and
        # a bare `claude` is the fallback for shells that never sourced env.zsh.
        terminal_cmd.__raw = "vim.env.CLAUDE_CMD or 'claude'";

        terminal = {
          # "auto" prefers snacks.nvim, which this config deliberately doesn't install
          # (telescope + neo-tree were chosen over the snacks bundle). Be explicit so the
          # provider can't silently change if snacks ever arrives as someone's dependency.
          provider = "native";
          split_side = "right";
          split_width_percentage = 0.35;
          auto_close = false; # ......... Keep the session visible after Claude exits, so the transcript is readable
        };

        diff_opts = {
          layout = "vertical";
          open_in_new_tab = false;
        };

        focus_after_send = true;
      };
    };

    # The claudecode module declares a `claude-code` dependency at mkDefault priority, which would
    # put pkgs.claude-code on PATH. That directly contradicts the decision documented in home.nix:
    # Claude Code is installed by its official native installer into ~/.local/share/claude and
    # self-updates there, which a read-only store cannot do. A store copy on PATH would shadow
    # ~/.local/bin/claude and freeze the version at whatever nixpkgs last vendored.
    dependencies.claude-code.enable = false;

    keymaps = [
      {
        mode = "n";
        key = "<leader>ac";
        action = "<cmd>ClaudeCode<cr>";
        options.desc = "Toggle Claude";
      }
      {
        mode = "n";
        key = "<leader>af";
        action = "<cmd>ClaudeCodeFocus<cr>";
        options.desc = "Focus Claude";
      }
      {
        mode = "v";
        key = "<leader>as";
        action = "<cmd>ClaudeCodeSend<cr>";
        options.desc = "Send selection to Claude";
      }
      {
        mode = "n";
        key = "<leader>ab";
        action = "<cmd>ClaudeCodeAdd %<cr>";
        options.desc = "Add buffer as @-mention";
      }
      {
        mode = "n";
        key = "<leader>aa";
        action = "<cmd>ClaudeCodeDiffAccept<cr>";
        options.desc = "Accept Claude diff";
      }
      {
        mode = "n";
        key = "<leader>ad";
        action = "<cmd>ClaudeCodeDiffDeny<cr>";
        options.desc = "Reject Claude diff";
      }
    ];
  };
}
