" scratch.vim plugin

if !exists('g:scratch_autohide')
  let g:scratch_autohide = 1
endif
if !exists('g:scratch_height')
  let g:scratch_height = 10
endif
if !exists('g:scratch_insert')
  let g:scratch_insert = 1
endif

command! -bang -nargs=0 Scratch call scratch#open(<bang>0, 0)

nnoremap gs :call scratch#open(0, 0)<cr>
nnoremap gS :call scratch#open(1, 0)<cr>
vnoremap gs :call scratch#open(0, 1)<cr>
nnoremap gZzZz gs
