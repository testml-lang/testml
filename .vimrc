augroup tml_ft
  autocmd!
  autocmd BufNewFile,BufRead *.tml  set ft= sw=2
augroup END

augroup code_ft
  autocmd!
  autocmd BufNewFile,BufRead *.coffee,*.pm,*.py  set sw=2
augroup END

augroup pm6_ft
  autocmd!
  autocmd BufNewFile,BufRead *.pm6  set sw=2
augroup END
