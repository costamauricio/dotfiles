silent !stty -ixon

call plug#begin('~/.vim/plugged')

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'gruvbox-community/gruvbox'

Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdcommenter'
Plug 'editorconfig/editorconfig-vim'

"Git Integrations
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

"LSP and extras
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}

"Vimspector
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

"Icons dependency
Plug 'kyazdani42/nvim-web-devicons'

"File-tree
Plug 'kyazdani42/nvim-tree.lua'

"Vim-Telescope plugins
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'nicwest/vim-http'

call plug#end()

colorscheme gruvbox
set background=dark
set termguicolors

let mapleader = "\<Space>"

filetype plugin indent on
syntax on
set number relativenumber
set nu rnu
set hidden
set noswapfile
set cursorline
"set cursorcolumn
set scrolloff=15
set backspace=indent,eol,start
set list listchars=tab:\│\ ,trail:.
set autoread
set expandtab
set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent
set smartindent
set smartcase

set updatetime=750

"autocmd BufNewFile,BufReadPost *.ino,*.pde set filetype=cpp
autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2

highlight LspDiagnosticsSignError ctermfg=Red ctermbg=235 guifg=Red guibg=235
highlight LspDiagnosticsSignWarning ctermfg=Yellow ctermbg=235 guifg=Yellow guibg=235
highlight LspDiagnosticsSignInformation ctermfg=Blue ctermbg=235 guifg=Blue guibg=235
highlight LspDiagnosticsSignHint ctermfg=Green ctermbg=235 guifg=Green guibg=235

highlight SpecialKey ctermfg=238 ctermbg=236 guibg=238 guifg=238
highlight SignColumn guibg=235 ctermbg=235

highlight GitGutterAdd ctermfg=Green ctermbg=235 guifg=Green guibg=235
highlight GitGutterChange ctermfg=Blue ctermbg=235 guifg=Blue guibg=235
highlight GitGutterDelete ctermfg=Red ctermbg=235 guifg=Red guibg=235

let g:coq_settings = {'keymap.jump_to_mark': v:null, 'auto_start': 'shut-up'}

let g:vim_http_tempbuffer = 1
let g:vim_http_split_vertically = 1

let g:nvim_tree_quit_on_open = 1

let g:gitgutter_sign_allow_clobber = 0
let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_removed = '▏'
let g:gitgutter_sign_removed_first_line = '▔'
let g:gitgutter_sign_modified_removed = '▋'

let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

fun! CloseCurrentBuf()
    let l:opened = len( getbufinfo({'buflisted':1}) )
    if l:opened == 1
        execute "enew | bd #"
    else
        execute "bp | bd #"
    endif
endfun

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup PERFORMS
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
    autocmd CursorHold * lua vim.diagnostic.open_float()
augroup END

lua << EOF
require 'nvim-treesitter.configs'.setup {
    ensure_installed = 'maintained',
    highlight = {enable = true},
}

require'nvim-tree'.setup {}

-- require('vim.lsp.log').set_level('debug')
local util = require'lspconfig/util'

-- Check for an existant prettierrc* to enable formatting with prettier or tsserver
local function prettier_config_exists()
    local eslintrc = vim.fn.glob(".prettier*", true, true)

    if not vim.tbl_isempty(eslintrc) then
        return true
    end

    return false
end

local function format_diagnostics(params, client_id, client_name, filter_out)
    for i, diagnostic in ipairs(params.diagnostics) do
        if filter_out ~= nil and filter_out(diagnostic) then
            params.diagnostics[i] = nil
        else
            diagnostic.message = '['.. client_name ..'] '..diagnostic.message..' ['..(diagnostic.code or '')..']'
        end
    end

    return require('vim.lsp.diagnostic').on_publish_diagnostics(nil, params, client_id)
end

local function filter_commonjs_diagnostics(diagnostic)
    if diagnostic.severity == 4 and diagnostic.code ~= 6133 then
        return true
    end

    return false
end

local lspconfig = require'lspconfig'
local coq = require'coq'

-- npm install -g typescript typescript-language-server
lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
    on_attach=function(client)
        if prettier_config_exists() then
            client.resolved_capabilities.document_formatting = false
        end
    end,
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "TSServer", filter_commonjs_diagnostics)
        end
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "json"
    },
    flags = {
        allow_incremental_sync = true
    }
}))

local eslint = {
    lintCommand = "npx --no-install eslint -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "npx --no-install prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}

-- install efm-langserver
lspconfig.efm.setup{
    on_attach=function(client)
        if not prettier_config_exists() then
            client.resolved_capabilities.document_formatting = false
        end

        client.resolved_capabilities.goto_definition = false
    end,
    init_options = {
        documentFormatting = true,
    },
    root_dir = util.root_pattern('.eslintrc*', '.prettierr*'),
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "ESLint")
        end
    },
    settings = {
        languages = {
            javascript = {eslint},
            javascriptreact = {eslint},
            ["javascript.jsx"] = {eslint},
            typescript = {eslint},
            ["typescript.tsx"] = {eslint},
            typescriptreact = {eslint}
        }
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescript.tsx",
        "typescriptreact"
    },
}

-- install gopls
lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
    cmd = {"gopls", "serve"},
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}))

EOF

" Use <Tab> and <S-Tab> to navigate through popup menu
"inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"" Set completeopt to have a better completion experience
"set completeopt=menuone,noinsert,noselect

"" Avoid showing message extra message when using completion
"set shortmess+=c


"Shortcuts
"imap <tab> <Plug>(completion_smart_tab)
"imap <s-tab> <Plug>(completion_smart_s_tab)

nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> re <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>ff <cmd>lua vim.lsp.buf.formatting()<CR>

nnoremap <leader>nt :NvimTreeToggle<CR>
nnoremap <leader>nf :NvimTreeFindFile<CR>
nnoremap <C-p> <cmd>lua require'telescope.builtin'.find_files({hidden = true})<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nmap <C-_> <plug>NERDCommenterToggle
vmap <C-_> <plug>NERDCommenterToggle gv
nmap <C-h> :bp<CR>
nmap <C-l> :bn<CR>
nmap <C-s> :up<CR>
imap <C-s> <c-o>:up<CR>
vmap <C-s> <c-c>:up<CR>gv
nnoremap <leader>w :call CloseCurrentBuf()<CR>
nnoremap <leader>r :so %<CR>
nnoremap <leader>n :enew<CR>
inoremap jj <Esc>
vnoremap <leader>y "+y gv
"nnoremap <S-k> :m-2<CR>
"nnoremap <S-j> :m+1<CR>
"vnoremap <S-k> :m '<-2<CR>gv
"vnoremap <S-j> :m '>+1<CR>gv

lua << EOF
require('telescope').setup {
    defaults = {
        file_ignore_patterns = {'.git/'}
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}
require'telescope'.load_extension('fzy_native')
require'nvim-web-devicons'.setup {
    default = true
}
EOF

autocmd VimLeave * silent !stty ixon
