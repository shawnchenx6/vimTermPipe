" ------------------------------------------------------------------------------
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_vim2term") || &cp
  finish
endif
let g:loaded_vim2term = 1 
let s:keepcpo           = &cpo
set cpo&vim


let b:line_nl = "\<cr>"

" Public Interface:
nmap <C-Enter> <Plug>SendBlock
vmap <C-Enter> <Plug>SendSelection

" Global Maps:
nnoremap <silent> <script> <Plug>SendBlock
 \ :call <SID>SendBlock()<CR>

vnoremap <silent> <script> <Plug>SendSelection
\ <ESC>:call <SID>SendSelection()<CR>

augroup terminalID
    au!
    au TermOpen * let g:last_term_id = b:terminal_job_id
    au TermOpen * let g:last_term_nr = bufnr('%')
augroup END


function! s:send2term(txt)
    if !exists('g:last_term_id')
        echomsg 'Terminal not started!'
        return
    endif
    if !exists('b:terminal_job_id')
        let b:terminal_job_id = g:last_term_id
        let b:terminal_job_nr = g:last_term_nr
    endif
    let curwin = winnr()
    let winid = win_findbuf(b:terminal_job_nr)
    if len(winid) == 0
        echoerr "terminal window not found"
        return 
    endif
    let winid = winid[0]
    exe win_id2win(winid) . ' wincmd w'
    call cursor('$', 1)
    exe curwin . ' wincmd w'

    if exists('*chansend')
        call chansend(b:terminal_job_id, a:txt)
        exe 'sleep 100m'
        call chansend(b:terminal_job_id, b:line_nl)
    else
        call jobsend(b:terminal_job_id, a:txt)
        exe 'sleep 100m'
        call jobsend(b:terminal_job_id, b:line_nl)
    endif
endfunction

function! s:SendLines(ls)
    if type(a:ls) != 3
        echoerr "Internal Error: argument is not a list. Please contact developer"
    endif

    if len(a:ls) == 1
        call s:send2term(a:ls[0])
    else
        let txt= ""
        for line in a:ls
            if line =~ '\S'
                let txt = txt . line . b:line_nl
            endif
        endfor
        call s:send2term(txt)
    endif
endfunction


function! s:SearchSelection()
    let startp = [line("'<"), col("'<")]
    let endp = [line("'>"), col("'>")]
    return [startp, endp]
endfunction


function! s:SendSelection()
    let range = s:SearchSelection() 
    let startp = range[0]
    let endp = range[1]
    if startp[0] == endp[0]
        let line = getline(startp[0])
        let span = endp[1] - startp[1] + 1
        let line = strpart(line, startp[1]-1, span)
        let lines = [line]
    else
        let lines = getline(startp[0],endp[0])
    endif
    call s:SendLines(lines)
    exe endp[0] + 1
endfunction


function! s:SearchBlock(startl)
    let endMarks=["^}",'^]', '^)', "^end"]
    let startl = a:startl
    let idx = startl + 1
    while idx <= line('$')
        let line = getline(idx)
        if line =~ '^\S'
            for e in endMarks
                if line =~ e
                    return idx
                endif
            endfor
            return idx - 1
        endif
        let idx += 1
    endwhile
    return line('$')
endfunction

function! s:SendBlock()
    let startl = line(".")
    let endl = s:SearchBlock(startl)
    let lines = getline(startl, endl)
    exe endl + 1
    call s:SendLines(lines)
endfunction

let &cpo= s:keepcpo
unlet s:keepcpo

