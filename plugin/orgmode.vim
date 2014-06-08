function! ParseOrgModeFile(file)
  if filereadable(a:file)
    return orgmodep#parse(readfile(a:file))
  else
    throw 'File not found'
  endif
endfunction
