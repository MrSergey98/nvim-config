local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function setup_basedpyright(python_path)
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
end

local function get_python_path(cwd)
    local poetry_output = vim.fn.trim(vim.fn.system("cd " .. cwd .. " && poetry env info --path"))
    if poetry_output == "" or poetry_output:find("No virtual") then
        return vim.fn.exepath("python")
    end
    return poetry_output .. "\\Scripts\\python.exe"
end

-- Запуск при старте
local python_path = get_python_path(vim.fn.getcwd())
vim.notify("basedpyright python: " .. python_path)
setup_basedpyright(python_path)

-- Перезапуск при смене директории
vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "global",
    callback = function()
        local new_python_path = get_python_path(vim.fn.getcwd())
        vim.notify("basedpyright python: " .. new_python_path)
        for _, client in ipairs(vim.lsp.get_clients({ name = "basedpyright" })) do
            vim.lsp.stop_client(client.id)
        end
        setup_basedpyright(new_python_path)
    end,
})

-- Подсветка переменных
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.supports_method("textDocument/documentHighlight") then
                vim.lsp.buf.document_highlight()
                return
            end
        end
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
