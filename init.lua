vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.cmd('syntax on')
vim.o.cursorline = true
vim.o.number = true
vim.o.showmatch = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.showmode = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.o.autocomplete = true -- Enables the overall completion feature.
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.complete = '.,o'
local function pum_map(key, pum_keys)
	vim.keymap.set('i', key, function()
		return vim.fn.pumvisible() == 1 and pum_keys or key
	end, { expr = true })
end

pum_map('<Tab>', '<Down>')    -- next, highlights without inserting
pum_map('<S-Tab>', '<Up>')    -- previous

vim.keymap.set('i', '<CR>', function()
	if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ 'selected' }).selected ~= -1 then
		return '<C-y>'        -- accept the highlighted entry
	end
	return '<CR>'             -- otherwise a normal newline
end, { expr = true })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
    },
  },
})


vim.lsp.enable({'lua_ls', 'clangd', 'cmake' })
