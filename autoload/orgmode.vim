" Parser compiled on Sat 07 Jun 2014 08:34:51 PM CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "orgmode.vimpeg"
" with the following grammar:

" ; Emacs org-mode PEG
" ; Barry Arthur, 2014 06 06
" 
" .skip_white   = false
" .namespace    = 'orgmodep'
" .parser_name  = 'orgmode'
" .root_element = 'orgline'
" 
" orgline           ::= ( directive | markup | content )* EOF          -> #orgline
" directive         ::= ws '#' '.\{-}\ze[\r\n]' line_end               -> #directive
" markup            ::= headline | properties
" headline          ::= stars ws '.\{-}\ze[\r\n]' line_end             -> #headline
" content_line      ::= !markup  '.\{-}\ze[\r\n]' line_end             -> #content_line
" content           ::= ( content_line | line_end )+
" stars             ::= '\*\{1,3\}'
" properties_begin  ::= ws ':PROPERTIES:' ws line_end
" properties_end    ::= ws ':END:' ws line_end
" properties        ::= properties_begin property_pair* properties_end -> #properties
" property_pair     ::= ws property_key ws property_value ws           -> #property_pair
" property_key      ::= !properties_end ':[a-zA-Z_-]\+:'               -> #property_key
" property_value    ::= '.\{-}\ze[\r\n]' line_end                      -> #property_value
" ws                ::= '[\t ]*'
" line_end          ::= '[\r\n]'
" EOF               ::= !'.'

let s:p = vimpeg#parser({'root_element': 'orgline', 'skip_white': 0, 'parser_name': 'orgmode', 'namespace': 'orgmodep'})
call s:p.and([s:p.maybe_many(s:p.or(['directive', 'markup', 'content'])), 'EOF'],
      \{'id': 'orgline', 'on_match': 'orgmodep#orgline'})
call s:p.and(['ws', s:p.e('#'), s:p.e('.\{-}\ze[\r\n]'), 'line_end'],
      \{'id': 'directive', 'on_match': 'orgmodep#directive'})
call s:p.or(['headline', 'properties'],
      \{'id': 'markup'})
call s:p.and(['stars', 'ws', s:p.e('.\{-}\ze[\r\n]'), 'line_end'],
      \{'id': 'headline', 'on_match': 'orgmodep#headline'})
call s:p.and([s:p.not_has('markup'), s:p.e('.\{-}\ze[\r\n]'), 'line_end'],
      \{'id': 'content_line', 'on_match': 'orgmodep#content_line'})
call s:p.many(s:p.or(['content_line', 'line_end']),
      \{'id': 'content'})
call s:p.e('\*\{1,3\}',
      \{'id': 'stars'})
call s:p.and(['ws', s:p.e(':PROPERTIES:'), 'ws', 'line_end'],
      \{'id': 'properties_begin'})
call s:p.and(['ws', s:p.e(':END:'), 'ws', 'line_end'],
      \{'id': 'properties_end'})
call s:p.and(['properties_begin', s:p.maybe_many('property_pair'), 'properties_end'],
      \{'id': 'properties', 'on_match': 'orgmodep#properties'})
call s:p.and(['ws', 'property_key', 'ws', 'property_value', 'ws'],
      \{'id': 'property_pair', 'on_match': 'orgmodep#property_pair'})
call s:p.and([s:p.not_has('properties_end'), s:p.e(':[a-zA-Z_-]\+:')],
      \{'id': 'property_key', 'on_match': 'orgmodep#property_key'})
call s:p.and([s:p.e('.\{-}\ze[\r\n]'), 'line_end'],
      \{'id': 'property_value', 'on_match': 'orgmodep#property_value'})
call s:p.e('[\t]*',
      \{'id': 'ws'})
call s:p.e('[\r\n]',
      \{'id': 'line_end'})
call s:p.not_has(s:p.e('.'),
      \{'id': 'EOF'})

let g:orgmode = s:p.GetSym('orgline')
function! orgmode#parse(in)
  return g:orgmode.match(a:in)
endfunction
function! orgmode#parser()
  return deepcopy(g:orgmode)
endfunction
