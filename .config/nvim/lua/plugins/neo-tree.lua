-- return {
-- 	"nvim-neo-tree/neo-tree.nvim",
-- 	branch = "v3.x",
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 		"nvim-tree/nvim-web-devicons",
-- 		"MunifTanjim/nui.nvim",
-- 	},
-- 	config = function()
-- 		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
-- 		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
--     require("neo-tree").setup({
--       filesystem = {
--       follow_current_file={
--         enabled = true,
--     }
--     }})
-- 	end,
-- }
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   branch = "v3.x",
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "nvim-tree/nvim-web-devicons",
--     "MunifTanjim/nui.nvim",
--   },
--   config = function()
--     -- Disable netrw
--     vim.g.loaded_netrw = 1
--     vim.g.loaded_netrwPlugin = 1
--
--     vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
--     vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
--
--     require("neo-tree").setup({
--       close_if_last_window = false,
--       popup_border_style = "rounded",
--       enable_git_status = true,
--       enable_diagnostics = true,
--       filesystem = {
--         follow_current_file = {
--           enabled = true,
--           leave_dirs_open = false,
--         },
--         hijack_netrw_behavior = "disabled",
--         use_libuv_file_watcher = true,
--       },
--       buffers = {
--         follow_current_file = {
--           enabled = true,
--         },
--       },
--     })
--   end,
-- }
--
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    -- Add window picker for telescope-like UI
    "s1n7ax/nvim-window-picker",
  },
  config = function()
    -- Disable netrw completely to prevent conflicts
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Configure window picker first
    require('window-picker').setup({
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = { 'neo-tree', "neo-tree-popup", "notify" },
          -- if the buffer type is one of following, the window will be ignored
          buftype = { 'terminal', "quickfix" },
        },
      },
    })

    require("neo-tree").setup({
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,

      -- Fix the buffer naming issue
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = false,
        statusline = false,
      },

      -- Add proper window mappings with telescope-like UI
      window = {
        position = "left",
        width = 30,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<space>"] = "none", -- disable space
          ["<cr>"] = "open",
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
          ["l"] = "focus_preview",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          -- This brings back the telescope-like window picker
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["a"] = {
            "add",
            config = {
              show_path = "none" -- "none", "relative", "absolute"
            }
          },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination
          ["m"] = "move", -- takes text input for destination
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
        }
      },

      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        hijack_netrw_behavior = "disabled",
        use_libuv_file_watcher = true,
        bind_to_cwd = true,
        cwd_target = {
          sidebar = "global",
          current = "global"
        },
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
        },
        -- Enable window picker for file operations
        window_picker = {
          enable = true,
          picker = "window-picker",
          winblend = 10,
          border = "rounded",
          include_current_win = false,
          autoselect_one = true,
        },
      },

      buffers = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        show_unloaded = true,
        bind_to_cwd = true,
        -- Enable window picker for buffer operations
        window_picker = {
          enable = true,
          picker = "window-picker",
          winblend = 10,
          border = "rounded",
          include_current_win = false,
          autoselect_one = true,
        },
      },

      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"]  = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          }
        }
      },

      -- Add event handlers to prevent conflicts
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            -- Ensure Neo-tree uses current working directory
            vim.cmd("cd " .. vim.fn.getcwd())
          end
        },
      },
    })

    -- Simple working keymaps
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Toggle Neo-tree" })
    vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { desc = "Neo-tree buffers" })
  end,
}

