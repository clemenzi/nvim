-- plugins that improve the browsing and file management experience
return {
	{
		"stevearc/oil.nvim",
		enabled = not vim.g.vscode,
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			skip_confirm_for_simple_edits = true,
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		lazy = false,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.1.9",
		cmd = "Telescope",
		enabled = not vim.g.vscode,
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			defaults = require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
				file_ignore_patterns = { "node_modules" },
			}),
		},
		keys = {
			{ "<leader><leader>", "<cmd>Telescope buffers<cr>",                   desc = "Navigate between buffers" },
			{ "<leader>?",        "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
			{ "<leader>/",        "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Files" },
		},
	},
}
