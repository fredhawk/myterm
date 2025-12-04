return {
  "L3MON4D3/LuaSnip",
  opts = function()
    local ls = require("luasnip")
    local snip_loader = require("luasnip.loaders.from_lua")

    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      autosnippets = true,
    })

    -- Extend filetypes snippets with others, ex add css snippets to javascript
    -- ls.filetype_extend("javascript", { "css" })
    ls.filetype_extend("astro", { "css", "javascript", "typescript" })

    -- Load the snippets from nvim folder /snippets. load all lua files there.
    snip_loader.lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })
  end,
}
