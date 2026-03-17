set autoindent        " Enable automatic indentation
set smartindent       " Enable smart indentation
set tabstop=4         " Set the width of a tab character
set shiftwidth=4      " Set the number of spaces used for each step of (auto)indent
set expandtab         " Convert tabs to spaces
set hlsearch

autocmd FileType markdown syn clear markdownError

cnoreabbrev W w
cnoreabbrev Q q

" Map Ctrl + Up Arrow to move up 5 lines
noremap <C-Up> 5k
inoremap <C-Up> <C-O>5k

" Map Ctrl + Down Arrow to move down 5 lines
noremap <C-Down> 5j
inoremap <C-Down> <C-O>5j

" Map Ctrl+Backspace to delete the previous word in insert mode
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

" Map Ctrl+Del to delete the next word in insert mode
imap <C-Del> <Esc>ldeha

" Switch to hex editor mode
nnoremap <C-x> :%!xxd<CR>
" Switch out of hex editor mode
nnoremap <S-x> :%!xxd -r<CR>

" Map Ctrl+S to the :w command to save the script
nnoremap <C-s> :w<CR>
inoremap <C-s> <C-o>:w<CR>
vnoremap <C-s> <Esc>:w<CR>gv>

" Map Ctrl+Z to undo
nnoremap <C-z> u
inoremap <C-z> <Esc>u
vnoremap <C-z> u

" Map Shift+Tab to reverse indent
inoremap <S-Tab> <Esc>v<a

" Map Alt+Up: move cursor up and scroll page up one line
nnoremap <A-Up> k<C-Y>
inoremap <A-Up>   <Esc>k<C-Y>i

" Map Alt+Down: move cursor down and scroll page down one line
nnoremap <A-Down> j<C-E>
inoremap <A-Down> <Esc>j<C-E>i

" Map Alt+Ctrl+Up Arrow to move up 5 lines and scroll page 5 lines up
nnoremap <C-A-Up>   5k5<C-Y>
inoremap <C-A-Up>   <Esc>5k5<C-Y>i

" Map Alt+Ctrl+Down Arrow to move down 5 lines and scroll page down lines up
nnoremap <C-A-Down> 5j5<C-E>
inoremap <C-A-Down> <Esc>5j5<C-E>i

" Move cursor to mouse click
set mouse=ni
