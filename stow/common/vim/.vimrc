# enable modern features
set nocompatible

# arrow keys should work in insert mode
inoremap <Up> <C-o>k
inoremap <Down> <C-o>j
inoremap <Left> <C-o>h
inoremap <Right> <C-o>l
# map command s to save file
imap <D-s> <Esc>:w<CR>a 
