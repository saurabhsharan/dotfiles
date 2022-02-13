set expandtab
set tabstop=2
set shiftwidth=2
set smarttab

set nocompatible

set smartindent
set autoindent

filetype plugin indent on

syntax on

set incsearch
set hlsearch

set number

:command WQ wq
:command Wq wq
command W w
command Q q

set statusline+=%F
set laststatus=2

" set list
" set listchars=tab:>-,trail:.,extends:#,nbsp:.

set showmatch " flashes matching paren when one is typed

set smartcase

let &titlestring = @%
set title

set backspace=indent,eol,start

packadd minpac
call minpac#init()

call minpac#add('mattn/emmet-vim')
call minpac#add('junegunn/fzf')
call minpac#add('tpope/vim-projectionist')
call minpac#add('itchyny/lightline.vim')
call minpac#add('scrooloose/nerdtree')
call minpac#add('tomlion/vim-solidity')

" Clojure plugins
call minpac#add('guns/vim-clojure-static')
call minpac#add('tpope/vim-fireplace')
" call minpac#add('kien/rainbow_parentheses.vim')
" let g:rainbow_active = 1
call minpac#add('guns/vim-sexp')
call minpac#add('tpope/vim-sexp-mappings-for-regular-people')
call minpac#add('guns/vim-clojure-highlight')
call minpac#add('easymotion/vim-easymotion')
call minpac#add('mileszs/ack.vim')
call minpac#add('luochen1990/rainbow')
call minpac#add('romainl/vim-cool')
call minpac#add('tpope/vim-fugitive')

let g:ackprg = 'ag --nogroup --nocolor --column'

" <C-p> to activate fzf
nnoremap <C-p> :<C-u>FZF<CR>

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()

" map <C-o> :NERDTreeToggle<CR>

:nnoremap <F5> "=strftime('%b %d, %Y %I:%M %p')<CR>P
