-- plugin to improve code completion, lsp, linting, and treesitter
return {
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
	    "lukas-reineke/lsp-format.nvim",
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

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

          require("lsp-format").on_attach(client, args.buf)

          if client:supports_method(
                vim.lsp.protocol.Methods.textDocument_inlineCompletion,
                args.buf
              ) then
            vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
          end
        end,
      })

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
  }
}
