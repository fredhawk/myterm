local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local date = function()
    return { os.date("%Y-%m-%d") }
end

ls.add_snippets("typescript", {
    s({
        trig = "raid",
        name = "Date",
        dscr = "Date in the form of YYYY-MM-DD",
    }, {
        f(date, {}),
    }),
    s({ trig = "fjl", name = "Regular for loop", desc = "For loop"},
        fmt([[
for (let {} = 0; {} < {}; {}++) {{
    {}
}}
        ]], {i(1), rep(1), i(2), rep(1), i(0)})
    ),
    s({ trig = "fji", name = "For ... in", desc = "The for...in statement iterates over all enumerable string properties of an object (ignoring properties keyed by symbols), including inherited enumerable properties."},
        fmt([[
for (const {} in {}) {{
    {}
}}
        ]], { i(1, "property"), i(2, "object"), i(0)})
    ),
    s({ trig = "fjo", name = "For ... of", desc = "The for...of statement executes a loop that operates on a sequence of values sourced from an iterable object. Iterable objects include instances of built-ins such as Array, String, TypedArray, Map, Set, NodeList (and other DOM collections), as well as the arguments object, generators produced by generator functions, and user-defined iterables."},
        fmt([[
for (const {} of {}) {{
    {}
}}
        ]], { i(1, "element"), i(2, "array"), i(0)})
    ),
    s({ trig = "fn", name = "Named function", desc = "Named function"},
        fmt([[
function {}({}: {}): {} {{
    {}
}}
        ]], { i(1, "name"), i(2), i(3), i(4), i(0)})
    ),
    s({ trig = "fna", name = "Arrow function", desc = "Arrow function"},
        fmt([[
const {}: {} = ({}: {}): {} => {{
    {}
}}
        ]], { i(1, "name"), i(2), i(3), i(4), i(5), i(0)})
    ),
    s({ trig = "afn", name = "Named async function", desc = "Named async function"},
        fmt([[
async function {}({}: {}): {} {{
    {}
}}
        ]], { i(1, "name"), i(2), i(3), i(4), i(0)})
    ),
    s({ trig = "afna", name = "Async arrow function", desc = "Async arrow function"},
        fmt([[
const {}: {} = async ({}: {}): {} => {{
    {}
}}
        ]], { i(1, "name"), i(2), i(3), i(4), i(5), i(0)})
    ),
})
