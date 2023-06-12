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
  'tpope/vim-fugitive',
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
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
    'ms-jpq/coq_nvim',
    branch = 'coq',
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
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  { 'numToStr/Comment.nvim',        opts = {} },
  { 'kyazdani42/nvim-web-devicons', opts = {} },
  {
    'rest-nvim/rest.nvim',
    opts = {},
    dependencies = { 'nvim-lua/plenary.nvim' },
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
        lualine_a = { 'buffers' },
        lualine_z = { 'tabs' },
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
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },
}, {})

vim.o.syntax = true
vim.o.filetype = true
vim.o.plugin = true
vim.o.number = true
vim.o.hidden = true
vim.o.noswapfile = true
vim.o.cursorline = true
vim.o.scrolloff = 15
--vim.o.backspace = 'ident,eol,start'
--vim.o.list = 'tab:|,trail:.'
--vim.o.listchars = 'tab:|,trail:.'
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

vim.keymap.set('n', '<leader>w', close_current_buffer, { desc = 'Close the current buffer' })

vim.keymap.set('n', '<leader>ntt', ':NeoTreeShowToggle<CR>', { desc = '[N]eo [T]ree [T]oggle' })

-- Setup neovim lua configuration
require('neodev').setup()

