" Parser compiled on Sun 08 Jun 2014 07:33:43 AM CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "orgmode.vimpeg"
" with the following grammar:

" ; PEG grammar of simplified Emacs org-mode format
" ; Barry Arthur, 2014 06 07
" 
" .skip_white   = false
" .namespace    = 'orgmodep'
" .parser_name  = 'orgmode'
" .root_element = 'orgline'
" 
" orgline          ::= ( directive | markup | content )* EOF          -> #orgline
" directive        ::= ws '#' rest_of_line                            -> #directive
" markup           ::= headline | properties
" headline         ::= stars ws rest_of_line                          -> #headline
" content_line     ::= !markup  rest_of_line                          -> #content_line
" content          ::= ( content_line | nl )+
" stars            ::= '\*\{1,3\}'
" properties_begin ::= ws ':PROPERTIES:' nl
" properties_end   ::= ws ':END:' nl
" properties       ::= properties_begin property_pair* properties_end -> #properties
" property_pair    ::= ws property_key ws property_value ws           -> #property_pair
" property_key     ::= !properties_end ':[a-zA-Z_-]\+:'               -> #property_key
" property_value   ::= rest_of_line
" rest_of_line     ::= '.\{-}\ze\s*[\r\n]' nl                         -> #rest_of_line
" ws               ::= '\s*'
" nl               ::= ws '[\r\n]'
" EOF              ::= !'.'

let s:p = vimpeg#parser({'root_element': 'orgline', 'skip_white': 0, 'parser_name': 'orgmode', 'namespace': 'orgmodep'})
call s:p.and([s:p.maybe_many(s:p.or(['directive', 'markup', 'content'])), 'EOF'],
      \{'id': 'orgline', 'on_match': 'orgmodep#orgline'})
call s:p.and(['ws', s:p.e('#'), 'rest_of_line'],
      \{'id': 'directive', 'on_match': 'orgmodep#directive'})
call s:p.or(['headline', 'properties'],
      \{'id': 'markup'})
call s:p.and(['stars', 'ws', 'rest_of_line'],
      \{'id': 'headline', 'on_match': 'orgmodep#headline'})
call s:p.and([s:p.not_has('markup'), 'rest_of_line'],
      \{'id': 'content_line', 'on_match': 'orgmodep#content_line'})
call s:p.many(s:p.or(['content_line', 'nl']),
      \{'id': 'content'})
call s:p.e('\*\{1,3\}',
      \{'id': 'stars'})
call s:p.and(['ws', s:p.e(':PROPERTIES:'), 'nl'],
      \{'id': 'properties_begin'})
call s:p.and(['ws', s:p.e(':END:'), 'nl'],
      \{'id': 'properties_end'})
call s:p.and(['properties_begin', s:p.maybe_many('property_pair'), 'properties_end'],
      \{'id': 'properties', 'on_match': 'orgmodep#properties'})
call s:p.and(['ws', 'property_key', 'ws', 'property_value', 'ws'],
      \{'id': 'property_pair', 'on_match': 'orgmodep#property_pair'})
call s:p.and([s:p.not_has('properties_end'), s:p.e(':[a-zA-Z_-]\+:')],
      \{'id': 'property_key', 'on_match': 'orgmodep#property_key'})
call s:p.and(['rest_of_line'],
      \{'id': 'property_value'})
call s:p.and([s:p.e('.\{-}\ze\s*[\r\n]'), 'nl'],
      \{'id': 'rest_of_line', 'on_match': 'orgmodep#rest_of_line'})
call s:p.e('\s*',
      \{'id': 'ws'})
call s:p.and(['ws', s:p.e('[\r\n]')],
      \{'id': 'nl'})
call s:p.not_has(s:p.e('.'),
      \{'id': 'EOF'})

let g:orgmode = s:p.GetSym('orgline')
function! orgmode#parse(in)
  return g:orgmode.match(a:in)
endfunction
function! orgmode#parser()
  return deepcopy(g:orgmode)
endfunction
