silent !stty -ixon

call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'gruvbox-community/gruvbox'

Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdcommenter'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'
Plug 'ryanoasis/vim-devicons'

"LSP and extras
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'

"Vimspector
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

"Vim-Telescope plugins
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

"Javascript plugins
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

"autocmd BufNewFile,BufReadPost *.ino,*.pde set filetype=cpp

colorscheme gruvbox
set background=dark

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

autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2

let NERDTreeShowHidden=1
let g:NERDTreeIgnore = ['^\.git']

highlight SpecialKey ctermfg=238 ctermbg=236

highlight GitGutterAdd ctermfg=Green ctermbg=237
highlight GitGutterChange ctermfg=Blue ctermbg=237
highlight GitGutterDelete ctermfg=Red ctermbg=237

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
    autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
augroup END

lua << EOF
-- require('vim.lsp.log').set_level('debug')
local util = require'lspconfig/util'

-- npm install -g typescrypt typescrypt-language-server
require'lspconfig'.tsserver.setup{
    on_attach=function(client)
        vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
        client.resolved_capabilities.document_formatting = false
        require'completion'.on_attach(client)
    end
}

local eslint = {
    lintCommand = "npx --no-install eslint -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "npx --no-install prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}

-- install efm-langserver
require'lspconfig'.efm.setup{
    on_attach=function(client)
        client.resolved_capabilities.hover = false
        client.resolved_capabilities.documentSymbol = false
        client.resolved_capabilities.codeAction = false
        client.resolved_capabilities.completion = false
        client.resolved_capabilities.document_formatting = true
    end,
    root_dir = util.root_pattern('.eslintrc*', '.prettierr*'),
    settings = {
        languages = {
            typescript = {eslint},
            javascript = {eslint},
            typescriptreact = {eslint},
            javascriptreact = {eslint}
        }
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact"
  },
}
EOF

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

imap <tab> <Plug>(completion_smart_tab)
imap <s-tab> <Plug>(completion_smart_s_tab)

nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> re <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>ff <cmd>lua vim.lsp.buf.formatting()<CR>

nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nmap <C-_> <plug>NERDCommenterToggle
vmap <C-_> <plug>NERDCommenterToggle gv
nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>
nnoremap <C-s> :up<CR>
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
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}
require'telescope'.load_extension('fzy_native')
EOF

autocmd VimLeave * silent !stty ixon
