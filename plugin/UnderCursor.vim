if exists('g:UnderCursor_loaded')
    finish
endif
let g:UnderCursor_loaded = 1

call UnderCursor#highlight_init()

augroup UnderCursor
    au!
    autocmd CursorHold,CursorHoldI * call UnderCursor#highlight_word()
    autocmd CursorMoved * call UnderCursor#highlight_select()
augroup End

vnoremap <expr> * "\<Esc>/\\V".escape(UnderCursor#content(), '/')."\<CR>"
vnoremap <expr> # "\<Esc>/\\V".escape(UnderCursor#content(), '?')."\<CR>"
