" scratch.vim autoload

function! scratch#open(reset)
  " open scratch buffer
  let scr_bufnum = bufnr('__Scratch__')
  if scr_bufnum == -1
    execute 'new __Scratch__'
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal buftype=nofile
    setlocal foldcolumn=0
    setlocal nofoldenable
    setlocal nonumber
    setlocal noswapfile
    setlocal scrolloff=0
    setlocal winfixheight
  else
    let scr_winnum = bufwinnr(scr_bufnum)
    if scr_winnum != -1
      if winnr() != scr_winnum
        execute scr_winnum . "wincmd w"
      endif
    else
      execute "split +buffer" . scr_bufnum
    endif
    if a:reset
      silent execute '%d'
    endif
  endif
  call s:resize_scratch()
endfunction

function! scratch#add_and_open(reset) range
  " open scratch buffer with current line selection
  let selected_lines = getline(a:firstline, a:lastline)
  call scratch#open(a:reset)
  let current_scratch_line = line('$')
  if !strlen(getline(current_scratch_line))
    " line is empty, we overwrite it
    let current_scratch_line -= 1
  endif
  call append(current_scratch_line, selected_lines)
  silent execute 'normal! G'
  call s:resize_scratch()
endfunction

function! s:resize_scratch()
  " size window appropriately
  execute 'wincmd K'
  let total_lines = line('$')
  let min_height = g:scratch_height[0]
  let max_height = g:scratch_height[1]
  let height = min([max_height, max([min_height, total_lines])])
  execute "resize " . height
endfunction

function! s:on_enter_scratch()
  " quit if scratch is last window open (or close tab)
  if winbufnr(2) ==# -1
    if tabpagenr('$') ==# 1
      bdelete
      quit
    else
      close
    endif
  endif
endfunction

augroup scratch
  autocmd!
  autocmd BufEnter __Scratch__ call s:on_enter_scratch()
  if g:scratch_autohide
    autocmd BufLeave __Scratch__ close
  endif
augroup end
