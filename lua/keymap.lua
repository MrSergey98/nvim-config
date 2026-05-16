local fzf_lua = require("fzf-lua")

vim.keymap.set("n", "<leader><leader>", fzf_lua.files)
vim.keymap.set("n", "<leader>/", function()
    local fzf = require("fzf-lua")
    local dir = vim.fn.input("Search dir: ", vim.fn.getcwd(), "dir")
    if dir == "" then return end
    fzf.live_grep({ cwd = dir })
end, { desc = "Live grep (choose dir)" })
vim.keymap.set('n', 'K', vim.diagnostic.open_float)

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
vim.keymap.set("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", opts)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>td", function ()
	require("lazydocker").toggle()
	end, { desc = "Toggle LazyDocker" })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<leader>fi", function()
    vim.lsp.buf.code_action({
        context = {
            only = { "source.organizeImports" },
            diagnostics = {},
        },
        apply = true,
    })
end, { desc = "Fix imports (ruff)" })

vim.api.nvim_create_user_command("G", function(opts)
    local input = opts.args
    local file, line = input:match("^(.+):(%d+)$")
    if file and line then
        vim.cmd("edit +" .. line .. " " .. file)
    else
        vim.cmd("edit " .. input)
    end
end, { nargs = 1, complete = "file" })

-- Indent/unindent в visual mode
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent block" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent block" })

-- Unindent в insert mode
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename variable" })
-- Удаление без копирования
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d", { desc = "Delete without yank" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>w", ":wa<CR>", { desc = "Save all files" })
vim.keymap.set("i", ".", function()
    vim.api.nvim_feedkeys(".", "n", false)
    vim.schedule(function()
        require("cmp").complete()
    end)
end)
-- Lazygit
vim.keymap.set("n", "<leader>gg", function()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
        cmd = "lazygit",
        direction = "float",
        close_on_exit = true,
        env = {
            LG_CONFIG_FILE = vim.fn.stdpath("config") .. "\\lazygit.yml",
            NVIM_SERVER = vim.v.servername,
        },
        on_exit = function()
            vim.cmd("checktime")
        end,
    })
    lazygit:toggle()
end, { desc = "LazyGit" })

-- Gitsigns
local gs = require("gitsigns")

-- Навигация по изменениям
vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk" })
vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })

-- Действия с изменениями
vim.keymap.set("n", "<leader>hs", gs.stage_hunk,   { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", gs.reset_hunk,   { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })

-- Blame
vim.keymap.set("n", "<leader>hb", gs.blame_line,   { desc = "Blame line" })

local dap = require("dap")
local dapui = require("dapui")

vim.keymap.set("n", "<F5>",  dap.continue,          { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over,          { desc = "Debug: Step over" })
vim.keymap.set("n", "<F11>", dap.step_into,          { desc = "Debug: Step into" })
vim.keymap.set("n", "<F12>", dap.step_out,           { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.terminate,     { desc = "Debug: Stop" })
vim.keymap.set("n", "<leader>du", dapui.toggle,      { desc = "Debug: Toggle UI" })
