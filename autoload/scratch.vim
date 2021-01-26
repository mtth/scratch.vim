" autoload/scratch.vim

" window handling

function! s:activate_autocmds(bufnr)
  if g:scratch_autohide
    augroup ScratchAutoHide
      autocmd!
      execute 'autocmd WinEnter <buffer=' . a:bufnr . '> nested call <SID>close_window(0)'
      execute 'autocmd Winleave <buffer=' . a:bufnr . '> nested call <SID>close_window(1)'
    augroup END
  endif
endfunction

function! s:deactivate_autocmds()
  augroup ScratchAutoHide
    autocmd!
  augroup END
endfunction

function! s:open_window(position)
  " open scratch buffer window and move to it. this will create the buffer if
  " necessary.
  let scr_bufnr = bufnr('__Scratch__')
  if scr_bufnr == -1
    let cmd = g:scratch_horizontal ? 'new' : 'vnew'
    execute a:position . s:resolve_size(g:scratch_height) . cmd . ' __Scratch__'
    execute 'setlocal filetype=' . g:scratch_filetype
    setlocal bufhidden=hide
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal foldcolumn=0
    setlocal nofoldenable
    setlocal nonumber
    setlocal noswapfile
    setlocal winfixheight
    setlocal winfixwidth
    if strlen(g:scratch_persistence_file) > 0
      if filereadable(fnamemodify(g:scratch_persistence_file, ':p'))
        let cpo = &cpo
        set cpo-=a
        execute ':r ' . g:scratch_persistence_file
        let &cpo = cpo
        execute 'normal! ggdd'
      endif
    endif
    call s:activate_autocmds(bufnr('%'))
  else
    let scr_winnr = bufwinnr(scr_bufnr)
    if scr_winnr != -1
      if winnr() != scr_winnr
        execute scr_winnr . 'wincmd w'
      endif
    else
      let cmd = g:scratch_horizontal ? 'split' : 'vsplit'
      execute a:position . s:resolve_size(g:scratch_height) . cmd . ' +buffer' . scr_bufnr
    endif
  endif
endfunction

function! s:close_window(force)
  " close scratch window if it is the last window open, or if force
  if strlen(g:scratch_persistence_file) > 0
    execute ':w! ' . g:scratch_persistence_file
  endif
  if a:force
    let prev_bufnr = bufnr('#')
    let scr_bufnr = bufnr('__Scratch__')
    if scr_bufnr != -1
      " Temporarily deactivate these autocommands to prevent overflow, but
      " still allow other autocommands to be executed.
      call s:deactivate_autocmds()
      close
      execute bufwinnr(prev_bufnr) . 'wincmd w'
      call s:activate_autocmds(scr_bufnr)
    endif
  elseif winbufnr(2) == -1
    if tabpagenr('$') == 1
      bdelete
      quit
    else
      close
    endif
  endif
endfunction

" utility

function! s:resolve_size(size)
  " if a:size is an int, return that number, else it is a float
  " interpret it as a fraction of the screen size and return the
  " corresponding number of lines
  if has('float') && type(a:size) ==# 5 " type number for float
    let win_size = g:scratch_horizontal ? winheight(0) : winwidth(0)
    return float2nr(a:size * win_size)
  else
    return a:size
  endif
endfunction

function! s:quick_insert()
  " leave scratch window after leaving insert mode and remove corresponding autocommand
  augroup ScratchInsertAutoHide
    autocmd!
  augroup END
  execute bufwinnr(bufnr('#')) . 'wincmd w'
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
    silent execute '%d _'
  else
    silent execute 'normal! G$'
  endif
endfunction

function! scratch#insert(reset)
  " open scratch buffer
  call scratch#open(a:reset)
  if g:scratch_insert_autohide
    augroup ScratchInsertAutoHide
      autocmd!
      autocmd InsertLeave <buffer> nested call <SID>quick_insert()
    augroup END
  endif
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

function! scratch#preview()
  " toggle scratch window, keeping cursor in current window
  let scr_winnr = bufwinnr('__Scratch__')
  if scr_winnr != -1
    execute scr_winnr . 'close'
  else
    call scratch#open(0)
    call s:deactivate_autocmds()
    execute bufwinnr(bufnr('#')) . 'wincmd w'
    call s:activate_autocmds(bufnr('__Scratch__'))
  endif
endfunction
