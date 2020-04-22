set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tomasiser/vim-code-dark'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'preservim/nerdcommenter'

call vundle#end()

autocmd TerminalOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif

filetype plugin indent on
syntax on
set number
set hidden
set cursorline
"set cursorcolumn
set updatetime=250
let mapleader = ","
colorscheme codedark

highlight GitGutterAdd ctermfg=Green
highlight GitGutterChange ctermfg=Blue
highlight GitGutterDelete ctermfg=Red

let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_removed = '▏'
let g:gitgutter_sign_removed_first_line = '▔'
let g:gitgutter_sign_modified_removed = '▋'

let g:airline_theme = 'codedark'
let g:airline#extensions#tabline#enabled = 1

map <C-n> :NERDTreeToggle<CR>
map <C-p> :FZF<CR>
map <C-h> :bp<CR>
map <C-l> :bn<CR>
map <C-_> <plug>NERDCommenterToggle
map <C-t> :bel term++rows=15<CR>
map <leader>r :so %<CR>
