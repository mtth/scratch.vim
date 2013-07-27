" scratch.vim autoload
"

function! scratch#open(reset, selection) range
  " open scratch buffer
  if bufname('%') ==# '[Command Line]'
    echoerr 'Unable to open scratch buffer from command line window.'
    return
  endif
  let selected_lines = getline(a:firstline, a:lastline)
  let scr_bufnum = bufnr('__Scratch__')
  if scr_bufnum == -1
    execute 'topleft ' . g:scratch_height . 'new __Scratch__'
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal buftype=nofile
    setlocal filetype=scratch
    setlocal foldcolumn=0
    setlocal nofoldenable
    setlocal nonumber
    setlocal noswapfile
    setlocal winfixheight
  else
    let scr_winnum = bufwinnr(scr_bufnum)
    if scr_winnum != -1
      if winnr() != scr_winnum
        execute scr_winnum . 'wincmd w'
      endif
    else
      execute 'topleft ' . g:scratch_height . 'split +buffer' . scr_bufnum
    endif
    if a:reset
      silent execute '%d'
    endif
  endif
  if a:selection
    " paste selection in scratch buffer
    let current_scratch_line = line('$')
    if !strlen(getline(current_scratch_line))
      " line is empty, we overwrite it
      let current_scratch_line -= 1
    endif
    call append(current_scratch_line, selected_lines)
    " remove indents and go to end
    normal gg=GG
  endif
  if g:scratch_insert
    startinsert!
  endif
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

function! s:close_scratch()
  " close scratch window and return to previous buffer
  let prev_bufnr = bufnr('#')
  close
  execute bufwinnr(prev_bufnr) . 'wincmd w'
endfunction

augroup scratch
  autocmd!
  autocmd BufEnter __Scratch__ call <SID>on_enter_scratch()
  if g:scratch_autohide
    if g:scratch_insert
      autocmd InsertLeave __Scratch__ nested call <SID>close_scratch()
    else
      autocmd BufLeave __Scratch__ nested call <SID>close_scratch()
    endif
  endif
augroup END

" BUG: <c-c> seems to trigger InsertLeave sometimes.
