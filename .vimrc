set expandtab " pressing tab will actually insert spaces
set tabstop=2 " number of spaces to insert when tab is pressed
set shiftwidth=2 " number of spaces for indentation
set smarttab " auto-insert indentation

set mouse=a " allow mouse reporting

set smartindent " adjust indentation based on file syntax
set autoindent " apply indentation of current line to next line (when pressing Enter or o)

set backspace=indent,eol,start " fixes some issue with delete key not working in iTerm, via https://apple.stackexchange.com/a/174351

set showmatch " flashes matching paren when one is typed

" hybrid line numbers shows relative line numbers for all lines except the current line
set number relativenumber
set nu rnu

" Yank will copy to system clipboard https://clay-atlas.com/us/blog/2021/09/17/mac-os-en-copy-paste-vim/
set clipboard=unnamed

" search is case-insensitive for all lower case, will match case otherwise
set ignorecase
set smartcase

set incsearch " show incremental search results during typing
set hlsearch " highlight all search results

" clear last search highlight by pressing Enter, via https://stackoverflow.com/a/662914
nnoremap <CR> :noh<CR><CR>

filetype indent on

syntax on

" Force .v files to use Verilog syntax highlighting, via https://stackoverflow.com/a/28117335
au BufRead,BufNewFile *.v set filetype=verilog

set statusline+=%F
set laststatus=2

" per introduction in https://dev.to/iggredible/using-buffers-windows-and-tabs-efficiently-in-vim-56jc
set hidden

let &titlestring = @%
set title

set noerrorbells
set novisualbell
set t_vb=
autocmd! GUIEnter * set vb t_vb=

:set guifont=Menlo\ Regular:h15

" configure code folding
set foldmethod=syntax " use syntax highlighter for identifying folds
set foldcolumn=1
let javaScript_fold=1
set foldlevelstart=99 " start file with all folds open
" use space bar to toggle open/close folds in normal mode, via https://vim.fandom.com/wiki/Folding#Mappings_to_toggle_folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

" Update iTerm window title with current buffer filename via https://gist.github.com/bignimbus/1da46a18416da4119778
function! SetTerminalTitle()
    let titleString = expand('%:t')
    if len(titleString) > 0
        let &titlestring = expand('%:t')
        " this is the format iTerm2 expects when setting the window title
        let args = "\033];".&titlestring."\007"
        let cmd = 'silent !echo -e "'.args.'"'
        execute cmd
        redraw!
    endif
endfunction
autocmd BufEnter * call SetTerminalTitle()

:command WQ wq
:command Wq wq
command W w
command Q q

" let g:mapleader = ","

" nmap F <Plug>(easymotion-prefix)s

packadd minpac

call minpac#init()

" Run :PackUpdate after adding a new plugin
" Run :PackClean after removing a plugin
call minpac#add('mhinz/vim-startify')
call minpac#add('tomlion/vim-solidity')
call minpac#add('easymotion/vim-easymotion')
call minpac#add('mattn/emmet-vim')
call minpac#add('alvan/vim-closetag')
" call minpac#add('wincent/terminus')
call minpac#add('justinmk/vim-sneak')
call minpac#add('Valloric/MatchTagAlways')
call minpac#add('AndrewRadev/tagalong.vim')
call minpac#add('vim-airline/vim-airline')
call minpac#add('kshenoy/vim-signature')
call minpac#add('tpope/vim-surround')

call minpac#add('scrooloose/nerdtree')
nmap <C-f> :NERDTreeToggle<CR>
" automatically start nerdtree when opening any file
" autocmd VimEnter * NERDTree
let g:NERDTreeIgnore = ['^build$', '^node_modules$']

call minpac#add('junegunn/vim-easy-align')
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

call minpac#add('neoclide/coc.nvim')

" web/frontend/css/js plugins
call minpac#add('pangloss/vim-javascript')
call minpac#add('leafgarland/typescript-vim')
call minpac#add('MaxMEllon/vim-jsx-pretty')
call minpac#add('peitalin/vim-jsx-typescript')
call minpac#add('neoclide/coc-tsserver')
let g:coc_global_extensions = [
    \ 'coc-tsserver'
    \ ]

call minpac#add('ctrlpvim/ctrlp.vim')
" from https://github.com/kien/ctrlp.vim/issues/174#issuecomment-49747252
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

call minpac#add('adelarsq/vim-matchit')
runtime macros/matchit.vim

" clojure plugins
call minpac#add('dense-analysis/ale')
let g:ale_linters = {'clojure': ['clj-kondo']}

call minpac#add('luochen1990/rainbow')
let g:rainbow_active = 1

call minpac#add('tpope/vim-fireplace')
call minpac#add('bhurlow/vim-parinfer')
call minpac#add('clojure-vim/async-clj-omni')
call minpac#add('guns/vim-clojure-static')

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()
