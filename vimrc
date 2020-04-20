set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tomasiser/vim-code-dark'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf'

call vundle#end()

colorscheme codedark

" Airline
let g:airline_theme = 'codedark'
let g:airline#extensions#tabline#enabled = 1

map <C-n> :NERDTreeToggle<CR>
map <C-p> :FZF<CR>
map <C-h> :wincmd h<CR>
map <C-l> :wincmd l<CR>

filetype plugin indent on
syntax on
set number
set hidden
