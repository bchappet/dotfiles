local vim = vim
local Plug = vim.fn['plug#']
local opt = {noremap=true, silent=false}

-- Standard vim options

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true --persistent history
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

-- set auto save
vim.opt.hidden = true
-- Use autocmd instead of autowrite/autowriteall to check if buffer is writable
vim.api.nvim_create_autocmd({"FocusLost", "BufLeave"}, {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= '' and vim.bo.modifiable and not vim.bo.readonly and vim.bo.buftype == '' then
      vim.cmd('silent! write')
    end
  end,
})

-- Restore cursor position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Standard remap

vim.keymap.set('n',            ';',':',opt)
vim.keymap.set('n',            ':',';',opt)
vim.keymap.set({'i', 'v'},'jk','<esc>',opt)
vim.keymap.set('n',            '<Tab>', ':bn<cr>', opt)
vim.keymap.set('n',            '<S-Tab>', ':bp<cr>', opt)

-- Plugins

vim.call('plug#begin')

Plug('folke/tokyonight.nvim')
Plug('neovim/nvim-lspconfig')
Plug('heavenshell/vim-pydocstring', { ['do'] = 'make install', ['for'] = 'python' })
Plug('nvim-treesitter/nvim-treesitter')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', {['tag']='0.1.8'})
Plug('jiaoshijie/undotree')
Plug('alexghergh/nvim-tmux-navigation')
Plug('nvim-lualine/lualine.nvim')
Plug('nvim-tree/nvim-web-devicons')
Plug('mason-org/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
-- Mini stuff (dependencies for completion)
Plug('nvim-mini/mini.icons')
Plug('nvim-mini/mini.snippets')
Plug('nvim-mini/mini.completion')
-- Git
Plug('tpope/vim-fugitive')

vim.call('plug#end')

-- Configure Mason
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'pyright', 'ruff' },
  automatic_installation = true,
})

-- Configure LSP
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')

-- LSP navigation
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opt)

-- LSP diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {noremap = true, silent = true})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {noremap = true, silent = true})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {noremap = true, silent = true})
vim.keymap.set('n', 'gl', vim.diagnostic.setloclist, {noremap = true, silent = true})

-- Format with LSP (ruff for Python)
-- Format current line in normal mode
vim.keymap.set('n', '<leader>f', function()
  local line = vim.fn.line('.')
  local line_count = vim.api.nvim_buf_line_count(0)
  vim.lsp.buf.format({
    range = {
      ['start'] = {line, 0},
      ['end'] = {math.min(line + 1, line_count), 0}
    }
  })
end, {noremap = true, silent = true})

-- Format selection in visual mode
vim.keymap.set('v', '<leader>f', function()
  vim.lsp.buf.format()
end, {noremap = true, silent = true})

-- Format entire file
vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, {noremap = true, silent = true})

-- Organize imports (ruff)
vim.keymap.set('n', '<leader>i', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.organizeImports' } },
    apply = true,
  })
end, {noremap = true, silent = true})

-- Configure vim-pydocstring
vim.g.pydocstring_enable_mapping = 0
vim.g.pydocstring_formatter = 'google'

-- Configure undotree
require('undotree').setup()
vim.keymap.set('n', '<F5>', require('undotree').toggle, opt)

-- Configure treesitter
require('nvim-treesitter.configs').setup({
  -- Install parsers for these languages
  ensure_installed = { "lua", "python", "vim", "vimdoc", "bash", "markdown" },

  -- Auto-install missing parsers when entering buffer
  auto_install = true,

  -- Enable syntax highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  -- Enable indentation
  indent = {
    enable = true
  },
})

-- colorscheme
vim.cmd[[colorscheme tokyonight]]

-- configure tmux
local nvim_tmux_nav = require('nvim-tmux-navigation')
nvim_tmux_nav.setup {
    disable_when_zoomed = false -- defaults to false
}

-- lua-line
require('lualine').setup({
    tabline = {
        lualine_a = {},
        lualine_b = {'branch'},
        lualine_c = {'filename'},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'tabs'}
    },
    sections = {lualine_c = {'lsp_progress'}}
})

-- mini auto-completion + deps
require('mini.icons').setup()
require('mini.snippets').setup()
require('mini.completion').setup({
  delay = { completion = 10000000 },  -- Disable auto-completion (trigger manually with Tab)
})

-- Custom completion navigation with Tab/Shift-Tab
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'  -- Navigate forward in menu
  else
    -- Check if there's text before cursor to complete
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      return '<Tab>'  -- Insert tab for indentation
    else
      return '<C-x><C-u>'  -- Trigger mini.completion
    end
  end
end, { expr = true, noremap = true })

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  else
    return '<S-Tab>'
  end
end, { expr = true, noremap = true })


-- Ctrl commands
vim.keymap.set({'n', 'i', 'v'},"<C-p>", "<cmd>Telescope oldfiles<cr>", opt)
vim.keymap.set({'n', 'i', 'v'},"<C-n>", "<cmd>Telescope find_files<cr>", opt)
vim.keymap.set({'n', 'i', 'v'}, "<C-\\>", ":Pydocstring<cr>", opt)

-- Helper function to save only if buffer has a name and unsaved changes
local function safe_write()
  if vim.api.nvim_buf_get_name(0) ~= '' and vim.bo.modified then
    vim.cmd('write')
  end
end

vim.keymap.set({'n', 'i'}, "<C-h>", function() safe_write(); nvim_tmux_nav.NvimTmuxNavigateLeft() end, opt)
vim.keymap.set({'n', 'i'}, "<C-j>", function() safe_write(); nvim_tmux_nav.NvimTmuxNavigateDown() end, opt)
vim.keymap.set({'n', 'i'}, "<C-k>", function() safe_write(); nvim_tmux_nav.NvimTmuxNavigateUp() end, opt)
vim.keymap.set({'n', 'i'}, "<C-l>", function() safe_write(); nvim_tmux_nav.NvimTmuxNavigateRight() end, opt)

-- Other Leader command
vim.keymap.set('n', '<leader>d',':bd<CR>', opt)
vim.keymap.set('n', '<leader>q',':q<CR>', opt)
vim.keymap.set('n', '<leader>w','<C-w>', opt)

-- Set colorcolumn for Python files only
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.colorcolumn = "100"
    end,
})
