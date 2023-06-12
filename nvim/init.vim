silent !stty -ixon

call plug#begin('~/.config/nvim/plugged')

"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'gruvbox-community/gruvbox'

"Plug 'ryanoasis/vim-devicons'
"Plug 'vim-airline/vim-airline'
"Plug 'preservim/nerdcommenter'
"Plug 'editorconfig/editorconfig-vim'

"Git Integrations
"Plug 'lewis6991/gitsigns.nvim'
"Plug 'tpope/vim-fugitive'

"LSP and extras
"Plug 'neovim/nvim-lspconfig'
" Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}

"Vimspector
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

"Icons dependency
"Plug 'kyazdani42/nvim-web-devicons'

"File-tree
"Plug 'kyazdani42/nvim-tree.lua'

"Vim-Telescope plugins
"Plug 'nvim-lua/popup.nvim'
"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-telescope/telescope.nvim'
"Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

"Plug 'rest-nvim/rest.nvim'
Plug 'sago35/tinygo.vim'

call plug#end()

"colorscheme gruvbox
"set background=dark
"set termguicolors

"let mapleader = "\<Space>"

filetype plugin indent on
syntax on
"set number
"set relativenumber
" set hidden
"set noswapfile
"set cursorline
"set cursorcolumn
"set scrolloff=15
"set backspace=indent,eol,start
"set list listchars=tab:\│\ ,trail:.
"set autoread
set expandtab
"set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent
set smartindent
"set smartcase
"set mouse=a
"set mouse-=a

"set updatetime=750

"autocmd BufNewFile,BufReadPost *.ino,*.pde set filetype=cpp
autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype php setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab autoindent smartindent

"highlight LspDiagnosticsSignError ctermfg=Red ctermbg=235 guifg=Red guibg=236
"highlight LspDiagnosticsSignWarning ctermfg=Yellow ctermbg=235 guifg=Yellow guibg=235
"highlight LspDiagnosticsSignInformation ctermfg=Blue ctermbg=235 guifg=Blue guibg=235
"highlight LspDiagnosticsSignHint ctermfg=Green ctermbg=235 guifg=Green guibg=235

"highlight SpecialKey ctermfg=238 ctermbg=236 guibg=238 guifg=238
"highlight SignColumn guibg=235 ctermbg=235

"highlight GitSignsAdd ctermfg=Green ctermbg=235 guifg=Green guibg=235
"highlight GitSignsChange ctermfg=Blue ctermbg=235 guifg=Blue guibg=235
"highlight GitSignsDelete ctermfg=Red ctermbg=235 guifg=Red guibg=235

let g:coq_settings = {'keymap.jump_to_mark': v:null, 'auto_start': 'shut-up'}

"let g:vim_http_tempbuffer = 1
"let g:vim_http_split_vertically = 1

"let g:airline_powerline_fonts = 1
"let g:airline_theme = 'gruvbox'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'

"fun! CloseCurrentBuf()
    "let l:opened = len( getbufinfo({'buflisted':1}) )
    "if l:opened == 1
        "execute "enew | bd #"
    "else
        "execute "bp | bd #"
    "endif
"endfun

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup PERFORMS
    atocmd!
    autocmd BufWritePre * :call TrimWhitespace()
    "autocmd CursorHold * lua vim.diagnostic.open_float()
augroup END

lua << EOF
-- require 'gitsigns'.setup()

--- require 'nvim-treesitter.configs'.setup {
---     ensure_installed = {'go', 'javascript', 'php', 'http', 'json'},
---     highlight = {enable = true},
--- }

-- require'nvim-tree'.setup {
--     actions = {
--         open_file = {
--             quit_on_open = false
--         }
--     },
--     git = {
--         ignore = false
--     }
-- }

-- require'nvim-web-devicons'.setup {
--     default = true
-- }

-- require'rest-nvim'.setup { }

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

"nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
"nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
"nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
"nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
"nnoremap <silent> re <cmd>lua vim.lsp.buf.rename()<CR>
"nnoremap <silent> ca <cmd>lua vim.lsp.buf.code_action()<CR>
"nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
"nnoremap <leader>ff <cmd>lua vim.lsp.buf.format({ async = true })<CR>

"nnoremap <leader>nt :NvimTreeToggle<CR>
"nnoremap <leader>nf :NvimTreeFindFile<CR>

"nnoremap <leader>rr <Plug>RestNvim<CR>
"nnoremap <leader>rc <Plug>RestNvimPreview<CR>
"nnoremap <leader>rl <Plug>RestNvimLast<CR>

"nnoremap <C-p> <cmd>lua require'telescope.builtin'.find_files()<cr>
"nnoremap <leader>fg <cmd>lua require'telescope.builtin'.live_grep()<cr>
"nnoremap <leader>fb <cmd>lua require'telescope.builtin'.buffers()<cr>
"nmap <C-_> <plug>NERDCommenterToggle
"vmap <C-_> <plug>NERDCommenterToggle gv
"nmap <C-h> :bp<CR>
"nmap <C-l> :bn<CR>
"nmap <C-s> :up<CR>
"imap <C-s> <c-o>:up<CR>
"vmap <C-s> <c-c>:up<CR>gv
"nnoremap <leader>w :call CloseCurrentBuf()<CR>
nnoremap <leader>r :so %<CR>
"nnoremap <leader>n :enew<CR>
"inoremap jj <Esc>
vnoremap <leader>y "+y gv
"nnoremap <S-k> :m-2<CR>
"nnoremap <S-j> :m+1<CR>
"vnoremap <S-k> :m '<-2<CR>gv
"vnoremap <S-j> :m '>+1<CR>gv

autocmd VimLeave * silent !stty ixon
