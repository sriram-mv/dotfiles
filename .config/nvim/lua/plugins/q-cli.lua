return {
  'sriram-mv/q-cli-neovim',
  config = function()
    require('q-cli-neovim').setup({
      trust_all_tools=true,
      startup_timeout=3000
    })
    vim.keymap.set('n', '<leader>tq', '<cmd>QToggle<cr>', { desc = 'Toggle Q CLI' })
    vim.keymap.set('n', '<leader>td', '<cmd>QDebug<cr>', { desc = 'Debug Q CLI session' })
    vim.keymap.set('n', '<leader>tc', '<cmd>QCleanup<cr>', { desc = 'Clean up Q CLI sessions' })
  end,
}
