-- plugins that improve the user interface
return {
	{
  	"f-person/auto-dark-mode.nvim",
		dependencies = {
			"Mofiqul/vscode.nvim",
		},
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
		event = "BufReadPre",
		---@module "ibl"
		---@type ibl.config
		opts = {
			indent = { char = "▏" },
		},
	},
}
