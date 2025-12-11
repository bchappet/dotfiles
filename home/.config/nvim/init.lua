local vim = vim
local Plug = vim.fn['plug#']
opt = {noremap=true, silent=false}

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

vim.call('plug#end')

-- Configure LSP
vim.lsp.enable('pyright')
-- Jumps to the definition of the symbol under the cursor.
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

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
        lualine_z = {}
    },
    sections = {lualine_c = {'lsp_progress'}}
})


-- Ctrl commands
vim.keymap.set({'n', 'i', 'v'},"<C-p>", "<cmd>Telescope oldfiles<cr>", opt)
vim.keymap.set({'n', 'i', 'v'},"<C-n>", "<cmd>Telescope find_files<cr>", opt)
vim.keymap.set({'n', 'i', 'v'}, "<C-\\>", ":Pydocstring<cr>", opt)

-- Helper function to save only if buffer is writable
local function safe_write()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= '' and vim.bo.modifiable and not vim.bo.readonly and vim.bo.buftype == '' then
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
