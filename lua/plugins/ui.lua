-- plugins that improve the user interface
return {
	{
		"Mofiqul/vscode.nvim",
		enabled = not vim.g.vscode,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme vscode")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = not vim.g.vscode,
		main = "ibl",
		event = "BufReadPre",
		---@module "ibl"
		---@type ibl.config
		opts = {
			indent = { char = "▏" },
		},
	},
}
