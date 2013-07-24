" scratch.vim plugin

if !exists('g:scratch_autohide')
  let g:scratch_autohide = 1
endif
if !exists('g:scratch_height')
  let g:scratch_height = [10, 20]
endif
if !exists('g:scratch_insert')
  let g:scratch_insert = 1
endif

command! -bang -nargs=0 Scratch call scratch#open(<bang>0)

nnoremap gs :call scratch#open(0)<cr>
nnoremap gS :call scratch#open(1)<cr>
vnoremap gs :call scratch#add_and_open(0)<cr>
nnoremap gZzZz gs
