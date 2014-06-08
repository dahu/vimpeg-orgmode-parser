" Parser compiled on Sun 08 Jun 2014 11:00:40 AM CST,
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
" orgline          ::= ( directive | markup )* EOF                 -> #orgline
" directive        ::= ws '#' ws directive_key ws rest_of_line     -> #directive
" directive_key    ::= '+' non_prop_key                            -> #directive_key
" non_prop_key     ::= '\C[A-Z]\+:'
" markup           ::= headline | props | meta_data | content
" content          ::= rest_of_line                                -> #content
" headline         ::= stars ws rest_of_line                       -> #headline
" meta_data        ::= (meta_key meta_val)+ nl                     -> #meta_data
" meta_key         ::= ws non_prop_key ws                          -> #meta_key
" meta_val         ::= meta_datetime | meta_date
" meta_datetime    ::= '\[' '[^]]\+' '\]'                          -> #meta_datetime
" meta_date        ::= '<' '[^>]\+' '>'                            -> #meta_date
" stars            ::= '\*\{1,3\}'
" prop_begin       ::= ws ':PROPERTIES:' nl
" prop_end         ::= ws ':END:' nl
" props            ::= prop_begin prop_pair* prop_end              -> #props
" prop_pair        ::= ws prop_key ws prop_val ws                  -> #prop_pair
" prop_key         ::= !prop_end ':[a-zA-Z_-]\+:'                  -> #prop_key
" prop_val         ::= rest_of_line
" rest_of_line     ::= '.\{-}\ze\s*[\r\n]' nl                      -> #rest_of_line
" ws               ::= '\s*'
" nl               ::= ws '[\r\n]'
" EOF              ::= !'.'

let s:p = vimpeg#parser({'root_element': 'orgline', 'skip_white': 0, 'parser_name': 'orgmode', 'namespace': 'orgmodep'})
call s:p.and([s:p.maybe_many(s:p.or(['directive', 'markup'])), 'EOF'],
      \{'id': 'orgline', 'on_match': 'orgmodep#orgline'})
call s:p.and(['ws', s:p.e('#'), 'ws', 'directive_key', 'ws', 'rest_of_line'],
      \{'id': 'directive', 'on_match': 'orgmodep#directive'})
call s:p.and([s:p.e('+'), 'non_prop_key'],
      \{'id': 'directive_key', 'on_match': 'orgmodep#directive_key'})
call s:p.e('\C[A-Z]\+:',
      \{'id': 'non_prop_key'})
call s:p.or(['headline', 'props', 'meta_data', 'content'],
      \{'id': 'markup'})
call s:p.and(['rest_of_line'],
      \{'id': 'content', 'on_match': 'orgmodep#content'})
call s:p.and(['stars', 'ws', 'rest_of_line'],
      \{'id': 'headline', 'on_match': 'orgmodep#headline'})
call s:p.and([s:p.many(s:p.and(['meta_key', 'meta_val'])), 'nl'],
      \{'id': 'meta_data', 'on_match': 'orgmodep#meta_data'})
call s:p.and(['ws', 'non_prop_key', 'ws'],
      \{'id': 'meta_key', 'on_match': 'orgmodep#meta_key'})
call s:p.or(['meta_datetime', 'meta_date'],
      \{'id': 'meta_val'})
call s:p.and([s:p.e('\['), s:p.e('[^]]\+'), s:p.e('\]')],
      \{'id': 'meta_datetime', 'on_match': 'orgmodep#meta_datetime'})
call s:p.and([s:p.e('<'), s:p.e('[^>]\+'), s:p.e('>')],
      \{'id': 'meta_date', 'on_match': 'orgmodep#meta_date'})
call s:p.e('\*\{1,3\}',
      \{'id': 'stars'})
call s:p.and(['ws', s:p.e(':PROPERTIES:'), 'nl'],
      \{'id': 'prop_begin'})
call s:p.and(['ws', s:p.e(':END:'), 'nl'],
      \{'id': 'prop_end'})
call s:p.and(['prop_begin', s:p.maybe_many('prop_pair'), 'prop_end'],
      \{'id': 'props', 'on_match': 'orgmodep#props'})
call s:p.and(['ws', 'prop_key', 'ws', 'prop_val', 'ws'],
      \{'id': 'prop_pair', 'on_match': 'orgmodep#prop_pair'})
call s:p.and([s:p.not_has('prop_end'), s:p.e(':[a-zA-Z_-]\+:')],
      \{'id': 'prop_key', 'on_match': 'orgmodep#prop_key'})
call s:p.and(['rest_of_line'],
      \{'id': 'prop_val'})
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
