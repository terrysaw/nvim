vim.g.mapleader = " "
vim.g.maplocalleader = " "


vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.cmd("syntax on")
vim.o.cursorline = true
vim.o.number = true
vim.o.scrolloff = 10
vim.o.showmatch = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.showmode = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.confirm = true

local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add{
  gh "neovim/nvim-lspconfig",
  gh "NMAC427/guess-indent.nvim",
  gh "lewis6991/gitsigns.nvim",
  gh "folke/tokyonight.nvim",
  gh "nvim-lua/plenary.nvim",
  gh "nvim-telescope/telescope.nvim",
  gh "nvim-telescope/telescope-ui-select.nvim",
}

vim.o.autocomplete = true -- Enables the overall completion feature.
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.complete = ".,o"
local function pum_map(key, pum_keys)
	vim.keymap.set("i", key, function()
		return vim.fn.pumvisible() == 1 and pum_keys or key
	end, { expr = true })
end

pum_map("<Tab>", "<Down>")    -- next, highlights without inserting
pum_map("<S-Tab>", "<Up>")    -- previous

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
		return "<C-y>"        -- accept the highlighted entry
	end
	return "<CR>"             -- otherwise a normal newline
end, { expr = true })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

--- Packages (Arch):
--- lua_language_server clang cmake_language_server bash_language_server
vim.lsp.enable({
    "lua_ls", 
    "clangd", 
    "cmake",
    "bashls",
    "gdscript",
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    virtual_lines = false,

    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float {
                bufnr = bufnr,
                scope = "cursor",
                focus = false,
            }
        end,
    },
}

vim.keymap.set("n", "<leader>R", function() vim.cmd("source %") end, { desc = "Resource config" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

--- Telescope
local builtin = require "telescope.builtin"
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps", })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles", })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord", })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep", })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics", })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers", })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
    callback = function(event)
        local buf = event.buf

        vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
        vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
        vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
        vim.keymap.set("n", "grt", builtin.lsp_type_definitions, { buffer = buf, desc = "[G]oto [T]ype definition" })
    end
})

--- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my-lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mmode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
        end
    end
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when tanking (copying) text",
    group = vim.api.nvim_create_augroup("my-highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

vim.cmd.colorscheme "tokyonight-night"
