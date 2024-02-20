local vim = vim
local Plug = vim.fn['plug#']
opt = {noremap=true, silent=false}


-- Standard vim options

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true --persistent history
vim.opt.undodir = "${HOME}/.config/nvim/undo"


-- Standard remap

vim.keymap.set('n',            ';',':',opt)
vim.keymap.set('n',            ':',';',opt)
vim.keymap.set({'i', 'v'},'jk','<esc>',opt)
vim.keymap.set('n',            '<Tab>', ':bn<cr>', opt)
vim.keymap.set('n',            '<S-Tab>', ':bp<cr>', opt)

-- Plugins

vim.call('plug#begin')

Plug('folke/tokyonight.nvim')
Plug('folke/which-key.nvim')
Plug('heavenshell/vim-pydocstring', { ['do'] = 'make install', ['for'] = 'python' })
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag']= '0.1.5' })
Plug('jiaoshijie/undotree')
Plug('alexghergh/nvim-tmux-navigation')
Plug('codota/tabnine-nvim', { ['do']= './dl_binaries.sh' })

vim.call('plug#end')


-- Configure which-key
--
vim.opt.timeoutlen = 200
local wk = require("which-key")

wk.register({
  f = {
    name = "file", -- optional group name
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    r = { "<cmd>Telescope oldfiles<cr>", "Recent File" },
    g = { "<cmd>Telescope live_grep<cr>", "Find Grep" }, 
    b = { "<cmd>Telescope buffers<cr>", "Find Buffers" }, 
    h = { "<cmd>Telescope help_tags<cr>", "Help Tags" }, 
  },
  c = {
    name = 'code',
    m = { "<cmd>Mason<cr>", "Mason"},
    p = { "<cmd>Pydocstring<cr>", "Python Documentation"},
  },
}, { prefix = "<leader>" })

-- Configure vim-pydocstring
vim.g.pydocstring_enable_mapping = 0
vim.g.pydocstring_formatter = 'google'

-- Configure undotree
require('undotree').setup()
vim.keymap.set('n', '<F5>', require('undotree').toggle, opt)

-- colorscheme 
vim.cmd[[colorscheme tokyonight]]

-- configure tmux
local nvim_tmux_nav = require('nvim-tmux-navigation')
nvim_tmux_nav.setup {
    disable_when_zoomed = true -- defaults to false
}

-- tab nine smart autocompletion
require('tabnine').setup({
  disable_auto_comment=true,
  accept_keymap="<Tab>",
  dismiss_keymap = "<C-]>",

  debounce_ms = 800,
  suggestion_color = {gui = "#808080", cterm = 244},
  exclude_filetypes = {"TelescopePrompt", "NvimTree"},
  log_file_path = nil, -- absolute path to Tabnine log file
})

-- Ctrl commands
vim.keymap.set({'n', 'i', 'v'},"<C-p>", "<cmd>Telescope oldfiles<cr>", opt)
vim.keymap.set({'n', 'i', 'v'},"<C-s>", '<esc>:w<cr>', opt)
vim.keymap.set({'n', 'i', 'v'}, "<C-\\>", ":Pydocstring<cr>", opt)

vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, opt)
vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, opt)
vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, opt)
vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, opt)

-- Other Leader command
vim.keymap.set('n', '<leader>d',':bd<CR>', opt)
vim.keymap.set('n', '<leader>q',':q<CR>', opt)
vim.keymap.set('n', '<leader>w','<C-w>', opt)

-- duplicate but faster (and I'm so used to it...)
