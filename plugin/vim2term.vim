" ------------------------------------------------------------------------------
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_vim2term") || &cp
  finish
endif
let g:loaded_vim2term = 1 " your version number
let s:keepcpo           = &cpo
set cpo&vim

" Public Interface:
" AppFunction: is a function you expect your users to call
" PickAMap: some sequence of characters that will run your AppFunction
" Repeat these three lines as needed for multiple functions which will
" be used to provide an interface for the user
nmap <C-Enter> <Plug>SendBlock
vmap <C-Enter> <Plug>SendSelection

" Global Maps:

nnoremap <silent> <unique> <script> <Plug>SendBlock
 \ :set lz<CR>:call <SID>SendBlock()<CR>:set nolz<CR>

vnoremap <silent> <unique> <script> <Plug>SendSelection
 \ :set lz<CR> <Esc>:call <SID>SendSelection()<CR>:set nolz<CR>

" nnoremap <silent> <C-Enter> :call SendBlock()<CR>
" vnoremap <silent> <C-Enter> <Esc>:call SendSelection()<CR>

augroup terminalID
    au!
    au TermOpen * let g:last_term_id = b:terminal_job_id
    au TermOpen * let g:last_term_nr = bufnr('%')
augroup END


function! s:Vim2Termial(...)
    let b:line_nl = "\<cr>"
    if !exists('b:terminal_job_id')
        let b:terminal_job_id = g:last_term_id
        let b:terminal_job_nr = g:last_term_nr
    endif
    let curwin = winnr()
    let winid = win_findbuf(b:terminal_job_nr)
    if len(winid) == 0
        echoerr "terminal window not found. bufnr: ". b:terminal_job_nr 
        return
    endif
    let winid = winid[0]
    exe win_id2win(winid) . ' wincmd w'
    call cursor('$', 1)
    exe curwin . ' wincmd w'

    if exists('*chansend')
        call chansend(b:terminal_job_id, a:1 . b:line_nl)
    else
        call jobsend(b:terminal_job_id, a:1 .b:line_nl)
    endif
endfunction


function! s:SendSelection()
    let b:line_nl = "\<cr>"
    if line("'<") == line("'>")
        let i = col("'<") - 1
        let j = col("'>") - i
        let l = getline("'<")
        let line = strpart(l, i, j)
        call s:Vim2Termial(line)
    else
        let lines = getline("'<", "'>")
        let lines += ['']
        call s:Vim2Termial(join(lines, b:line_nl))
    endif
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
    let endMarks=["^}","^end"]
    let b:line_nl = "\<cr>"
    let startl = line(".")
    let endl = s:SearchBlock(startl)
    let lines = getline(startl, endl)
    let lines += ['']
    call s:Vim2Termial(join(lines, b:line_nl))
    exe endl + 1
endfunction

let &cpo= s:keepcpo
unlet s:keepcpo

