local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local path_sep = is_windows and "\\" or "/"
local python_bin = is_windows and "Scripts\\python.exe" or "bin/python"
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
    -- 1. Локальный venv в папке проекта (.venv или venv)
    local venv_dirs = { ".venv", "venv", "env", ".env" }
    for _, venv in ipairs(venv_dirs) do
        local venv_python = cwd .. path_sep .. venv .. path_sep .. python_bin
        if vim.fn.filereadable(venv_python) == 1 then
            return venv_python
        end
    end

    -- 2. Poetry
    local cmd = is_windows
        and ("cd /d " .. cwd .. " && poetry env info --path")
        or  ("cd " .. cwd .. " && poetry env info --path")
    local poetry_output = vim.fn.trim(vim.fn.system(cmd))
    local last_line = poetry_output:match("([^\n]+)$")
    poetry_output = last_line or poetry_output
    if poetry_output ~= "" and not poetry_output:find("No virtual") and not poetry_output:find("not found") and not poetry_output:find("invalid") then
        return poetry_output .. path_sep .. python_bin
    end

    -- 3. Pipenv
    local pipenv_output = vim.fn.trim(vim.fn.system("cd " .. cwd .. " && pipenv --venv 2>/dev/null"))
    if pipenv_output ~= "" and not pipenv_output:find("No virtual") then
        return pipenv_output .. path_sep .. python_bin
    end

    -- 4. Conda (если активирован)
    local conda_prefix = vim.env.CONDA_PREFIX
    if conda_prefix and conda_prefix ~= "" then
        local conda_python = conda_prefix .. path_sep .. python_bin
        if vim.fn.filereadable(conda_python) == 1 then
            return conda_python
        end
    end

    -- 5. Системный python
    return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or vim.fn.exepath("python")
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
        if #clients == 0 then return end
        for _, client in ipairs(clients) do
            if client.server_capabilities.documentHighlightProvider then
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
