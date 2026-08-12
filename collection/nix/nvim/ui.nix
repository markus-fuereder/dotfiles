{ ... }:
{
  programs.nixvim = {
    # PICKER ===========================================================================================================
    # fzf-native is a compiled C sorter; nix builds it here, so unlike the upstream install there is
    # no `make` step to remember. ui-select routes vim.ui.select (LSP code actions, etc.) through
    # telescope so those pickers match everything else.
    plugins.telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
        ui-select.enable = true;
      };
      settings.defaults = {
        layout_strategy = "horizontal";
        layout_config.prompt_position = "top";
        sorting_strategy = "ascending";
        # node_modules and .next dominate every result list in a JS project otherwise.
        file_ignore_patterns = [
          "^.git/"
          "node_modules/"
          "^.next/"
          "^dist/"
          "^build/"
          "^.angular/"
          "package%-lock.json"
          "yarn.lock"
          "pnpm%-lock.yaml"
        ];
      };
      keymaps = {
        "<leader>ff" = { action = "find_files"; options.desc = "Find files"; };
        "<leader>fg" = { action = "live_grep"; options.desc = "Live grep"; };
        "<leader>fb" = { action = "buffers"; options.desc = "Find buffers"; };
        "<leader>fh" = { action = "help_tags"; options.desc = "Find help"; };
        "<leader>fr" = { action = "oldfiles"; options.desc = "Recent files"; };
        "<leader>fw" = { action = "grep_string"; options.desc = "Grep word under cursor"; };
        "<leader>fs" = { action = "lsp_document_symbols"; options.desc = "Document symbols"; };
        "<leader>fS" = { action = "lsp_dynamic_workspace_symbols"; options.desc = "Workspace symbols"; };
        "<leader>fd" = { action = "diagnostics"; options.desc = "Diagnostics"; };
        "<leader>fk" = { action = "keymaps"; options.desc = "Find keymaps"; };
        "<leader><leader>" = { action = "git_files"; options.desc = "Find git files"; };
      };
    };

    # EXPLORER =========================================================================================================
    # neo-tree, the closest analogue to the VS Code sidebar this replaces.
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file.enabled = true; # ............ Sidebar tracks the buffer you're actually looking at
          use_libuv_file_watcher = true; # ......... Pick up files created outside nvim (yarn add, nest generate)
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = true;
            hide_by_name = [ "node_modules" ".next" ".angular" "dist" ];
          };
        };
      };
    };

    # STATUSLINE =======================================================================================================
    plugins.lualine = {
      enable = true;
      settings.options = {
        theme = "auto"; # ............................................ Picks up monokai-pro from the colorscheme
        globalstatus = true; # ................... One statusline for the whole window, not one per split
      };
    };

    # GIT ==============================================================================================================
    # Signs and hunk navigation in-editor; lazygit (already in systemPackages) stays the tool for
    # anything more involved than staging a hunk.
    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = false; # ....... Off by default; toggled on demand with <leader>gb below
    };

    # DIAGNOSTICS LIST =================================================================================================
    plugins.trouble = {
      enable = true;
      settings.focus = true;
    };

    # DISCOVERABILITY ==================================================================================================
    # The load-bearing plugin for a config this size: press <leader> and it shows what's bound.
    plugins.which-key = {
      enable = true;
      settings.spec = [
        { __unkeyed-1 = "<leader>f"; group = "Find"; }
        { __unkeyed-1 = "<leader>c"; group = "Code"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; }
        { __unkeyed-1 = "<leader>a"; group = "AI / Claude"; }
        { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
        { __unkeyed-1 = "<leader>x"; group = "Diagnostics"; }
      ];
    };

    plugins.todo-comments.enable = true;
    plugins.indent-blankline.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle file explorer";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics (workspace)";
      }
      {
        mode = "n";
        key = "<leader>xb";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Diagnostics (buffer)";
      }
      {
        mode = "n";
        key = "<leader>xs";
        action = "<cmd>Trouble symbols toggle<cr>";
        options.desc = "Symbol outline";
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>TodoTrouble<cr>";
        options.desc = "TODO comments";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns toggle_current_line_blame<cr>";
        options.desc = "Toggle line blame";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview hunk";
      }
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns next_hunk<cr>";
        options.desc = "Next hunk";
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns prev_hunk<cr>";
        options.desc = "Previous hunk";
      }
    ];
  };
}
