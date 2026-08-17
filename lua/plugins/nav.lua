-- plugins that improve the browsing and file management experience
return {
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
}
