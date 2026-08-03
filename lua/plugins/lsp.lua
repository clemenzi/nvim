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
		opts = {
			ensure_installed = { "copilot-language-server" },
		},
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
			keymap = {
				preset = "super-tab",
				["<Tab>"] = {
					function(cmp)
						if vim.b[vim.api.nvim_get_current_buf()].nes_state then
							cmp.hide()
							return require("copilot-lsp.nes").apply_pending_nes()
								and require("copilot-lsp.nes").walk_cursor_end_edit()
						end
						if cmp.snippet_active() then
							return cmp.accept()
						end
						return cmp.select_and_accept()
					end,
					"snippet_forward",
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
		"copilotlsp-nvim/copilot-lsp",
		enabled = not vim.g.vscode,
		event = "InsertEnter",
		keys = {
			{
				"<Tab>",
				function()
					if vim.b[vim.api.nvim_get_current_buf()].nes_state then
						local nes = require("copilot-lsp.nes")
						return nes.walk_cursor_start_edit()
							or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
					end
					return "<C-i>"
				end,
				mode = "n",
				expr = true,
				desc = "Accept Copilot NES suggestion",
			},
		},
		init = function()
			vim.g.copilot_nes_debounce = 500
		end,
		config = function()
			require("copilot-lsp").setup({
				nes = {
					move_count_threshold = 3,
				},
			})
			vim.lsp.enable("copilot_ls")
		end,
	},
}
