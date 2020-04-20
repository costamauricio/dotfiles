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

call vundle#end()

colorscheme codedark

" Airline
let g:airline_theme = 'codedark'
let g:airline#extensions#tabline#enabled = 1

let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_removed = '▏'
let g:gitgutter_sign_removed_first_line = '▔'
let g:gitgutter_sign_modified_removed = '▋'

map <C-n> :NERDTreeToggle<CR>
map <C-p> :FZF<CR>
map <C-h> :bp<CR>
map <C-l> :bn<CR>

filetype plugin indent on
syntax on
set number
set hidden
"set cursorline
"set cursorcolumn
