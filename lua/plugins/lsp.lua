-- plugin to improve code completion, lsp, linting, and treesitter
return {
	{
		"mason-org/mason-lspconfig.nvim",
		enabled = not vim.g.vscode,
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"neovim/nvim-lspconfig",
				cmd = { "LspInfo", "LspInstall", "LspUninstall" },
				enabled = not vim.g.vscode,
			},
			{
				"saghen/blink.cmp",
				enabled = not vim.g.vscode,
				event = "InsertEnter",
			},
		},
		keys = {
			{
				"<leader>ff",
				function()
					vim.lsp.buf.format()
				end,
				{ desc = "Format File" },
			},
		},
		opts = {
			ensure_installed = {},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = require("blink.cmp").get_lsp_capabilities(),
					})
				end,
			},
		},
	},
	{
		"mason-org/mason.nvim",
		enabled = not vim.g.vscode,
		cmd = { "MasonInstall", "MasonUninstall", "Mason" },
		opts = {},
	},
	{
		"folke/lazydev.nvim",
		enabled = not vim.g.vscode,
		ft = "lua",
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
			keymap = { preset = "enter" },
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
		"zbirenbaum/copilot.lua",
		enabled = not vim.g.vscode,
		cmd = "Copilot",
		event = "InsertEnter",
		dependencies = {
			"copilotlsp-nvim/copilot-lsp",
		},
		keys = {
			{
				"<Tab>",
				function()
					local suggestion = require("copilot.suggestion")
					if suggestion.is_visible() then
						suggestion.accept()
					else
						return "<Tab>"
					end
				end,
				mode = "i",
				expr = true,
				replace_keycodes = true,
			},
		},
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = false,
				},
			},
			-- nes = {
			-- 	enabled = true,
			-- 	keymap = {
			-- 		accept_and_goto = "<leader>p",
			-- 		accept = false,
			-- 		dismiss = "<Esc>",
			-- 	},
			-- },
		},
	},
}
