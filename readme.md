# ctrlproj.vim

## Introduction

*Ctrlproj* is an abbreviation of "CtrlP + Project" and provides great project
management features powered by CtrlP. This is based on my first Vim's plug-in
[ctrlp-quickref.vim](https://github.com/iwataka/ctrlp-quickref.vim) and shipped
with a lot of additional features. Though this is an early-stage experimental
project, this aims to import the features of the awesome pair of Emacs's
[Projectile](https://github.com/bbatsov/projectile) and
[Helm](https://github.com/emacs-helm/helm) by utilizing
[CtrlP](https://github.com/ctrlpvim/ctrlp.vim).

At present, this project includes these features:

+ switch between projects
+ toggle between files with same names but different extensions
+ toggle between code and its test (experimental)
+ kill all buffers in working project
+ open files in any other projects

Of course Ctrlproj is fully integrated with CtrlP's features.

## Installation

You can use your favorite package manager.

+ Pathogen

    git clone http://github.com/iwataka/ctrlproj.vim ~/.vim/bundle/ctrlproj.vim

+ vim-plug

    Plug 'iwataka/ctrlproj.vim'

+ NeoBundle

    NeoBundle 'iwatak/ctrlproj.vim'

+ Vundle

    NeoBundle 'iwataka/ctrlproj.vim'

## Usage

After installing this plug-in, you should register some paths to your projects,
libraries or application sources in ~/.vim/.ctrlproj file (recommended) or
g:ctrlproj_paths variable. If you prefer the former, you should create .ctrlproj
file in ~/.vim and write like below:

    # Write
    # Some
    # Comments
    /directory1/library_or_something_else/src
    /directory2/*/src

    # Additional comment
    /directory3/*

    # You can also exclude specified directory by writing like this
    ! /directory3/library_or_something_else

If you prefer the latter, write in your .vimrc like this:

    let g:ctrlp_quickref_paths = [
        \ '/directory1/library_or_something_else/src',
        \ '/directory2/*/src',
        \ '/directory3/*',
        " You want to exclude specified directory, put '!' at the head.
        \ '! /directory3/library_or_something_else/'
    ]

That's all!
Run the command :Ctrlproj and you get CtrlP interface with paths you registered
before.

Now you can hit the enter on selected path and get CtrlP interface again.
In this way, Ctrlproj provides very quick access to files in any other projects.

You can press other keys like:

+ <c-t> to delete all buffers in the current project and move the current
    directory to the selected project.

+ <c-v> to move the current directory to the selected project without removing
    buffers.

+ <c-x> to open the default file-explorer in the selected project.

More additional commands are provided by Ctrlproj:

+ :CtrlprojLastDir

    Open CtrlP interface in the last selected directory.

+ :CtrlprojAlternate

    Toggle current buffer to the files which have same names but different
    extensions.

+ :CtrlprojSwitch

    Toggle current focused code to its test or vice versa.

+ :CtrlprojRemoveBuffers

    Remove all buffers included in the current project.

+ :CtrlprojEdit

    Open the file you register the paths.

## Options

+ ctrlproj_readonly_enabled

    Set this to 0 to open files without readonly flag (default: 1).

+ ctrlproj_open_extensions

    If you open files which have extensions contained in this list, they are
    opened by "open-command" (default: ['html', 'pdf']).

+ ctrlproj_configuration_file

    If you want to write paths in other file, set this to the path (default:
    '~/.vim/.ctrlproj').

+ ctrlproj_paths

    This list contains paths which are the candidates of this plug-in (default:
    []).

## Requirement

+ Of course [ctrlp.vim](https://github.com/kien/ctrlp.vim)

+ xdg-open command (if you use Linux OS)

+ [ctrlp-py-matcher](https://github.com/FelikZ/ctrlp-py-matcher)(optional, but
    recommended)

+ [the_silver_searhcer](https://github.com/ggreer/the_silver_searcher)(optional,
    but recommended)
