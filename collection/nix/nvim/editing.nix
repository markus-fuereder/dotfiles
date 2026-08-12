{ config, ... }:
{
  programs.nixvim = {
    # TREESITTER =======================================================================================================
    # Grammars are pinned to an explicit list rather than nixvim's all-grammars default: the
    # default builds every parser nvim-treesitter knows about, which is a lot of compile time and
    # closure for languages this machine will never open.
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      # There is no separate `jsonc` grammar, but tsconfig.json / nest-cli.json get the jsonc
      # filetype. Point that filetype at the json parser so those files still highlight.
      languageRegister.json = [ "jsonc" ];
      grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
        # TypeScript / JavaScript ---------------------------------------------------------------------------------
        typescript
        tsx
        javascript
        jsdoc
        # Angular templates and Next.js markup ---------------------------------------------------------------------
        angular
        html
        css
        scss
        # Data formats --------------------------------------------------------------------------------------------
        json
        json5
        yaml
        toml
        graphql
        prisma
        # Prose ---------------------------------------------------------------------------------------------------
        markdown
        markdown_inline
        # This config, and the shells around it -------------------------------------------------------------------
        nix
        lua
        luadoc
        bash
        dockerfile
        # Plumbing ------------------------------------------------------------------------------------------------
        diff
        git_config
        gitcommit
        gitignore
        regex
        vim
        vimdoc
        query
      ];
    };

    # Treesitter-aware auto-closing of JSX/HTML tags — types the </div> for you.
    plugins.ts-autotag = {
      enable = true;
      settings.opts.enable_close_on_slash = true;
    };

    # COMPLETION =======================================================================================================
    # blink.cmp rather than nvim-cmp: it needs no companion source plugins for the LSP/path/snippet
    # sources used here, so the Nix surface is a single module instead of six.
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default"; # ......... <C-y> accepts, <C-n>/<C-p> cycle, <C-space> opens — no <Tab> hijacking
        appearance.nerd_font_variant = "mono";
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          # Ghost text preview of the selected item, inline in the buffer.
          ghost_text.enabled = true;
        };
        sources.default = [ "lsp" "path" "snippets" "buffer" ];
        snippets.preset = "luasnip";
        signature.enabled = true;
      };
    };

    plugins.luasnip.enable = true;
    plugins.friendly-snippets.enable = true;

    # FORMATTING =======================================================================================================
    # conform.nvim with prettierd, which keeps a daemon warm so format-on-save stays imperceptible
    # instead of paying Node's startup cost on every write. prettierd reads the project's own
    # .prettierrc, so per-repo style is respected.
    #
    # `lsp_format = "fallback"` means: use the formatter below when one is configured for the
    # filetype, otherwise fall back to whatever the attached language server offers.
    plugins.conform-nvim = {
      enable = true;

      # autoInstall defaults to OFF. Without it, conform is configured to call prettierd/stylua but
      # neither is on nvim's PATH, so format-on-save silently degrades to LSP formatting instead of
      # erroring — exactly the kind of quiet wrong behaviour that's hard to notice.
      autoInstall = {
        enable = true;
        # trim_whitespace is one of conform's built-in Lua formatters, not a binary, so there is no
        # package to resolve. Left unset, autoInstall throws "a package ... could not be found".
        overrides.trim_whitespace = null;
      };

      settings = {
        format_on_save = {
          timeout_ms = 3000; # ....... Generous: prettierd's first invocation in a session spawns the daemon
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          javascript = [ "prettierd" ];
          javascriptreact = [ "prettierd" ];
          typescript = [ "prettierd" ];
          typescriptreact = [ "prettierd" ];
          json = [ "prettierd" ];
          jsonc = [ "prettierd" ];
          yaml = [ "prettierd" ];
          css = [ "prettierd" ];
          scss = [ "prettierd" ];
          less = [ "prettierd" ];
          html = [ "prettierd" ];
          htmlangular = [ "prettierd" ];
          graphql = [ "prettierd" ];
          markdown = [ "prettierd" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          sh = [ "shfmt" ];
          # Trim trailing whitespace in anything without a real formatter.
          "_" = [ "trim_whitespace" ];
        };
      };
    };

    # Manual format, for buffers where you don't want to wait for a save.
    keymaps = [
      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format({ async = true, lsp_format = 'fallback' })<cr>";
        options.desc = "Format buffer";
      }
      {
        mode = "n";
        key = "<leader>ce";
        action = "<cmd>EslintFixAll<cr>";
        options.desc = "ESLint fix all";
      }
    ];

    # EDITING QUALITY OF LIFE ==========================================================================================
    plugins.nvim-autopairs.enable = true;

    # Inline latest/wanted versions next to dependencies in package.json.
    plugins.package-info = {
      enable = true;
      settings.hide_up_to_date = true;
    };

    # Renders #fff / rgb() / Tailwind colour names as their actual colour — earns its place in
    # SCSS and in Tailwind config files.
    plugins.colorizer = {
      enable = true;
      settings = {
        filetypes = [ "css" "scss" "html" "javascriptreact" "typescriptreact" "typescript" "lua" ];
        user_default_options = {
          tailwind = true;
          css = true;
          names = false; # ................. Don't colourise every English word that happens to be a CSS colour name
        };
      };
    };
  };
}
