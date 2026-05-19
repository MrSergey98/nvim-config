vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.colorcolumn = "150"
vim.opt.listchars = "tab: ,multispace:|   ,eol:󰌑"
if vim.fn.has("nvim-0.11") == 1 then
    vim.opt.winborder = "rounded"
end
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.diagnostic.config({
  virtual_text = true,
})
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 50
vim.env.GIT_EDITOR = "nvim"
vim.env.EDITOR = "nvim"
vim.opt.signcolumn = "yes"
