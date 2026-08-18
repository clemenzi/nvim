-- ============================================================================
-- Global editor options
-- ============================================================================

-- Use a single space as the prefix for user-defined mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show the current line number in full and all other lines relative to it.
vim.o.relativenumber = true
-- Highlight the line containing the cursor to make navigation easier.
vim.o.cursorline = true

-- Keep Tree-sitter folds open when a buffer is first displayed.
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = "1"
vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"

-- Tab Size
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Use one global statusline at the bottom of the editor.
vim.o.laststatus = 3

-- Integrate Neovim's clipboard with the operating system clipboard.
vim.o.clipboard = "unnamedplus"

-- Hide a few non-essential messages, such as the search-count feedback.
vim.o.shortmess = vim.o.shortmess .. "Wc"

-- Custom statusline: mode, file, modification/read-only flags, filetype,
-- cursor position, and percentage through the current buffer.
vim.o.statusline = " %{mode()}  %f %m%r%= %y  %l:%c  %p%% "

-- ============================================================================
-- Plugin manager bootstrap
-- ============================================================================

-- Install lazy.nvim on first launch, then add it to Neovim's runtime path.
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

-- ============================================================================
-- Plugin specifications
-- ============================================================================

require("lazy").setup({
	spec = {
		{
			"kylechui/nvim-surround",
			-- Add, change, and delete surrounding pairs such as quotes or brackets.
			version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
			event = "InsertEnter",
			opts = {},
		},
		{
			"windwp/nvim-autopairs",
			-- Automatically insert matching brackets and quotes while typing.
			enabled = not vim.g.vscode,
			event = "InsertEnter",
			opts = {},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			opts = true,
			event = "BufRead",
			init = function()
				vim.api.nvim_create_autocmd("FileType", {
					callback = function(args)
						if not pcall(vim.treesitter.start, args.buf) then
							return
						end

						vim.wo.foldmethod = "expr"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end,
				})
			end,
		},
		{
			"mason-org/mason-lspconfig.nvim",
			-- Install and configure language servers through Mason and lspconfig.
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
				-- Keep this empty so Mason does not install language servers silently.
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
			-- Teach completion and the Lua language server about Neovim's Lua API.
			event = "InsertEnter",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{
			"saghen/blink.cmp",
			-- Completion engine used by the LSP, snippets, filesystem, and buffer
			-- sources. It is enabled only when Neovim is not embedded in VS Code.
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
			-- Apply or jump through inline next-edit suggestions, when available.
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
			-- Browse and edit directories as if they were ordinary buffers.
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
			dependencies = { { "nvim-mini/mini.icons", opts = {} } },
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
			-- Fuzzy finder for buffers, files, and searches in the current buffer.
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
				{ "<leader>^",        "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Files" },
			},
		},
		{
			"Mofiqul/vscode.nvim",
			-- Use the VS Code-inspired theme during the initial UI setup.
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("vscode")
			end,
		},
	},
	-- Lazy-load every plugin by default; individual specs opt into startup or
	-- a specific event, command, or key mapping when appropriate.
	-- Every plugin must opt in to a loading trigger.  The colourscheme is the
	-- sole exception because it is part of the initial UI.
	defaults = { lazy = true },
	-- Avoid a background update check on every launch; use :Lazy check when
	-- updates are wanted.
	checker = { enabled = false },
})

-- ============================================================================
-- Global keymaps and autocmds
-- ============================================================================

function Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Double Escape returns from terminal-insert mode to normal mode.
Map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Move selected code block around
Map("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected block up" })
Map("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected block right" })
Map("v", "<", "<gv", { desc = "Move selected block backwards" })
Map("v", ">", ">gv", { desc = "Move selected block forward" })

-- Terminal buffers should behave like terminals: no line numbers and an
-- automatic transition into insert mode when they are opened.
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.o.number = false
		vim.o.relativenumber = false
		vim.cmd.startinsert()
	end,
})
