function! ReadOrgModeFile(file)
  if filereadable(a:file)
    return orgmodep#parse(readfile(a:file))
  else
    throw 'File not found'
  endif
endfunction

function! WriteOrgModeFile(orgdata, fname)
  if filereadable(a:fname)
    throw 'File exists: ' . a:fname
  else
    call writefile(split(orgmodeg#generate(a:orgdata), "\n"), a:fname)
  endif
endfunction
