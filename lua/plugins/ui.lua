-- plugins that improve the user interface
return {
	{
		"Mofiqul/vscode.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("vscode")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		-- Keep the initial UI path limited to the colourscheme.  The detector
		-- starts the first time Neovim regains focus and then keeps polling.
		event = "FocusGained",
		opts = {
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd.colorscheme("vscode")
    	end,
    	set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd.colorscheme("vscode")
    	end,
    	update_interval = 3000,
    	fallback = "dark"
  	}
	},
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
}
