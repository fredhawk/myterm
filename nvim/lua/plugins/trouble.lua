return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {},
	vim.keymap.set("n", "<leader>xx", function()
		require("trouble").toggle()
	end, { desc = "[x] Toggle Trouble" }),
	vim.keymap.set("n", "<leader>xw", function()
		require("trouble").toggle("workspace_diagnostics")
	end, { desc = "[w] Toggle Workspace Diagnostics" }),
	vim.keymap.set("n", "<leader>xd", function()
		require("trouble").toggle("document_diagnostics")
	end, { desc = "[d] Toggle Document Diagnostics" }),
	vim.keymap.set("n", "<leader>xq", function()
		require("trouble").toggle("quickfix")
	end, { desc = "[q] Toggle Quickfix List" }),
	vim.keymap.set("n", "<leader>xl", function()
		require("trouble").toggle("loclist")
	end, { desc = "[l] Toggle Loclist" }),
	vim.keymap.set("n", "gR", function()
		require("trouble").toggle("lsp_references")
	end, { desc = "[R] Toggle LSP References" }),
}
