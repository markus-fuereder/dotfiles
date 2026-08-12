{ ... }:
{
  # NEOVIM =============================================================================================================
  # Declarative Neovim via nixvim. Split by concern so no single file grows past easy review:
  #   lsp.nix     — language servers
  #   editing.nix — treesitter, completion, formatting
  #   ui.nix      — picker, explorer, statusline, git signs
  #   claude.nix  — claudecode.nvim
  imports = [
    ./lsp.nix
    ./editing.nix
    ./ui.nix
    ./claude.nix
  ];

  programs.nixvim = {
    enable = true;

    # `viAlias`/`vimAlias` are deliberately NOT set: pkgs.vim is still in
    # environment.systemPackages as an escape hatch for when this config breaks, and the aliases
    # would collide with it in PATH. The shell alias in config.nix covers the everyday case.

    # Leader -----------------------------------------------------------------------------------------------------------
    # Must be set before plugins register their keymaps, which nixvim handles by emitting globals first.
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Clipboard --------------------------------------------------------------------------------------------------------
    # macOS ships pbcopy/pbpaste, so no clipboard provider package is needed.
    clipboard.register = "unnamedplus";

    # Options ----------------------------------------------------------------------------------------------------------
    opts = {
      number = true;
      relativenumber = true;
      signcolumn = "yes"; # ..................... Reserve the gutter so diagnostics don't shift text as they appear
      cursorline = true;

      # 2-space soft tabs: matches prettier's default for the TS/JS/JSON/YAML/SCSS work this is for.
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      smartindent = true;

      # Search: case-insensitive until you type a capital.
      ignorecase = true;
      smartcase = true;
      inccommand = "split"; # ................................. Live preview for :s/… in a split before committing

      # Splits open where the eye expects them.
      splitright = true;
      splitbelow = true;

      scrolloff = 8;
      undofile = true; # ................................................. Persist undo history across nvim restarts
      updatetime = 250; # ................................ Faster CursorHold, so LSP hover/diagnostics feel prompt
      timeoutlen = 400; # ........................................................ How long which-key waits to popup
      termguicolors = true;
      wrap = false;
      confirm = true; # ................................ Prompt instead of erroring when quitting an unsaved buffer
    };

    # Colorscheme ------------------------------------------------------------------------------------------------------
    # Monokai Pro, `ristretto` filter — the one that matches collection/kitty/theme.conf exactly:
    # text #fff1f3, accent1 #fd6883, accent3 #f9cc6c, accent4 #adda78, dimmed5 #403838, dimmed3 #72696a.
    # (Not `spectrum`, whose accents are #fc618d / #fce566 / #7bd88f, and not `pro`, which is what the
    # tmux-monokai-pro plugin hardcodes — tmux.conf now overrides those to ristretto to match.)
    #
    # transparent_background: kitty deliberately paints #111111 rather than ristretto's own #2c2525
    # (see the comment in theme.conf), so painting no background is what makes the editor area blend
    # into the terminal instead of sitting on a lighter, warmer rectangle. Trade-off: floats, the
    # neo-tree sidebar and the completion menu lose their darker shading and rely on borders instead.
    colorschemes.monokai-pro = {
      enable = true;
      settings = {
        filter = "ristretto";
        transparent_background = true;
        terminal_colors = true;
        styles = {
          comment = { italic = true; };
          keyword = { italic = true; };
        };
      };
    };

    # Keymaps ----------------------------------------------------------------------------------------------------------
    # Plugin-specific maps live next to their plugin; only editor-general ones are here.
    keymaps = [
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>write<cr>";
        options.desc = "Write buffer";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>quit<cr>";
        options.desc = "Quit window";
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<cr>";
        options.desc = "Clear search highlight";
      }

      # Window navigation without the <C-w> prefix.
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Window left"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Window down"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Window up"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Window right"; }

      # Buffers.
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<cr>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<cr>"; options.desc = "Delete buffer"; }

      # Keep the selection when re-indenting, so you can dedent repeatedly.
      { mode = "v"; key = "<"; action = "<gv"; options.desc = "Dedent selection"; }
      { mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent selection"; }

      # Escape out of the Claude / lazygit terminal splits without reaching for <C-\><C-n>.
      { mode = "t"; key = "<C-x>"; action = "<C-\\><C-n>"; options.desc = "Leave terminal mode"; }
    ];
  };
}
