return {
	"nvim-lualine/lualine.nvim", -- Fancier statusline,
	event = { "InsertEnter", "CmdLineEnter" },
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "tokyonight",
				component_separators = "|",
				section_separators = "",
			},
		})
	end,
}
