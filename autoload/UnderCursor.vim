function! UnderCursor#highlight_init()
    let base_hl = 'term=underline cterm=underline gui=underline'
    let Get_bg = { hl -> hl->split('\v\s+')->map('trim(v:val)')
        \ ->filter("v:val =~# '".'\v^\w+bg=\S+$'."'")->join(' ') }

    let cursorline_hl = execute('highlight CursorLine')->Get_bg()
    exec 'hi UnderCursorWord' base_hl cursorline_hl

    let visual_hl = execute('highlight Visual')->Get_bg()
    exec 'hi UnderCursorSelect' base_hl visual_hl
endfunction

function! UnderCursor#_highlight_clear()
    if exists('w:undercursor_hl_id')
        silent! call matchdelete(w:undercursor_hl_id)
    endif
endfunction

function! UnderCursor#_highlight_pattern(pattern, hl_group, ...)
    let priority = get(a:, 1, 0)
    let hl_id = get(w:, 'undercursor_hl_id', -1)
    call UnderCursor#_highlight_clear()
    let w:undercursor_hl_id = matchadd(a:hl_group, a:pattern, priority, hl_id)
endfunction

function! UnderCursor#highlight_word()
    let cur_line = getline('.')
    let cur_col = col('.')
    let word = matchstr(cur_line, '\v\w*%'.cur_col.'c\w+')

    if word !=# get(w:, 'undercursor_hl', '')
        let w:undercursor_hl = word

        call UnderCursor#_highlight_clear()
        if !empty(word)
            let ptn = printf('\V\(\w\)\@<!%s\(\w\)\@!', escape(word, '\'))
            call UnderCursor#_highlight_pattern(ptn, 'UnderCursorWord')
        endif
    endif
endfunction

function! UnderCursor#visual_content()
    if mode() ==# "v"
        let [line_start, column_start] = getpos('v')[1:2]
        let [line_end, column_end] = getpos('.')[1:2]
        if line_start > line_end ||
            \ line_start == line_end && column_start > column_end
            let [line_start, column_start, line_end, column_end] =
                \ [line_end, column_end, line_start, column_start]
        endif

        let lines = getline(line_start, line_end)
        if empty(lines)
            let content = ''
        else
            let lines[-1] = substitute(lines[-1], '\v%>'.column_end.'c.+', '', '')
            let lines[0] = lines[0][column_start - 1:]
            let content = trim(join(lines, "\n"))
        endif

        return content
    else
        return ''
    endif
endfunction

function! UnderCursor#visual_content_escape()
    return substitute(substitute(escape(UnderCursor#visual_content(), '\'),
        \                        "\r", '\\r', 'g'),
        \             "\n", '\\n', 'g')
endfunction

function! UnderCursor#highlight_select()
    if mode() ==# "v"
        let content = UnderCursor#visual_content_escape()

        if content !=# get(w:, 'undercursor_hl', '')
            let w:undercursor_hl = content

            if !empty(content)
                let ptn = printf('\V\c%s', content)
                call UnderCursor#_highlight_pattern(ptn, 'UnderCursorSelect')
            endif
        endif
    endif
endfunction
