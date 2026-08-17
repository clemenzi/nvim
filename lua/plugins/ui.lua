-- plugins that improve the user interface
return {
	-- {
	-- 	"Mofiqul/vscode.nvim",
	-- 	enabled = not vim.g.vscode,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd("colorscheme vscode")
	-- 	end,
	-- },
	{
  	"f-person/auto-dark-mode.nvim",
		dependencies = {
			"ellisonleao/gruvbox.nvim",
		},
  	opts = {
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd([[colorscheme gruvbox]])
    	end,
    	set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd([[colorscheme gruvbox]])
    	end,
    	update_interval = 3000,
    	fallback = "dark"
  	}
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
