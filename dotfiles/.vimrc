set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completion
set cc=90                   " set an 80 column border for good coding style
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " speed up scrolling in vim

filetype plugin on
filetype plugin indent on   " allow auto-indenting depending on file type
syntax on                   " syntax highlighting

call plug#begin("~/.vim/plugged")

Plug 'tomasr/molokai'
Plug 'sainnhe/sonokai'
Plug 'voldikss/vim-floaterm'

call plug#end()

" floaterm config
let g:floaterm_opener = 'edit'

let g:floaterm_position = 'bottom'
let g:floaterm_width = 1.0
let g:floaterm_height = 0.4

" let g:floaterm_keymap_new = '<leader>t'
let g:floaterm_keymap_toggle = '<leader>c'
"nmap <c-t> :FloatermNew fff<cr>

" color scheme
colorscheme sonokai
