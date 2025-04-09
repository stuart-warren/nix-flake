{ config, pkgs, ... }:

let helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    enable = true;
    vimAlias = true;
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      termguicolors = true;
      hlsearch = false;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      swapfile = false;
      signcolumn = "yes";
      updatetime = 250;
      timeout = true;
      timeoutlen = 300;
      list = true;
      listchars = {
        tab = "<->";
        extends = "⟩";
        precedes = "⟨";
        eol = "↵";
      }; 
    }; # end opts

    match = { ExtraWhitespace = "\\s\\+$"; };
    highlight = { ExtraWhitespace = { bg = "#ff0000"; }; };
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };
    extraPlugins = with pkgs.vimPlugins; [
      cloak-nvim
      tint-nvim
      vim-nix
      nvim-fzf
      nvim-fzf-commands
      fugitive-gitlab-vim
      vim-sleuth
      aerial-nvim
      yanky-nvim
    ];
    extraConfigLua = ''
      require("tint").setup({
        tint = -60,
      })
      require("cloak").setup({
        enabled = true,
        cloak_character = "*",
        patterns = {
          {
            file_pattern = {
              ".env*",
              "nix-creds.conf",
              ".netrc",
              "config.json",
            },
            cloak_pattern = {
              "(ghp_)%g+",
              "(PAT:)%g+",
              "(KEY=)%g+",
              "(TOKEN=)%g+",
              "(password )%g+",
              "(auth\": )\"%g+\"",
            },
            replace = "%1",
          },
        },
      })
      require("yanky").setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      })
    '';
    globals = {
      mapleader = " ";
      maylocalleader = " ";
    };
    plugins = {
      nvim-bqf = { enable = true; };
      noice = { enable = true; };
      which-key = { enable = true; };
      fugitive = { enable = true; };
      gitsigns = { enable = true; };
      web-devicons = { enable = true; };
      # cursorline = { enable = true; };
      lualine = {
        enable = true;
        settings.options = {
	  sectionSeparators = {
	    left = "";
            right = "";
          };
          componentSeparators = {
            left = "|";
            right = "|";
	  };
        };
      };
      copilot-lua = {
        enable = true;
        panel.enabled = false;
        suggestion.enabled = false;
      };
      inc-rename = { enable = true; };
      indent-blankline = { enable = true; };
      comment = { enable = true; };
      telescope = { enable = true; };
      treesitter = { enable = true; };
      treesitter-context = { enable = true; };
      treesitter-refactor = { enable = true; };
      treesitter-textobjects = { enable = true; };
      trouble = { enable = true; };
      tmux-navigator = { enable = true; };
      todo-comments = { enable = true; };
      oil = {
        enable = true;
        settings.view_options.show_hidden = true;
      };
      neogit = { enable = true; };
      flash = { enable = true; };
      dap = { enable = true; };
      # obsidian = {
      #   enable = true;
      #   dir = "~/Documents/ObsidianWork/Work/";
      #   dailyNotes = {
      #     dateFormat = "%Y/%m/%Y-%m-%d";
      #     folder = "Journal";
      #     template = "Daily";
      #   };
      #   templates = { subdir = "Templates"; };
      # };
      nix = { enable = true; };
      project-nvim = { enable = true; };
      # yanky = { enable = true; };
      none-ls = {
        enable = true;
        enableLspFormat = true;
        sources = {
          code_actions = {
            gitsigns.enable = true;
            statix.enable = true;
          };
          formatting = {
            nixfmt.enable = true;
            nixpkgs_fmt.enable = true;
          };
        };
      };
      # friendly-snippets = { enable = true; };
      luasnip = {
        enable = true;
        fromVscode = [{ }];
      };
      lsp-format = { enable = true; };
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          cssls.enable = true;
          # dockerls.enable = true;
          gopls.enable = true;
          lua_ls.enable = true;
          # marksman.enable = true;
          nixd.enable = true;
          nil_ls.enable = true;
          pyright.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          terraformls.enable = true;
          yamlls = {
            enable = true;
            # consider handling extra schemas if needed/customtags
          };
        };
        keymaps = {
          lspBuf = {
            K = "hover";
            #     gD = "references";
            gd = "definition";
            #     gi = "implementation";
            #     gt = "type_definition";
          };
          silent = true;
        };
      };
      cmp-nvim-lsp = { enable = true; };
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          completion.completeopt = "menu,menuone,noinsert,noselect";
          sources = [
            { name = "copilot"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "yanky"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          # preselect = "cmp.PreselectMode.None";
          preselect = "None";
          mapping = {
            "<C-p>" =
              "cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Insert})";
            "<C-n>" =
              "cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Insert})";
            "<C-c>" = "cmp.mapping.close()";
            "<C-y>" = "cmp.mapping.confirm({ select = false })";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-l>" =
              "cmp.mapping(function() if require('luasnip').expand_or_locally_jumpable() then require('luasnip').expand_or_jump() end end, { 'i', 's'})";
            "<C-h>" =
              "cmp.mapping(function() if require('luasnip').locally_jumpable(-1) then require('luasnip').jump(-1) end end, { 'i', 's'})";
          };
          snippet = {
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
        };
        # mappingPresets = [ "insert" "cmdline" ];
      };
    };
    keymaps = [
      {
        mode = [ "n" ];
        key = "-";
        action = "<Cmd>Oil<cr>";
        options.desc = "Open parent dir in Oil";
      }
      {
        mode = [ "n" "v" ];
        key = "<Space>";
        action = "<Nop>";
        options = {
          silent = true;
          desc = "";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>gg";
        action = "<Cmd>Neogit<cr>";
        options.desc = "open neogit";
      }
      {
        mode = [ "n" ];
        key = "<leader>bb";
        action = "<Cmd>Telescope buffers<cr>";
        options.desc = "open buffer list";
      }
      {
        mode = [ "v" ];
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "move line(s) down";
      }
      {
        mode = [ "v" ];
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "move line(s) up";
      }
      {
        mode = [ "v" ];
        key = ">";
        action = ">gv";
        options.desc = "indent keep selection";
      }
      {
        mode = [ "v" ];
        key = "<";
        action = "<gv";
        options.desc = "dedent keep selection";
      }
      {
        mode = [ "n" ];
        key = "J";
        action = "mzJ`z";
        options.desc = "join line without move cursor";
      }
      {
        mode = [ "n" ];
        key = "<C-d>";
        action = "<C-d>zz";
        options.desc = "scroll page down without move cursor";
      }
      {
        mode = [ "n" ];
        key = "<C-u>";
        action = "<C-u>zz";
        options.desc = "scroll page up without move cursor";
      }
      {
        mode = [ "n" ];
        key = "n";
        action = "nzzzv";
        options.desc = "next search without move cursor";
      }
      {
        mode = [ "n" ];
        key = "N";
        action = "Nzzzv";
        options.desc = "previous search without move cursor";
      }
      {
        mode = [ "i" ];
        key = "<C-c>";
        action = "<Esc>";
        options.desc = "alt esc";
      }
      {
        mode = [ "n" ];
        key = "Q";
        action = "<Nop>";
        options.desc = "disable Q";
      }
      {
        mode = [ "n" ];
        key = "<A-k>";
        action = "<cmd>cnext<CR>zz";
        options.desc = "prev qf without move cursor";
      }
      {
        mode = [ "n" ];
        key = "<A-j>";
        action = "<cmd>cprev<CR>zz";
        options.desc = "next qf without move cursor";
      }
      {
        mode = [ "n" ];
        key = "<leader>|";
        action = "<cmd>vsplit<CR>";
        options.desc = "split horizontal";
      }
      {
        mode = [ "n" ];
        key = "<leader>_";
        action = "<cmd>split<CR>";
        options.desc = "split vertical";
      }
      {
        mode = [ "n" ];
        key = "<leader>xx";
        action = helpers.mkRaw "function() require('trouble').toggle() end";
        options.desc = "toggle trouble";
      }
      {
        mode = [ "n" ];
        key = "<leader>xw";
        action = helpers.mkRaw
          "function() require('trouble').toggle('workspace_diagnostics') end";
        options.desc = "workspace diagnostics";
      }
      {
        mode = [ "n" ];
        key = "<leader>xd";
        action = helpers.mkRaw
          "function() require('trouble').toggle('document_diagnostics') end";
        options.desc = "document diagnostics";
      }
      {
        mode = [ "n" ];
        key = "<leader>xq";
        action =
          helpers.mkRaw "function() require('trouble').toggle('quickfix') end";
        options.desc = "quickfix";
      }
      {
        mode = [ "n" ];
        key = "<leader>xl";
        action =
          helpers.mkRaw "function() require('trouble').toggle('loclist') end";
        options.desc = "loclist";
      }
      {
        mode = [ "n" ];
        key = "gR";
        action = helpers.mkRaw
          "function() require('trouble').toggle('lsp_references') end";
        options.desc = "lsp references";
      }
      {
        mode = [ "n" ];
        key = "gI";
        action = helpers.mkRaw
          "function() require('trouble').toggle('lsp_implementations') end";
        options.desc = "lsp implementations";
      }
      {
        mode = [ "n" "x" ];
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        options.desc = "yanky put after";
      }
      {
        mode = [ "n" "x" ];
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        options.desc = "yanky put before";
      }
      {
        mode = [ "n" "x" ];
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        options.desc = "yanky put after";
      }
      {
        mode = [ "n" "x" ];
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        options.desc = "yanky put before";
      }
      {
        mode = [ "n" ];
        key = "<C-p>";
        action = "<Plug>(YankyPreviousEntry)";
        options.desc = "yanky previous entry";
      }
      {
        mode = [ "n" ];
        key = "<C-n>";
        action = "<Plug>(YankyNextEntry)";
        options.desc = "yanky next entry";
      }
    ];
  };
}
