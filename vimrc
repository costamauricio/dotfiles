silent !stty -ixon

call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'tomasiser/vim-code-dark'
Plug 'gruvbox-community/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdcommenter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

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
set shiftwidth=4
set tabstop=4 softtabstop=4
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

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup PERFORMS
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
augroup END

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>ff :NERDTreeFind<CR>
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>b <cmd>Telescope buffers<cr>
nmap <C-_> <plug>NERDCommenterToggle
vmap <C-_> <plug>NERDCommenterToggle gv
nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>
nnoremap <C-s> :up<CR>
imap <C-s> <c-o>:up<CR>
vmap <C-s> <c-c>:up<CR>gv
nnoremap <leader>w :bp\|bd #<CR>
nnoremap <leader>r :so %<CR>
nnoremap <leader>n :enew<CR>
inoremap jj <Esc>
vnoremap <leader>y "+y gv
nnoremap <S-k> :m-2<CR>
nnoremap <S-j> :m+1<CR>
vnoremap <S-k> :m '<-2<CR>gv
vnoremap <S-j> :m '>+1<CR>gv

autocmd VimLeave * silent !stty ixon
