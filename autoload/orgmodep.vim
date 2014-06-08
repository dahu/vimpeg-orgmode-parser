
" debug {{{1
let debug = 0
function! Debug(msg)
  if get(g:, 'debug', 0)
    echom a:msg
  endif
endfunction
"}}}1

function! orgmodep#parse(text)
  if type(a:text) == type([])
    let text = join(a:text, "\n")
  elseif type(a:text) == type('')
    let text = a:text
  else
    throw 'Unexpected type: ' . type(a:text)
  endif
  let tokens = orgmode#parse(text . "\n")
  if tokens.is_matched
    return orgmodep#build(tokens.value)
  else
    return 'Failed to parse: ' . tokens.errmsg
  endif
endfunction

" builder {{{1
function! orgmodep#build(tokens)
  let obj = {}
  let obj.tokens = a:tokens
  let obj.tree = {}
  let obj.node = obj.tree

  func obj.go()
    for t in self.tokens
      let type = self.type(t)
      call call(eval('self.add_' . type), [t], self)
    endfor
    return self.tree
  endfunc

  func obj.type(node)
    return a:node[0]
  endfunc

  func obj.root_node(type)
    if !has_key(self.tree, a:type)
      let self.tree[a:type] = []
    endif
    let self.node = self.tree[a:type]
  endfunc

  func obj.add_content(node)
    let content = a:node[1]
    if content != ''
      call add(self.node[-1].contents, content)
    endif
  endfunc

  func obj.add_directive(node)
    call self.root_node('directives')
    call add(self.node, a:node[1])
  endfunc

  func obj.add_headline(node)
    call self.root_node('headlines')
    call add(self.node, self.add_items(a:node[1]))
  endfunc

  func obj.add_items(node)
    let level = len(a:node[0])
    let title = a:node[1]
    let todo = matchstr(title, '^\s*\zsTODO\|DONE')
    let title = substitute(title, '^\s*' . todo, '', '')
    return {'level' : level, 'title' : title, 'todo' : todo,
          \ 'metadata' : {}, 'tags' : '', 'priority' : '',
          \ 'drawers' : [], 'contents' : []}
  endfunc

  func obj.add_meta_data(node)
    let meta = {}
    for m in a:node[1]
      let key = m[0]
      let type = m[1][0]
      let val =  m[1][1]
      call extend(meta, {key : {'type' : type, 'value' : val}})
    endfor
    call extend(self.node[-1].metadata, meta)
  endfunc

  func obj.add_props(node)
    let name = toupper(a:node[0])
    let key = substitute(substitute(a:node[1][0][0], '^:', '', ''), ':$', '', '')
    let val = join(a:node[1][0][1], ', ')
    let drawer = {'name' : name, key : val}
    call add(self.node[-1].drawers, drawer)
  endfunc

  return obj.go()
endfunction
" }}}1

" VimPEG callbacks {{{1
function! orgmodep#orgline(elems)
  call Debug( 'orgline=' . string(a:elems) )
  return a:elems[0]
endfunction

function! orgmodep#directive(elems)
  call Debug( 'directive=' . string(a:elems) )
  return ['directive', [a:elems[3], a:elems[5]]]
endfunction

function! orgmodep#directive_key(elems)
  call Debug( 'directive_key=' . string(a:elems) )
  return a:elems[1]
endfunction

function! orgmodep#headline(elems)
  call Debug( 'headline=' . string(a:elems) )
  return ['headline', [a:elems[0], a:elems[2]]]
endfunction

function! orgmodep#content(elems)
  call Debug( 'content=' . string(a:elems) )
  return ['content', a:elems[0]]
endfunction

function! orgmodep#meta_data(elems)
  call Debug( 'meta_data=' . string(a:elems) )
  return ['meta_data', a:elems[0]]
endfunction

function! orgmodep#meta_key(elems)
  call Debug( 'meta_key=' . string(a:elems) )
  return a:elems[1]
endfunction

function! orgmodep#meta_datetime(elems)
  call Debug( 'meta_datetime=' . string(a:elems) )
  return ['datetime', a:elems[1]]
endfunction

function! orgmodep#meta_date(elems)
  call Debug( 'meta_date=' . string(a:elems) )
  return ['date', a:elems[1]]
endfunction

function! orgmodep#props(elems)
  call Debug( 'props=' . string(a:elems) )
  return ['props', a:elems[1]]
endfunction

function! orgmodep#prop_pair(elems)
  call Debug( 'prop_pair=' . string(a:elems) )
  return [a:elems[1], a:elems[3]]
endfunction

function! orgmodep#prop_key(elems)
  call Debug( 'prop_key=' . string(a:elems) )
  return a:elems[1]
endfunction

function! orgmodep#rest_of_line(elems)
  call Debug( 'rest_of_line=' . string(a:elems) )
  return a:elems[0]
endfunction
"}}}1

" vim: fdm=marker
