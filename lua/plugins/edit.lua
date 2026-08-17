-- plugins that enhance the editing experience
return {
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
}
