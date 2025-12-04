local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local date = function()
    return { os.date("%Y-%m-%d") }
end

ls.add_snippets("lua", {
    s({
        trig = "today",
        name = "Date",
        dscr = "Date in the form of YYYY-MM-DD",
    }, {
        f(date, {}),
    }),
    s(
        { trig = "snip", name = "New Snippet", desc = "Boilerplate for new snippets." },
        fmta(
            [[
    s({ trig = "<>", name = "<>", desc = "<>"}, 
        <>
    )
    ]],
            { i(1), i(2), i(3), i(0) }
        )
    ),
})
