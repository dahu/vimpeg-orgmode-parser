" orgmode generator

function! orgmodeg#generate(tree)
  let tree = a:tree
  let s    = ''
  let d    = ''

  for directive in tree['directives']
    let d .= '#+' . directive[0] . ' ' . directive[1] . "\n"
  endfor

  for head in tree['headlines']
    let stars = repeat('*', head.level)
    let todo  = empty(head.todo) ? ' ' : (' ' . head.todo . ' ')
    let title = head.title

    let s .= stars . todo . title . "\n"

    if !empty(head.metadata)
      let br = {'datetime' : ['[', ']'], 'date' : ['<', '>']}
      let md = ''
      for [key, val] in sort(items(head.metadata))
        let md .= key . ': ' . br[val.type][0] . val.value . br[val.type][1] . ' '
      endfor
      let s .= substitute(md, '\s\+$', '', '') . "\n"
    endif

    if !empty(head.drawers)
      for drawer in sort(head.drawers)
        let s .= ':' . drawer[0] . ":\n"
        for props in sort(drawer[1])
          let s .= ':' . props.name . ': ' . props.value . "\n"
        endfor
        let s .= ":END:\n"
      endfor
    endif

    if !empty(head.contents)
      let s .= join(head.contents, "\n") . "\n"
    endif
  endfor

  return d . "\n" . s
endfunction
