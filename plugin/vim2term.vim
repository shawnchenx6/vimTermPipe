" ------------------------------------------------------------------------------
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_vim2term") || &cp
    finish
endif
let g:loaded_vim2term = 1 
let s:keepcpo           = &cpo
set cpo&vim

" Public Interface:
" nmap <C-Enter> <Plug>SendBlock
" vmap <C-Enter> <Plug>SendSelection
command  -nargs=1 LinkTerm call s:LinkTerm(<f-args>)

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
        echoerr "Terminal not started!"
        return
    endif

    if !exists('b:terminal_job_id')
        let b:terminal_job_id = g:last_term_id
        let b:terminal_job_nr = g:last_term_nr
    endif

    let curwin = winnr()
    let twinnr = s:BufWinNr(b:terminal_job_nr)
    if twinnr == -1
        echoerr "Terminal window not found!"
        return -1
    endif
    exe twinnr . ' wincmd w'
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

function! s:LinkTerm(...)
    let curwin = winnr()
    let b:terminal_job_nr = str2nr(a:1)
    let twinnr = s:BufWinNr(b:terminal_job_nr)
    if twinnr == -1
        echoerr "Terminal window not found!"
        return -1
    endif
    exe twinnr . ' wincmd w'
    let term_job_id = b:terminal_job_id
    exe curwin . ' wincmd w'
    let b:terminal_job_id = term_job_id
    echomsg "Linked to buffer " . bufname(b:terminal_job_nr)
endfunction

function! s:BufWinNr(bufnr)
    let winid = win_findbuf(a:bufnr)
    if len(winid) == 0
        return -1
    endif
    let winid = winid[0]
    return win_id2win(winid)
endfunction

function! s:SendLines(ls)
    let b:line_nl = "\<cr>"
    if type(a:ls) != 3
        echoerr "Internal Error: Argument should be a list. Please contact developer"
    endif

    call s:listRStrip(a:ls)
    if len(a:ls) == 1
        call s:send2term(a:ls[0])
    else
        let txt = join(a:ls, b:line_nl). b:line_nl
        call s:send2term(txt)
    endif
endfunction

function! s:listRStrip(ls)
    let cur = len(a:ls) - 1
    while cur >= 0
        if a:ls[cur] =~ '\S'
            break
        endif
        call remove(a:ls, cur)
        let cur -= 1
    endwhile
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



