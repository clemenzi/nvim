vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.expandtab = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.laststatus = 3

vim.o.clipboard = "unnamedplus"

vim.o.shortmess = vim.o.shortmess .. "Wc"

vim.o.statusline = " %{mode()}  %f %m%r%= %y  %l:%c  %p%% "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- {
    -- 	"folke/flash.nvim",
    -- 	---@type Flash.Config
    -- 	opts = {},
    -- 	keys = {
    -- 		{
    -- 			"s",
    -- 			mode = { "n", "x", "o" },
    -- 			function()
    -- 				require("flash").jump()
    -- 			end,
    -- 			desc = "Flash",
    -- 		},
    -- 		{
    -- 			"S",
    -- 			mode = { "n", "x", "o" },
    -- 			function()
    -- 				require("flash").treesitter()
    -- 			end,
    -- 			desc = "Flash Treesitter",
    -- 		},
    -- 		{
    -- 			"r",
    -- 			mode = "o",
    -- 			function()
    -- 				require("flash").remote()
    -- 			end,
    -- 			desc = "Remote Flash",
    -- 		},
    -- 		{
    -- 			"R",
    -- 			mode = { "o", "x" },
    -- 			function()
    -- 				require("flash").treesitter_search()
    -- 			end,
    -- 			desc = "Treesitter Search",
    -- 		},
    -- 		{
    -- 			"<c-s>",
    -- 			mode = { "c" },
    -- 			function()
    -- 				require("flash").toggle()
    -- 			end,
    -- 			desc = "Toggle Flash Search",
    -- 		},
    -- 	},
    -- },
    {
      "kylechui/nvim-surround",
      version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
      event = "InsertEnter",
      opts = {},
    },
    {
      "windwp/nvim-autopairs",
      enabled = not vim.g.vscode,
      event = "InsertEnter",
      opts = {},
    },
    {
      "kevinhwang91/nvim-ufo",
      event = "BufReadPost",
      dependencies = { "kevinhwang91/promise-async" },
      opts = {
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      },
      init = function()
        vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99 -- Keep folds open until explicitly closed.
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
      end,
      keys = {
        {
          "zR",
          function()
            require("ufo").openAllFolds()
          end,
          desc = "Open all folds",
        },
        {
          "zM",
          function()
            require("ufo").closeAllFolds()
          end,
          desc = "Close all folds",
        },
      },
    },
    {
      "mason-org/mason-lspconfig.nvim",
      enabled = not vim.g.vscode,
      -- Reading code should be instant. Start the expensive LSP stack only
      -- when the buffer is actually edited (or via one of its commands/keys).
      event = "InsertEnter",
      cmd = { "LspInfo", "LspInstall", "LspUninstall" },
      dependencies = {
        {
          "mason-org/mason.nvim",
          cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
          opts = {
            -- Avoid a registry network refresh while opening the first file.
            -- Use :MasonUpdate when a registry update is wanted.
            registry_cache = { refresh = false },
          },
        },
        "neovim/nvim-lspconfig",
        "saghen/blink.cmp",
        -- "lukas-reineke/lsp-format.nvim",
      },
      keys = {
        {
          "<leader>ff",
          function()
            vim.lsp.buf.format()
          end,
          desc = "Format File",
        },
      },
      opts = {
        ensure_installed = {},
      },
      config = function(_, opts)
        -- Configure capabilities once, before Mason enables installed servers.
        vim.lsp.config("*", {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        -- vim.api.nvim_create_autocmd("LspAttach", {
        --   callback = function(args)
        --     local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        --
        --     require("lsp-format").on_attach(client, args.buf)
        --
        --     if client:supports_method(
        --           vim.lsp.protocol.Methods.textDocument_inlineCompletion,
        --           args.buf
        --         ) then
        --       vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
        --     end
        --   end,
        -- })

        require("mason-lspconfig").setup(opts)
      end,
    },
    {
      "folke/lazydev.nvim",
      event = "InsertEnter",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    {
      "saghen/blink.cmp",
      enabled = not vim.g.vscode,
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
      event = "InsertEnter",
      version = "*",
      opts = {
        keymap = {
          preset = "super-tab",
          ["<CR>"] = { "select_and_accept", "fallback" },
          ["<Tab>"] = {
            "snippet_forward",
            function()
              if require("sidekick").nes_jump_or_apply() then
                return true
              end

              if vim.lsp.inline_completion.get() then
                return true
              end
            end,
            "fallback",
          },
        },
        signature = { enabled = true },
        sources = {
          default = { "lazydev", "lsp", "path", "snippets", "buffer" },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },
      },
    },
    {
      "folke/sidekick.nvim",
      opts = {},
      event = "InsertEnter",
      keys = {
        {
          "<tab>",
          function()
            -- if there is a next edit, jump to it, otherwise apply it if any
            if not require("sidekick").nes_jump_or_apply() then
              return "<Tab>" -- fallback to normal tab
            end
          end,
          expr = true,
          desc = "Goto/Apply Next Edit Suggestion",
        }
      },
    },
    {
      "stevearc/oil.nvim",
      enabled = not vim.g.vscode,
      cmd = "Oil",
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
        }
      },
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      init = function()
        -- Retain the original argument: Oil may turn the live buffer into
        -- oil:// before the deferred startup callback runs.
        local startup_directory = vim.fn.argv(0)

        local function load_oil_for_directory(path)
          if vim.fn.isdirectory(path) ~= 1 then
            return
          end
          require("lazy").load({ plugins = { "oil.nvim" } })
        end

        -- New directory buffers created after startup load Oil before their
        -- contents are read. The initial `nvim .` buffer is handled below.
        vim.api.nvim_create_autocmd("BufAdd", {
          group = vim.api.nvim_create_augroup("lazy-load-oil-directory", { clear = true }),
          callback = function(args)
            load_oil_for_directory(args.file)
          end,
        })

        -- Startup arguments are read before Lazy registers the BufAdd handler.
        -- Defer one precise hand-off for `nvim .`; ordinary file starts do no
        -- work here and never load Oil.
        if vim.fn.isdirectory(startup_directory) == 1 then
          vim.api.nvim_create_autocmd("VimEnter", {
            group = "lazy-load-oil-directory",
            once = true,
            callback = function()
              vim.schedule(function()
                load_oil_for_directory(startup_directory)
                vim.cmd.enew()
                require("oil").open(startup_directory)
              end)
            end,
          })
        end
      end,
      keys = {
        { "<space>e", "<cmd>Oil<cr>", desc = "Open parent directory" },
      },
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.1.9",
      cmd = "Telescope",
      enabled = not vim.g.vscode,
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = function()
        local themes = require("telescope.themes")
        return {
          defaults = themes.get_dropdown({
            winblend = 10,
            previewer = false,
            file_ignore_patterns = { "node_modules" },
          }),
        }
      end,
      keys = {
        { "<leader><leader>", "<cmd>Telescope buffers<cr>",                   desc = "Navigate between buffers" },
        { "<leader>?",        "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
        { "<leader>/",        "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Files" },
      },
    },
    {
      "Mofiqul/vscode.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("vscode")
      end,
    },
    -- {
    -- 	"f-person/auto-dark-mode.nvim",
    -- 	-- Keep the initial UI path limited to the colourscheme.  The detector
    -- 	-- starts the first time Neovim regains focus and then keeps polling.
    -- 	event = "FocusGained",
    -- 	opts = {
    -- 		set_dark_mode = function()
    -- 			vim.api.nvim_set_option_value("background", "dark", {})
    -- 			vim.cmd.colorscheme("vscode")
    --    	end,
    --    	set_light_mode = function()
    -- 			vim.api.nvim_set_option_value("background", "light", {})
    -- 			vim.cmd.colorscheme("vscode")
    --    	end,
    --    	update_interval = 3000,
    --    	fallback = "dark"
    --  	}
    -- },
    {
      "lukas-reineke/indent-blankline.nvim",
      enabled = not vim.g.vscode,
      main = "ibl",
      event = "BufReadPost",
      ---@module "ibl"
      ---@type ibl.config
      opts = {
        indent = { char = "▏" },
      },
    },
  },
  -- Every plugin must opt in to a loading trigger.  The colourscheme is the
  -- sole exception because it is part of the initial UI.
  defaults = { lazy = true },
  -- Avoid a background update check on every launch; use :Lazy check when
  -- updates are wanted.
  checker = { enabled = false },
})

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.o.number = false
    vim.o.relativenumber = false
    vim.cmd.startinsert()
  end,
})
