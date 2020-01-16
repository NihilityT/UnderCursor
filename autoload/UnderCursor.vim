functio! s:highlight_background(hl_group)
    return join(filter(map(split(a:hl_group, '\v\s+'), 'trim(v:val)'),
        \       'v:val =~# ''\v^\w+bg=\S+$'''), ' ')
endfunction

function! s:define_highlight_group(hl_group, hl_args)
    execute 'highlight' a:hl_group join(a:hl_args, ' ')
endfunction

function! UnderCursor#highlight_init()
    let base_highlight_args = 'term=underline cterm=underline gui=underline'
    call s:define_highlight_group('UnderCursorWord', [
        \ base_highlight_args,
        \ s:highlight_background(execute('highlight CursorLine'))
        \])
    call s:define_highlight_group('UnderCursorSelect', [
        \ base_highlight_args,
        \ s:highlight_background(execute('highlight Visual'))
        \])
endfunction

function! s:has_highlight()
    return exists('w:undercursor_hl_id')
endfunction

function! s:delete_highlight()
        call matchdelete(w:undercursor_hl_id)
        unlet w:undercursor_hl_id
endfunction

function! UnderCursor#highlight_clear()
    if s:has_highlight()
        call s:delete_highlight()
    endif
endfunction

function! s:current_pattern()
    return get(w:, 'undercursor_hl', '')
endfunction

function! s:update_pattern(pattern)
    let w:undercursor_hl = a:pattern
endfunction

function! s:match_empty(pattern)
    return '' =~# a:pattern
endfunction

function! s:add_highlight(pattern, hl_group)
        let w:undercursor_hl_id = matchadd(a:hl_group, a:pattern, 0)
endfunction

function! s:highlight_pattern(pattern, hl_group)
    if !s:match_empty(a:pattern)
        call s:add_highlight(a:pattern, a:hl_group)
    endif
endfunction

function! UnderCursor#highlight_pattern(pattern, hl_group)
    if s:current_pattern() !=# a:pattern
        call s:update_pattern(a:pattern)
        call UnderCursor#highlight_clear()
        call s:highlight_pattern(a:pattern, a:hl_group)
    endif
endfunction

function! UnderCursor#word()
    let word_under_cursor_pattern = '\v%<'.(col('.') + 1).'c\w+%>'.col('.').'c'
    return matchstr(getline('.'), word_under_cursor_pattern)
endfunction

function! UnderCursor#highlight_word()
    let word_pattern = '\V\w\@<!'.escape(UnderCursor#word(), '\').'\w\@!'
    call UnderCursor#highlight_pattern(word_pattern, 'UnderCursorWord')
endfunction

function! s:visual_pos_line()
    let begin_line = line('v')
    let end_line = line('.')
    if begin_line <= end_line
        return { 'begin': { 'line': begin_line, 'col': 0 },
            \    'end':   { 'line': end_line,   'col': 0 } }
    else
        return { 'begin': { 'line': end_line,   'col': 0 },
            \    'end':   { 'line': begin_line, 'col': 0 } }
    endif
endfunction

function! s:visual_pos_chars()
    let [begin_line, begin_col] = getpos('v')[1:2]
    let [end_line, end_col] = getpos('.')[1:2]
    if begin_line < end_line ||
        \ begin_line == end_line && begin_col <= end_col
        return { 'begin': { 'line': begin_line, 'col': begin_col },
            \    'end':   { 'line': end_line,   'col': end_col   } }
    else
        return { 'begin': { 'line': end_line,   'col': end_col   },
            \    'end':   { 'line': begin_line, 'col': begin_col } }
    endif
endfunction

function! s:visual_pos()
    if mode() ==# 'V' || mode() ==# 'S'
        return s:visual_pos_line()
    else
        return s:visual_pos_chars()
    endif
endfunction

function! s:remove_content_outside(lines)
    if !empty(a:lines) && s:visual_pos().end.col
        let a:lines[-1] = substitute(a:lines[-1],
            \                        '\v%>'.s:visual_pos().end.col.'c.+',
            \                        '', '')
        let a:lines[0] = a:lines[0][s:visual_pos().begin.col - 1:]
    endif
    return a:lines
endfunction

function! s:content()
    let lines = getline(s:visual_pos().begin.line, s:visual_pos().end.line)
    return trim(join(s:remove_content_outside(lines), "\n"))
endfunction

function! UnderCursor#escape(str)
    return substitute(substitute(escape(a:str, '\'), "\r", '\\r', 'g'),
        \             "\n", '\\n', 'g')
endfunction

function! UnderCursor#raw_content()
    return s:content()
endfunction

function! UnderCursor#content()
    return UnderCursor#escape(UnderCursor#raw_content())
endfunction

function! UnderCursor#highlight_select()
    if mode() ==? 'v' || mode() ==? 's'
        let select_pattern = '\V\c'.UnderCursor#content()
        call UnderCursor#highlight_pattern(select_pattern, 'UnderCursorSelect')
    endif
endfunction
