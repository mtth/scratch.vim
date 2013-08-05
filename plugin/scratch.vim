" plugin/scratch.vim

if (exists('g:scratch_disable') && g:scratch_disable) || &compatible
  finish
endif

if !exists('g:scratch_autohide')
  let g:scratch_autohide = 1
endif
if !exists('g:scratch_height')
  let g:scratch_height = 10
endif
if !exists('g:scratch_top')
  let g:scratch_top = 1
endif

command! -bang -nargs=0 Scratch call scratch#open(<bang>0)
command! -bang -nargs=0 ScratchInsert call scratch#insert(<bang>0)
command! -bang -nargs=0 -range ScratchSelection call scratch#selection(<bang>0)

nnoremap <silent> gs :call scratch#insert(0)<cr>
nnoremap <silent> gS :call scratch#insert(1)<cr>
xnoremap <silent> gs :<c-u>call scratch#selection(0)<cr>
xnoremap <silent> gS :<c-u>call scratch#selection(1)<cr>
nnoremap gZzZz gs
