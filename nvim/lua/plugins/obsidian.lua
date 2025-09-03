return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   "BufReadPre " .. vim.fn.expand "~" .. "/Documents/second-brain/core/**.md",
    --   "BufNewFile " .. vim.fn.expand "~" .. "/Documents/second-brain/core/**.md",
    -- },
    dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",

        -- see below for full list of optional dependencies 👇
    },
    -- opts = {
    --
    --     -- see below for full list of options 👇
    -- },
    config = function()
        local obsidian = require("obsidian")

        vim.o.conceallevel = 2
        vim.keymap.set('n', '<leader>os', ':ObsidianSearch<cr>', {desc = '[ObsidianSearch]'})
        vim.keymap.set('n', '<leader>oq', ':ObsidianQuickSwitch<cr>', {desc = '[ObsidianQuickSwitch]'})
        vim.keymap.set('n', '<leader>ot', ':ObsidianTemplate<cr>', {desc = '[ObsidianTemplate]'})
        vim.keymap.set('n', '<leader>on', ':ObsidianToday<cr>', {desc = '[ObsidianToday]'})

        obsidian.setup({
            workspaces = {
                {
                    name = "personal",
                    path = "~/Documents/second_brain/core/",
                },
            },
            new_notes_location = "notes_subdir",
            completion = {
                -- Set to false to disable completion.
                nvim_cmp = true,
                -- Trigger completion at 2 chars.
                min_chars = 2,
            },
            daily_notes = {
                -- Optional, if you keep daily notes in a separate directory.
                folder = "daily/" .. os.date("%Y") .. "/" .. os.date("%m") .. "/",
                -- Optional, if you want to change the date format for the ID of daily notes.
                date_format = "%Y-%m-%d",
                -- Optional, if you want to change the date format of the default alias of daily notes.
                alias_format = "%B %-d, %Y",
                -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
                template = "Sections/journal.md"
            },
            mappings = {
                -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                ["<leader>nf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
                -- Toggle check-boxes.
                ["<leader>ch"] = {
                    action = function()
                        return require("obsidian").util.toggle_checkbox()
                    end,
                    opts = { buffer = true },
                },
            },
            templates = {
                subdir = "templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                -- A map for custom variables, the key should be the variable and the value a function
                substitutions = {
                    fireid = function ()
                        return "id" .. tostring(os.date("%Y%m%d%H%M%S"))
                    end
                },
            },
            -- Optional, boolean or a function that takes a filename and returns a boolean.
            -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
            disable_frontmatter = false,

            -- Optional, alternatively you can customize the frontmatter data.
            ---@return table
            note_frontmatter_func = function(note)
                -- Add the title of the note as an alias.
                if note.title then
                    note:add_alias(note.title)
                end

                local out = { id = "id" .. tostring(os.date("%Y%m%d%H%M%S")), aliases = note.aliases, tags = note.tags }
                -- local out = { id = , aliases = note.aliases, tags = note.tags }

                -- `note.metadata` contains any manually added fields in the frontmatter.
                -- So here we just make sure those fields are kept in the frontmatter.
                if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                    for k, v in pairs(note.metadata) do
                        out[k] = v
                    end
                end

                return out
            end,
            -- Optional, customize how names/IDs for new notes are created.
            note_id_func = function(title)
                -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                -- In this case a note with the title 'My new note' will be given an ID that looks
                -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                local suffix = ""
                if title ~= nil then
                    -- If title is given, transform it into valid file name.
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                else
                    -- If title is nil, just add 4 random uppercase letters to the suffix.
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                -- return tostring(os.date("%Y%m%d%H%M%S")) .. "-" .. suffix
                return suffix
            end,
            attachments = {
                -- The default folder to place images in via `:ObsidianPasteImg`.
                -- If this is a relative path it will be interpreted as relative to the vault root.
                -- You can always override this per image by passing a full path to the command instead of just a filename.
                img_folder = "files", -- This is the default
                -- A function that determines the text to insert in the note when pasting an image.
                -- It takes two arguments, the `obsidian.Client` and a plenary `Path` to the image file.
                -- This is the default implementation.
                ---@param client obsidian.Client
                ---@param path Path the absolute path to the image file
                ---@return string
                img_text_func = function(client, path)
                    local link_path
                    local vault_relative_path = client:vault_relative_path(path)
                    if vault_relative_path ~= nil then
                        -- Use relative path if the image is saved in the vault dir.
                        link_path = vault_relative_path
                    else
                        -- Otherwise use the absolute path.
                        link_path = tostring(path)
                    end
                    local display_name = vim.fs.basename(link_path)
                    return string.format("![%s](%s)", display_name, link_path)
                end,
            },
        })
    end
}
