return {
  "saghen/blink.cmp",
  opts = {
    snippets = { preset = "luasnip" },
    keymap = {
      preset = "default",
      ["<Tab>"] = {},
      ["<S-Tab>"] = {},
      ["<C-k>"] = { "snippet_forward", "fallback" },
      ["<C-j>"] = { "snippet_backward", "fallback" },
    },
    completion = {
      list = {
        selection = {
          preselect = false,
        },
      },
    },
  },
}
