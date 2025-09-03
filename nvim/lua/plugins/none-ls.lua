return {
	"nvimtools/none-ls.nvim",
	-- lazy = true,
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.markdownlint,
				null_ls.builtins.formatting.markdownlint,
				null_ls.builtins.diagnostics.write_good,
				null_ls.builtins.code_actions.gitsigns,
			},
		})
	end,
}
