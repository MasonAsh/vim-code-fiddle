scriptencoding utf-8
" vim-code-fiddle - Easily test and run small snippets of code
" Author: Mason Ashbridge <masonjash@gmail.com>

if exists('g:loaded_codefiddle')
    finish
endif

if !exists('g:codefiddle_dir')
    " Create a default based on platform
    if has('win32')
        let g:codefiddle_dir = 'C:\\tmp\\codefiddle\\'
    elseif has('unix')
        let g:codefiddle_dir = '/tmp/codefiddle/'
    else
        echoerr "g:codefiddle_dir not set and could not determine a reasonable default for your platform"
        finish
    endif
endif

" Create codefiddle directory if it doesn't exist
if !isdirectory(g:codefiddle_dir)
    call mkdir(g:codefiddle_dir, "p")
endif

let codefiddle_outputdir = g:codefiddle_dir . 'bin/'

if !isdirectory(codefiddle_outputdir)
    call mkdir(codefiddle_outputdir, "p")
endif

function! s:defineRunCommand()
    execute "command! -buffer Run call codefiddle#runFiddle(expand('%'))"
endfunction

function! codefiddle#editFiddle(filename)
    let path = g:codefiddle_dir . a:filename

    let fileexists = 0
    if filereadable(path)
        let fileexists = 1
    endif

    execute "edit " . path
    " Define the Run command for this buffer
    call s:defineRunCommand()

    let extension = fnamemodify(a:filename, ":e")

    let langfound = 0
    for langdef in g:codefiddle_languagedefs
        for ext in langdef.exts
            if ext == extension
                let targetlangdef = langdef
                let langfound = 1
                break
            endif
        endfor
    endfor

    if langfound
        if !fileexists
            let file_contents = targetlangdef.initial_file_contents
            execute "silent put! =file_contents"
        endif
    else
        echoerr "No codefiddle language definition found for extension ." . extension . "\nTry defining this language by calling codefiddle#defineLanguage in your vimrc"
    endif
endfunction

command! -nargs=1 CodeFiddle :call codefiddle#editFiddle(<f-args>)

function! codefiddle#runFiddle(filepath)
    let filehead = fnamemodify(a:filepath, ":t:h")
    let extension = fnamemodify(a:filepath, ":e")
    " TODO: append .exe for windows
    let target_output_path = g:codefiddle_outputdir . filehead

    let langfound = 0
    for langdef in g:codefiddle_languagedefs
        for ext in langdef.exts
            if ext == extension
                let targetlangdef = langdef
                let langfound = 1
                break
            endif
        endfor
    endfor

    if langfound
        let compile_command = targetlangdef.compile_command
        let run_command = targetlangdef.run_command
        let compile_command = substitute(compile_command, '%INPUT%', a:filepath, "")
        let compile_command = substitute(compile_command, '%OUTPUT%', target_output_path, "")
        let run_command = substitute(run_command, '%INPUT%', a:filepath, "")
        let run_command = substitute(run_command, '%OUTPUT%', target_output_path, "")

        if !empty(compile_command)
            let compile_output = system(compile_command)
            if v:shell_error
                echo "Fiddle failed to compile: "
                echo compile_output
            else
                echo compile_output
                echo system(run_command)
            endif
        else
            " Interpreted languages don't define a compile_command
            echo system(run_command)
        endif
    endif
endfunction

if !exists('g:codefiddle_c_compiler')
    " TODO: more robust compiler detection?
    if executable('gcc')
        let g:codefiddle_c_compiler = 'gcc'
    elseif executable('clang')
        let g:codefiddle_c_compiler = 'clang'
    endif
endif

if exists('g:codefiddle_c_compiler')
    call codefiddle#defineLanguage('c', ['c'], g:codefiddle_c_compiler . ' %INPUT% -o %OUTPUT%', '%OUTPUT%', "#include <stdio.h>\n\nint main()\n{\n\n}")
endif

if !exists('g:codefiddle_cpp_compiler')
    " TODO: more robust compiler detection?
    if executable('g++')
        let g:codefiddle_cpp_compiler = 'g++'
    elseif executable('clang++')
        let g:codefiddle_cpp_compiler = 'clang++'
    endif
endif

if exists('g:codefiddle_cpp_compiler')
    call codefiddle#defineLanguage('cpp', ['cpp', 'cc', 'cxx'], g:codefiddle_cpp_compiler . ' %INPUT% -o %OUTPUT%', '%OUTPUT%', "#include <iostream>\n\nint main()\n{\n\n}")
endif

if !exists('g:codefiddle_python_executable')
    if executable('python')
        let g:codefiddle_python_executable = 'python'
    endif
endif

if exists('g:codefiddle_python_executable')
    call codefiddle#defineLanguage('python', ['py'], '', g:codefiddle_python_executable . ' %INPUT%', '')
endif

if !exists('g:codefiddle_rust_compiler')
    if executable('rustc')
        let g:codefiddle_rust_compiler = 'rustc'
    endif
endif

if exists('g:codefiddle_rust_compiler')
    call codefiddle#defineLanguage('rust', ['rs'], g:codefiddle_rust_compiler . ' %INPUT% -o %OUTPUT%', '%OUTPUT%', "fn main() {\n\n}")
endif

let g:loaded_codefiddle = 1
