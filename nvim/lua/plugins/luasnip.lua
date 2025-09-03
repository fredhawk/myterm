return {
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- -- install jsregexp (optional!).
		build = "make install_jsregexp",
		lazy = true,
		config = function()
			local ls = require("luasnip")
			local snip_loader = require("luasnip.loaders.from_lua")

			ls.setup({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				autosnippets = true,
			})

			-- Extend filetypes snippets with others, ex add css snippets to javascript
			-- ls.filetype_extend("javascript", { "css" })
			ls.filetype_extend("astro", { "css", "javascript", "typescript" })

			-- Load the snippets from nvim folder /lua/snippets. load all lua files there.
			snip_loader.lazy_load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })

			vim.keymap.set({ "i" }, "<C-K>", function()
				ls.expand()
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-L>", function()
				ls.jump(1)
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-J>", function()
				ls.jump(-1)
			end, { silent = true })

			vim.keymap.set({ "i", "s" }, "<C-E>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { silent = true })
		end,
	},
}
