if exists('g:UnderCursor_loaded')
    finish
endif
let g:UnderCursor_loaded = 1

if !exists('g:UnderCursor_expand_blank')
    let g:UnderCursor_expand_blank = 1
endif

if !exists('g:UnderCursor_enable')
    let g:UnderCursor_enable = 1
endif

call UnderCursor#highlight_init()

augroup UnderCursor
    au!
    autocmd CursorHold,CursorHoldI * call UnderCursor#highlight_word()
    autocmd CursorMoved * call UnderCursor#highlight_select()
augroup End

vnoremap <expr> * "\<Esc>/\\V".escape(UnderCursor#content(), '/')."\<CR>"
vnoremap <expr> # "\<Esc>/\\V".escape(UnderCursor#content(), '?')."\<CR>"
