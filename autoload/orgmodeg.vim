" orgmode generator

function! orgmodeg#generate(tree)
  let tree = a:tree
  return orgmodeg#generate_directives(tree)
        \ . "\n" . orgmodeg#generate_headlines(tree)
endfunction

function! orgmodeg#generate_directives(tree)
  let tree = a:tree
  let d = ''
  for directive in tree['directives']
    let d .= '#+' . directive[0] . ' ' . directive[1] . "\n"
  endfor
  return d
endfunction

function! orgmodeg#generate_headlines(tree)
  let tree = a:tree
  let s = ''
  for head in tree['headlines']
    let stars = repeat('*', head.level)
    let todo  = empty(head.todo) ? ' ' : (' ' . head.todo . ' ')
    let title = head.title

    let s .= stars . todo . title . "\n"
    let s .= orgmodeg#generate_metadata(head)
    let s .= orgmodeg#generate_drawers(head)
    let s .= orgmodeg#generate_contents(head)
  endfor
  return s
endfunction

function! orgmodeg#generate_metadata(node)
  let node = a:node
  let s = ''
  let md = ''
  if !empty(node.metadata)
    for [key, val] in sort(items(node.metadata))
      let md .= orgmodeg#meta_pair(key, val)
    endfor
    let s .= substitute(md, '\s\+$', '', '') . "\n"
  endif
  return s
endfunction

function! orgmodeg#meta_pair(meta_key, meta_val)
  let meta_key = a:meta_key
  let meta_val = a:meta_val
  let br = {'datetime' : ['[', ']'], 'date' : ['<', '>']}
  if has_key(br, meta_val.type)
    let dt = orgmodeg#datetime(meta_val)
    return meta_key . ': ' . br[meta_val.type][0] . dt . br[meta_val.type][1] . ' '
  else
    return meta_key . ': ' . meta_val . ' '
  endif
endfunction

function! orgmodeg#datetime(date_val)
  let date_val = a:date_val

  if type(date_val) == type({})
    if exists('g:loaded_lib_datetime')
      if date_val.type == 'datetime'
        let dt = date_val.value.to_localtime_string('%Y-%m-%d %a %H:%M')
      elseif date_val.type == 'date'
        let dt = date_val.value.to_localtime_string('%Y-%m-%d %a')
      else
        throw 'Unexpected internal error: unrecognised datetime: ' . date_val.type
      endif
    else
      throw 'vim-type-datetime missing'
    endif
  else
    let dt = date_val.value
  endif
  return dt
endfunction

function! orgmodeg#generate_drawers(node)
  let node = a:node
  let s = ''
  if !empty(node.drawers)
    for drawer in sort(node.drawers)
      let s .= orgmodeg#generate_drawer(drawer)
    endfor
  endif
  return s
endfunction

function! orgmodeg#generate_drawer(drawer)
  let drawer = a:drawer
  let s = ':' . drawer[0] . ":\n"
  for props in sort(drawer[1])
    let s .= ':' . props.name . ': ' . props.value . "\n"
  endfor
  let s .= ":END:\n"
  return s
endfunction

function! orgmodeg#generate_contents(node)
  let node = a:node
  if !empty(node.contents)
    return join(node.contents, "\n") . "\n"
  else
    return ''
  endif
endfunction
