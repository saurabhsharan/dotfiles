set expandtab
set tabstop=2
set shiftwidth=2
set smarttab
match Error /\t/

set smartindent
set autoindent

filetype indent on

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

set list
set listchars=tab:>-,trail:.,extends:#,nbsp:.

set showmatch " flashes matching paren when one is typed

set smartcase

let &titlestring = @%
set title
