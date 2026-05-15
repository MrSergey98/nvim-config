-- 1
vim.pack.add({
    {src = "https://github.com/folke/tokyonight.nvim"},
})

require("tokyonight").setup({})

--

vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
})

-- 2
vim.pack.add({
    { src = "https://github.com/williamboman/mason.nvim" },
})

require("mason").setup()

-- 3
vim.pack.add({
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
})
require('mason-lspconfig').setup()

-- 5
vim.pack.add({
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

require('lualine').setup()

-- 6
vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
})

local actions = require('fzf-lua.actions')
require('fzf-lua').setup({
    winopts = { backdrop = 85 },
    keymap = {
        builtin = {
            ["<C-f>"] = "preview-page-down",
            ["<C-b>"] = "preview-page-up",
            ["<C-p>"] = "toggle-preview",
        },
        fzf = {
            ["ctrl-a"] = "toggle-all",
            ["ctrl-t"] = "first",
            ["ctrl-g"] = "last",
            ["ctrl-d"] = "half-page-down",
            ["ctrl-u"] = "half-page-up",
        }
    },
    actions = {
        files = {
            ["ctrl-q"] = actions.file_sel_to_qf,
            ["ctrl-n"] = actions.toggle_ignore,
            ["ctrl-h"] = actions.toggle_hidden,
            ["enter"]  = actions.file_edit_or_qf,
        }
    }
})
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

require("nvim-tree").setup({
	 view = {
      width = 40,
    }
})

vim.pack.add({
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/hrsh7th/cmp-nvim-lsp",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/saadparwaiz1/cmp_luasnip",
})

vim.pack.add({
    { src = "https://github.com/crnvl96/lazydocker.nvim" },
})

require("lazydocker").setup({
    window = {
        settings = {
            border = "rounded",
            height = 0.618,
            relative = "editor",
            width = 0.618,
        }
    }
})

-- Список compose файлов
local compose_files = {
    "docker-compose.yml",
    "docker-compose.yaml",
    "docker-compose-dev.yml",
    "docker-compose-dev.yaml",
}

-- Фильтруем только существующие файлы
local existing = {}
for _, f in ipairs(compose_files) do
    if vim.fn.filereadable(f) == 1 then
        table.insert(existing, f)
    end
end

-- Устанавливаем переменную окружения
if #existing > 0 then
    vim.env.COMPOSE_FILE = table.concat(existing, ":")
end
vim.pack.add({
	"https://github.com/ray-x/lsp_signature.nvim",
})

vim.pack.add({ { src = "https://github.com/akinsho/toggleterm.nvim" } })
require("toggleterm").setup()
vim.pack.add({{ src = "https://github.com/kdheepak/lazygit.nvim" }})
vim.pack.add({{ src = "https://github.com/lewis6991/gitsigns.nvim" }})

require("gitsigns").setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▎" },
        topdelete    = { text = "▎" },
        changedelete = { text = "▎" },
    },
    current_line_blame = false,  -- включить если хотите blame на каждой строке
})
