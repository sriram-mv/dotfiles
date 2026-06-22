vim.cmd("set autoindent")
vim.cmd("set smartindent")
vim.cmd("set expandtab")
vim.cmd("set softtabstop=2")
vim.cmd("set nobackup")
vim.cmd("set nowritebackup")
vim.cmd("set noswapfile")
vim.cmd("set history=50")
vim.cmd("set ruler")
vim.cmd("set showcmd")
vim.cmd("set incsearch")
vim.cmd("set laststatus=2")
vim.cmd("set autowrite")
vim.cmd("set modelines=2")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set smarttab")
vim.cmd("set relativenumber")

vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false


-- Better window management
vim.keymap.set('n', '<leader>sv', '<C-w>v') -- Split vertically
vim.keymap.set('n', '<leader>sh', '<C-w>s') -- Split horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=') -- Equal width
vim.keymap.set('n', '<leader>sx', ':close<CR>') -- Close split

-- Better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Move lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', 'ZZ')


-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Remove buffer naming conflicts
vim.opt.hidden = true

vim.wo.number = true
