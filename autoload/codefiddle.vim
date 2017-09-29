if !exists('g:codefiddle_languagedefs')
    let g:codefiddle_languagedefs = []
endif

function! codefiddle#defineLanguage(language_name, associated_extensions, compile_command, run_command, initial_file_contents)
    call add(g:codefiddle_languagedefs, {'name': a:language_name, 'exts': a:associated_extensions, 'compile_command': a:compile_command, 'run_command': a:run_command, 'initial_file_contents': a:initial_file_contents})
endfunction
