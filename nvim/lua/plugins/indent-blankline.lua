return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost" },
		main = "ibl",
		opts = {},
		config = function()
			require("ibl").setup({
				--   show_trailing_blankline_indent = false,
				indent = {
					char = "┊",
				},
			})
		end,
	}, -- Add indentation guides even on blank lines,
}
