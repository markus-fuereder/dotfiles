{ ... }:
{
  programs.nixvim = {
    # LSP ==============================================================================================================
    # This uses nixvim's top-level `lsp` module, which drives Neovim's native `vim.lsp.config` /
    # `vim.lsp.enable` (nvim 0.11+) rather than the older `plugins.lsp` wrapper.
    #
    # `plugins.lspconfig` is still enabled, but NOT for its setup calls: nvim-lspconfig ships an
    # `lsp/<server>.lua` file per server containing the upstream defaults (cmd, filetypes,
    # root_markers). Putting it on the runtimepath lets vim.lsp.config pick those up, so each
    # server below only needs to declare what differs from upstream.
    plugins.lspconfig.enable = true;

    # JSON/YAML schema catalogue, consumed by jsonls and yamlls below.
    plugins.schemastore = {
      enable = true;
      json.enable = true;
      yaml.enable = true;
    };

    lsp = {
      # Keymaps applied on-attach, so they exist only in buffers that actually have a server.
      keymaps = [
        { key = "gd"; lspBufAction = "definition"; options.desc = "Goto definition"; }
        { key = "gD"; lspBufAction = "declaration"; options.desc = "Goto declaration"; }
        { key = "gr"; lspBufAction = "references"; options.desc = "Goto references"; }
        { key = "gI"; lspBufAction = "implementation"; options.desc = "Goto implementation"; }
        { key = "gy"; lspBufAction = "type_definition"; options.desc = "Goto type definition"; }
        { key = "K"; lspBufAction = "hover"; options.desc = "Hover documentation"; }
        { key = "<C-k>"; mode = "i"; lspBufAction = "signature_help"; options.desc = "Signature help"; }
        { key = "<leader>rn"; lspBufAction = "rename"; options.desc = "Rename symbol"; }
        { key = "<leader>ca"; mode = [ "n" "v" ]; lspBufAction = "code_action"; options.desc = "Code action"; }
      ];

      servers = {
        # TypeScript / JavaScript ------------------------------------------------------------------------------------
        # vtsls over ts_ls: it exposes the same commands the VS Code TS extension does (organise
        # imports, "go to source definition", file-move refactors), which is what Next.js and
        # NestJS work leans on. Covers plain .ts for NestJS and .tsx for Next.js alike.
        #
        # NOTE: vtsls bundles its own TypeScript. In a repo pinned to a different TS major, set
        # `settings.typescript.tsdk` to that project's node_modules/typescript/lib.
        vtsls = {
          enable = true;
          config.settings = {
            typescript = {
              # Inlay hints are off by default; parameter names and return types earn their
              # screen space in a NestJS codebase full of injected dependencies.
              inlayHints = {
                parameterNames.enabled = "literals";
                parameterTypes.enabled = true;
                variableTypes.enabled = false;
                propertyDeclarationTypes.enabled = true;
                functionLikeReturnTypes.enabled = true;
                enumMemberValues.enabled = true;
              };
              # Prefer `import type { X }` where the import is only used in type position.
              preferences.preferTypeOnlyAutoImports = true;
              updateImportsOnFileMove.enabled = "always";
            };
            javascript.inlayHints.parameterNames.enabled = "literals";
          };
        };

        # Angular ---------------------------------------------------------------------------------------------------
        # Gated on angular.json via root_markers so it attaches ONLY in Angular workspaces and
        # never races vtsls inside a Next.js repo. filetypes covers both the component .ts and
        # its .html template, which is where the language service earns its keep.
        #
        # NOTE: nixpkgs ships angular-language-server 22.x. Against a project several majors
        # older the language service can misbehave; the fix is `package = null` plus a `config.cmd`
        # pointing at that project's own node_modules/.bin/ngserver.
        angularls = {
          enable = true;
          config = {
            root_markers = [ "angular.json" ];
            filetypes = [ "typescript" "html" "htmlangular" ];
          };
        };

        # ESLint ----------------------------------------------------------------------------------------------------
        # Runs as a language server rather than through nvim-lint, so you get code actions and
        # :EslintFixAll, not just diagnostics. This is why no separate linter plugin is configured.
        eslint = {
          enable = true;
          config.settings = {
            # Respect the repo's own config; don't invent rules when a project has none.
            useFlatConfig = true;
            workingDirectories = [ { mode = "auto"; } ];
          };
        };

        # Tailwind / shadcn -----------------------------------------------------------------------------------------
        # shadcn/ui puts classes inside cn(), cva() and tv() helpers rather than a bare
        # class="…" attribute. Without these regexes the server sees no class context there and
        # completion silently does nothing — the single most common "tailwind LSP is broken"
        # complaint on shadcn projects.
        tailwindcss = {
          enable = true;
          config = {
            filetypes = [
              "html"
              "htmlangular"
              "css"
              "scss"
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
              "vue"
              "svelte"
            ];
            settings.tailwindCSS = {
              classAttributes = [ "class" "className" "ngClass" "class:list" ];
              experimental.classRegex = [
                # cva(…) / cx(…) / tv(…) — match the whole call, then each quoted string in it.
                [ "cva\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
                [ "cx\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
                [ "tv\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
                # cn(…) / clsx(…) / twMerge(…) — shadcn's own helper and its dependencies.
                [ "cn\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
                [ "clsx\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
                [ "twMerge\\(([^)]*)\\)" "[\"'`]([^\"'`]*).*?[\"'`]" ]
              ];
            };
          };
        };

        # CSS / SCSS ------------------------------------------------------------------------------------------------
        # unknownAtRules = ignore is required for Tailwind: @tailwind, @apply and @screen are not
        # in the CSS spec, so vscode-css-language-server flags every one of them otherwise.
        cssls = {
          enable = true;
          config.settings = {
            css.lint.unknownAtRules = "ignore";
            scss.lint.unknownAtRules = "ignore";
            less.lint.unknownAtRules = "ignore";
          };
        };

        # Markup ----------------------------------------------------------------------------------------------------
        html.enable = true;
        # Emmet for JSX/HTML abbreviation expansion (div.foo>ul>li*3).
        emmet_language_server = {
          enable = true;
          config.filetypes = [
            "html"
            "htmlangular"
            "css"
            "scss"
            "javascriptreact"
            "typescriptreact"
          ];
        };

        # Data formats ----------------------------------------------------------------------------------------------
        # Schemas come from plugins.schemastore above, which is what gives completion and
        # validation in package.json, tsconfig.json, nest-cli.json and GitHub Actions workflows.
        # No settings needed here: the schemastore module above already defines
        # `lsp.servers.{jsonls,yamlls}.config.settings.*` — the schema list, jsonls' validate.enable,
        # and disabling yamlls' built-in schema store so schemastore.nvim is the only source.
        # Re-declaring any of it produces a conflicting-definition error rather than merging.
        jsonls.enable = true;
        yamlls.enable = true;

        # Markdown --------------------------------------------------------------------------------------------------
        marksman.enable = true;

        # Nix / Lua -------------------------------------------------------------------------------------------------
        # lua_ls is here so editing THIS config (and any raw-lua snippets in it) is checked too.
        lua_ls = {
          enable = true;
          config.settings.Lua = {
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
            telemetry.enable = false;
          };
        };
        nil_ls.enable = true;
      };
    };

    # Diagnostics ------------------------------------------------------------------------------------------------------
    diagnostic.settings = {
      virtual_text = true;
      underline = true;
      severity_sort = true;
      update_in_insert = false; # ................ Don't churn diagnostics mid-keystroke; wait until you leave insert
    };
  };
}
