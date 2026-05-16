-- LSP capabilities для cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- PYTHON LSP
vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "global",  -- только при явной смене через :cd, не при открытии файлов
    callback = function()
        local cwd = vim.fn.getcwd()
        local poetry_output = vim.fn.trim(vim.fn.system("cd " .. cwd .. " && poetry env info --path"))
        local python_path
        if poetry_output == "" or poetry_output:find("No virtual") then
            python_path = vim.fn.exepath("python")
        else
            python_path = poetry_output .. "\\Scripts\\python.exe"
        end

        vim.notify("basedpyright python: " .. python_path)

        for _, client in ipairs(vim.lsp.get_clients({ name = "basedpyright" })) do
            vim.lsp.stop_client(client.id)
        end

        vim.lsp.config("basedpyright", {
            capabilities = capabilities,
            settings = {
                python = { pythonPath = python_path },
                basedpyright = {
                    typeCheckingMode = "basic",
                    reportUnknownMemberType = false,
                    reportUnknownVariableType = false,
                    reportUnknownParameterType = false,
                    reportMissingTypeArgument = false,
                    reportUnannotatedClassAttribute = false,
                    analysis = {
                        autoImportCompletions = true,
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                    },
                }
            },
        })
        vim.lsp.enable("basedpyright")
    end,
})

-- Подсветка переменных
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.lsp.buf.document_highlight()
    end,
})

vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function()
        vim.lsp.buf.clear_references()
    end,
})

vim.lsp.config("pylsp", {
    capabilities = capabilities,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false },
                pyflakes    = { enabled = false },
                mccabe      = { enabled = false },
            }
        }
    }
})
vim.lsp.enable("pylsp")

-- SIGNATURE (аргументы функции при вводе)
require("lsp_signature").setup({
    bind = true,
    hint_enable = false,
    floating_window = true,
    handler_opts = {
        border = "rounded",
    },
})

-- AUTOCOMPLETE
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    matching = {
        disallow_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),  -- окно с docstring
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})
