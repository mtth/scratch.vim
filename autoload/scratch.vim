" autoload/scratch.vim

" window handling

function! s:open_window(position)
  " open scratch buffer window and move to it
  " this will create the buffer if necessary
  let scr_bufnum = bufnr('__Scratch__')
  if scr_bufnum == -1
    execute a:position . g:scratch_height . 'new __Scratch__'
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal buftype=nofile
    setlocal filetype=scratch
    setlocal foldcolumn=0
    setlocal nofoldenable
    setlocal nonumber
    setlocal noswapfile
    setlocal winfixheight
    if g:scratch_autohide
      autocmd BufEnter <buffer> call <SID>close_window(0)
      autocmd BufLeave <buffer> call <SID>close_window(g:scratch_autohide)
    endif
  else
    let scr_winnum = bufwinnr(scr_bufnum)
    if scr_winnum != -1
      if winnr() != scr_winnum
        execute scr_winnum . 'wincmd w'
      endif
    else
      execute a:position . g:scratch_height . 'split +buffer' . scr_bufnum
    endif
  endif
endfunction

function! s:close_window(force)
  " close scratch window if it is the last window open, or if force
  if a:force
    let prev_bufnr = bufnr('#')
    close
    execute bufwinnr(prev_bufnr) . 'wincmd w'
  elseif winbufnr(2) ==# -1
    if tabpagenr('$') ==# 1
      bdelete
      quit
    else
      close
    endif
  endif
endfunction

" utility

function! s:quick_insert()
  " leave scratch window after leaving insert mode and remove corresponding autocommand
  autocmd! InsertLeave <buffer>
  call s:close_window(1)
endfunction

function! s:get_selection()
  " get current selection as list of lines, preserving registers
  let [contents, type] = [getreg('"'), getregtype('"')]
  try
    execute 'normal! gvy'
    return split(getreg('"'), '\n')
  finally
    call setreg('"', contents, type)
  endtry
endfunction

" public functions

function! scratch#open(reset)
  " sanity check and open scratch buffer
  if bufname('%') ==# '[Command Line]'
    echoerr 'Unable to open scratch buffer from command line window.'
    return
  endif
  let position = g:scratch_top ? 'topleft ' : 'botright '
  call s:open_window(position)
  if a:reset
    silent execute '%d'
  else
    silent execute 'normal! G$'
  endif
endfunction

function! scratch#insert(reset)
  " open scratch buffer
  call scratch#open(a:reset)
  autocmd InsertLeave <buffer> call <SID>quick_insert()
  startinsert!
endfunction

function! scratch#selection(reset) range
  " paste selection in scratch buffer
  let selection = s:get_selection()
  call scratch#open(a:reset)
  let last_scratch_line = line('$')
  if last_scratch_line ==# 1 && !strlen(getline(1))
    " line is empty, we overwrite it
    call append(0, selection)
    silent execute 'normal! Gdd$'
  else
    call append(last_scratch_line, selection)
    silent execute 'normal! G$'
  endif
  " remove trailing white space
  silent! execute '%s/\s\+$/'
endfunction
