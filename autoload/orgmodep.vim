let debug = 0
function! Debug(msg)
  if get(g:, 'debug', 0)
    echom a:msg
  endif
endfunction

function! orgmodep#parse(file)
  let t = join(readfile(a:file), "\n") . "\n"
  let p = orgmode#parse(t)
  if p.is_matched
    return p.value
  else
    return 'Failed to parse: ' . p.errmsg
  endif
endfunction

function! orgmodep#orgline(elems)
  call Debug( 'orgline=' . string(a:elems) )
  return a:elems[0]
endfunction

function! orgmodep#directive(elems)
  call Debug( 'directive=' . string(a:elems) )
  return ['directive', a:elems[2]]
endfunction

function! orgmodep#headline(elems)
  call Debug( 'headline=' . string(a:elems) )
  return ['headline', [a:elems[0], a:elems[2]]]
endfunction

function! orgmodep#content_line(elems)
  call Debug( 'content_line=' . string(a:elems) )
  return ['content', a:elems[1]]
endfunction

function! orgmodep#properties(elems)
  call Debug( 'properties=' . string(a:elems) )
  return ['properties', a:elems[1]]
endfunction

function! orgmodep#property_pair(elems)
  call Debug( 'property_pair=' . string(a:elems) )
  return [a:elems[1], a:elems[3]]
endfunction

function! orgmodep#property_key(elems)
  call Debug( 'property_key=' . string(a:elems) )
  return a:elems[1]
endfunction

function! orgmodep#property_value(elems)
  call Debug( 'property_value=' . string(a:elems) )
  return a:elems[0]
endfunction

