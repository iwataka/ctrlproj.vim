# ctrlproj.vim

## Introduction

**Ctrlproj** is an abbreviation of "CtrlP + Project" and provides great project
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

    ```
    git clone http://github.com/iwataka/ctrlproj.vim ~/.vim/bundle/ctrlproj.vim
    ```

+ vim-plug

    ```vim
    Plug 'iwataka/ctrlproj.vim'
    ```

+ NeoBundle

    ```vim
    NeoBundle 'iwataka/ctrlproj.vim'
    ```

+ Vundle

    ```vim
    NeoBundle 'iwataka/ctrlproj.vim'
    ```

## Usage

After installing this plug-in, you should register some paths to your projects,
libraries or application sources in `~/.vim/.ctrlproj` file (recommended) or
`g:ctrlproj_paths` variable. If you prefer the former, you should create `.ctrlproj`
file in `~/.vim` and write like below:

    # Write
    # Some
    # Comments
    /path/to/specified/project

    # Additional comment
    /path/to/specified/directory/*

    # You can also exclude specified directory by writing like this
    ! /path/to/project/you/want/to/exclude

If you prefer the latter, write in your .vimrc like this:

    let g:ctrlp_quickref_paths = [
        \ '/path/to/specified/project',
        \ '/path/to/specified/directory/*',
        " You want to exclude specified directory, put '!' at the head.
        \ '! /path/to/project/you/want/to/exclude'
    ]

That's all!
Run the command `:Ctrlproj` and you get CtrlP interface with paths you registered
before.

![Demo1](https://github.com/iwataka/images/blob/master/Ctrlproj1.png)

You can narrow the choices by typing characters and press `<c-j>` to scroll
down and `<c-k>` to scroll up. If you want to see more detail about CtrlP
interface, you should refer to its help

Then you can press these keys to select one of the projects:

+ `<enter>` to get CtrlP interface again in the selected project.  You can
    select files by default CtrlP's key-binds in it, but they are opened by
    open-command if you select ones which have the extensions like pdf, html or
    something like that.

+ `<c-t>` to delete all buffers in the current project and move the current
    directory to the selected project.

+ `<c-v>` to move the current directory to the selected project without removing
    buffers.

+ `<c-x>` to open the default file-explorer in the selected project.

More additional commands are provided by Ctrlproj:

+ `:CtrlprojLastDir`

    Open CtrlP interface in the last selected directory.

+ `:CtrlprojEdit`

    Open the file you register the paths.

+ `:CtrlprojAlternate`

    Toggle current buffer to the files which have same names but different
    extensions.

+ `:CtrlprojSwitch`

    Toggle current focused code to its test or vice versa.

+ `:CtrlprojRemoveBuffers`

    Remove all buffers included in the current project.

The last three commands utilizes the files which are cached by CtrlP.

## Options

+ `g:ctrlproj_readonly_enabled`

    Set this to 0 to open files without readonly flag (default: 1).

+ `g:ctrlproj_open_extensions`

    If you open files which have extensions contained in this list, they are
    opened by "open-command" (default: ['html', 'pdf']).

+ `g:ctrlproj_configuration_file`

    If you want to write paths in other file, set this to the path (default:
    '~/.vim/.ctrlproj').

+ `g:ctrlproj_paths`

    This list contains paths which are the candidates of this plug-in (default:
    []).

## Requirement

+ Of course [ctrlp.vim](https://github.com/kien/ctrlp.vim)

+ xdg-open command (if you use Linux OS)

+ [ctrlp-py-matcher](https://github.com/FelikZ/ctrlp-py-matcher)(optional, but
    recommended)

+ [the_silver_searhcer](https://github.com/ggreer/the_silver_searcher)(optional,
    but recommended)

## Bugs & Improvements

If you find any bugs or suggestions for improvements, feel free to report them.
