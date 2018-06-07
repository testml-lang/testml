" This .vimrc file was created by Vroom-0.37
set nocompatible
syntax on

map <SPACE> :n<CR>:<CR>gg
map <BACKSPACE> :N<CR>:<CR>gg
map R :!vroom -run %<CR>
map RR :!vroom -run %<CR>
map AA :call RunNow()<CR>:<CR>
map VV :!vroom -vroom<CR>
map QQ :q!<CR>
map OO :!open <cWORD><CR><CR>
map EE :e <cWORD><CR>
map !! G:!open <cWORD><CR><CR>
map ?? :e .help<CR>
set laststatus=2
set statusline=%-20f\ TestML\ -\ Acmeist,\ Data-Driven\ Software\ Testing\ Language

" Overrides from /Users/ingy/.vroom/vimrc


" Values from slides.vroom config section. (under 'vimrc')
unmap AA
set nohlsearch
au BufRead * syn match vroom_command "\v^\s*\$.*$"
hi vroom_command  term=bold,italic,underline ctermfg=DarkYellow
map ; /^\s\+\$<cr>
map ' :exec '!clear;printf "=\%.0s" {1..80};echo;' . substitute(getline('.'), '^\s\+\$\s\+', '', '')<cr>
map \1 :w<cr>
map <ENTER> :w<cr>:wincmd w<cr>:<esc>
map 1 :wincmd o<cr>
map 2 :wincmd v<cr>
map = :e #<cr>
map - t/gf

