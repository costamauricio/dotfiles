vim.g.mapleader = ' ' -- Leader key is Space
vim.g.maplocalleader = ' '
vim.o.termguicolors = true

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require('lazy').setup({
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
  },
  'tpope/vim-fugitive',
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup {
        style = 'warmer',
        term_colors = true
      }

      require('onedark').load()
    end
  },
  {
    'sainnhe/everforest',
    priority = 1000,
    enabled = false,
    config = function()
      vim.o.background = "dark"
      vim.g.everforest_background = 'hard'
      vim.cmd.colorscheme 'everforest'
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = false,
    config = function()
      require('gruvbox').setup({
        overrides = {
          SignColumn = { link = "Normal" },
          GruvboxGreenSign = { bg = "" },
          GruvboxOrangeSign = { bg = "" },
          GruvboxPurpleSign = { bg = "" },
          GruvboxYellowSign = { bg = "" },
          GruvboxRedSign = { bg = "" },
          GruvboxBlueSign = { bg = "" },
          GruvboxAquaSign = { bg = "" },
        },
      })
      vim.o.background = "dark"
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {}
  },
  {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    enabled = false,
    dependencies = {
      { 'ms-jpq/coq.artifacts',  branch = 'artifacts' },
      { 'ms-jpq/coq.thirdparty', branch = '3p' },
    },
    build = ':COQdeps',
    lazy = true,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim',       branch = "legacy", opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },
  'editorconfig/editorconfig-vim',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  { 'numToStr/Comment.nvim',        opts = {} },
  { 'kyazdani42/nvim-web-devicons', opts = {} },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
    opts = {
      rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" }
    }
  },
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "luarocks.nvim" },
    config = function()
      require("rest-nvim").setup({
        result = {
          formatters = {
            json = "jq"
          }
        }
      })
    end,
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      tabline = {
        lualine_a = {
          'buffers'
        },
        lualine_z = { 'tabs' },
      },
      sections = {
        lualine_c = {
          {
            'filename',
            file_status = true,
            path = 1
          }
        }
      },
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {
      indent = {
        tab_char = '┊'
      },
      scope = {
        char = '│',
        show_start = true
      }
    },
  },
  'mfussenegger/nvim-dap',
  'leoluz/nvim-dap-go',
  {
    'rcarriga/nvim-dap-ui', dependencies = {"nvim-neotest/nvim-nio"}
  },
  'theHamsta/nvim-dap-virtual-text',
}, {})

local cmp = require 'cmp'
local lspkind = require 'lspkind'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = '[buf]',
        nvim_lsp = '[LSP]',
        path = '[path]',
      }
    }
  },
  experimental = {
    ghost_text = false,
  }
})

require('dap-go').setup()
require('dapui').setup()
require('nvim-dap-virtual-text').setup()

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp',
  function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
-- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.o.syntax = true
vim.o.filetype = true
vim.o.plugin = true
vim.o.number = true
vim.o.hidden = true
vim.o.noswapfile = true
vim.o.cursorline = true
vim.o.scrolloff = 15
vim.opt.list = true
-- vim.opt.listchars:append 'eol:↵'
vim.opt.listchars:append 'trail:.'
vim.o.autoread = true
vim.o.hlsearch = false
vim.o.mouse = false
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

vim.o.completeopt = 'menuone,noselect'

vim.g.vim_http_tempbuffer = 1
vim.g.vim_http_split_vertically = 1

vim.diagnostic.config({
  virtual_text = {
    -- source = "always",  -- Or "if_many"
    prefix = '●', -- Could be '■', '▎', 'x'
  },
  severity_sort = true,
  float = {
    source = "always", -- Or "if_many"
  },
})

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.api.nvim_create_augroup('DiagnosticsHover', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  group = 'DiagnosticsHover',
  pattern = { "*" },
  callback = function(ev)
    -- Get the current windows
    local wins = vim.api.nvim_list_wins()
    for _, winID in ipairs(wins) do
      -- Check if any of the current windows is a floating, so we don't want to open the diagnostic
      -- and replace that one (Usually any LSP definition or help will open as another float window)
      -- so we only want to open the diagnostic float win when we don't have any other open
      if vim.api.nvim_win_get_config(winID).relative ~= '' then
        return
      end
    end
    vim.diagnostic.open_float()
  end
})

-- Clear trailing whitespaces
vim.api.nvim_create_augroup('TrimTrailingWhitespaces', { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = 'TrimTrailingWhitespaces',
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

function close_current_buffer()
  local buffers = vim.tbl_filter(function(buf)
    if 1 ~= vim.fn.buflisted(buf) then
      return false
    end
    if not vim.api.nvim_buf_is_loaded(buf) then
      return false
    end
    return true
  end, vim.api.nvim_list_bufs())

  if table.getn(buffers) == 1 then
    vim.cmd([[bd]])
    return
  end

  vim.cmd([[bp | bd #]])
end

--vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>rr', '<Plug>RestNvim<CR>', { desc = '[R]est [R]request' })
vim.keymap.set('n', '<leader>rl', '<Plug>RestNvimLast<CR>', { desc = '[R]equest [L]ast executed request' })

vim.keymap.set('n', '<C-h>', ':bp<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<C-l>', ':bn<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<C-s>', ':up<CR>', { desc = 'Save changes' })
vim.keymap.set('i', '<C-s>', '<c-o>:up<CR>', { desc = 'Save changes' })
vim.keymap.set('v', '<C-s>', '<c-c>:up<CR>gv', { desc = 'Save changes' })

vim.keymap.set('n', '<leader>n', ':enew<CR>', { desc = '[N]ew buffer' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Escape' })
vim.keymap.set('v', '<leader>y', '"+y gv', { desc = 'Copy to clipboard' })

vim.keymap.set('n', '<leader>w', close_current_buffer, { desc = 'Close the current buffer' })

vim.keymap.set('n', '<leader>ntt', ':NeoTreeShowToggle<CR>', { desc = '[N]eo [T]ree [T]oggle' })

-- Setup neovim lua configuration
require('neodev').setup()
