"------------------------------[ options ]-------------------------------------"
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
set cc=80                   " set an 80 column border for good coding style
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " speed up scrolling in vim
set scrolloff=10
set clipboard=unnamed
"------------------------------------------------------------------------------"

" change vim cursor style between modes
"let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"let &t_SR = "\<Esc>]50;CursorShape=2\x7"
"let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" fix cursor shape not changin in tmux
"if exists('$TMUX')
"    let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
"    let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
"else
"    let &t_SI = "\e[5 q"
"    let &t_EI = "\e[2 q"
"endif


filetype plugin on
filetype plugin indent on   " allow auto-indenting depending on file type
syntax on                   " syntax highlighting


"------------------------------[ plugins ]-------------------------------------"
call plug#begin("~/.vim/plugged")
    Plug 'tomasr/molokai'
    Plug 'sainnhe/sonokai'
    Plug 'voldikss/vim-floaterm'
    Plug 'preservim/nerdtree'
call plug#end()

" nerdtree
nnoremap <leader>tt :NERDTreeToggle<cr>
nnoremap <leader>tf :NERDTreeFocus<cr>
nnoremap <leader>tc :NERDTreeClose<cr>

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
"------------------------------------------------------------------------------"


"------------------------------[ mappings ]------------------------------------"

"" move line or visually selected block
inoremap <A-j> <Esc>:m .+1<cr>==gi
inoremap <A-k> <Esc>:m .-2<cr>==gi
vnoremap <A-j> :m '>+1<cr>gv=gv
vnoremap <A-k> :m '<-2<cr>gv=gv

"" move between pane
nnoremap <c-j> <c-w>j
nnoremap <c-h> <c-w>h
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

"" move split panes
nnoremap <A-h> <c-w>H
nnoremap <A-j> <c-w>J
nnoremap <A-k> <c-w>K
nnoremap <A-l> <c-w>L

"" center view
inoremap <C-Z> <Esc>zza
"------------------------------------------------------------------------------"


"------------------------------[ autocommands ]--------------------------------"
" keep cursor at `scrolloff` distance from end of window
augroup KeepFromBottom
    autocmd!
    autocmd CursorMoved * call AvoidBottom()
    autocmd TextChangedI * call AvoidBottom()
augroup END

function AvoidBottom()
    let distance_from_window_end = winheight(0) - winline()
    let lines_below_scrolloff = distance_from_window_end - &scrolloff
    let distance_to_eof = line('$') - line('.')

    let below_scrolloff = lines_below_scrolloff < 0
    let center_instead = winheight(0)/2 <= &scrolloff
    let near_eof = distance_to_eof < &scrolloff && distance_to_eof < winheight(0)/2
    let at_eol = getcursorcharpos()[2] > len(getline('.'))

    " if cursor is below scrolloff distance from bottom of window, scroll the buffer up that number of lines
    if below_scrolloff && near_eof
        if center_instead
            execute 'normal! zz'
            " echo "center"
        else
            let n = -lines_below_scrolloff
            execute 'normal! ' . n . "\<C-E>"
            " echo "scroll: ".n
        endif

        " Fix position of cursor at end of line
        if at_eol
            let cursor_pos = getcursorcharpos()
            let cursor_pos[2] = cursor_pos[2] + 1
            call setcursorcharpos(cursor_pos[1:])
        endif
    else
        " echo "not triggered: ".distance_to_eof
    endif
endfunction
"------------------------------------------------------------------------------"
