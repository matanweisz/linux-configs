"========================
" Vim Configuration File
"========================

"------------------------
" PLUGIN MANAGER (vim-plug)
"------------------------
call plug#begin('~/.vim/plugged')

" NerdTree File Explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'PhilRunninger/nerdtree-buffer-ops'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Syntax support for many languages
Plug 'sheerun/vim-polyglot'

" Git integration
Plug 'tpope/vim-fugitive'

" Git gutter for showing git changes
Plug 'airblade/vim-gitgutter'

" Auto-completion and LSP (requires node.js)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" AI suggestions for free
Plug 'Exafunction/codeium.vim'
Plug 'Exafunction/windsurf.vim', { 'branch': 'main' }

" Python-specific tools
Plug 'vim-python/python-syntax'

" YAML
Plug 'stephpy/vim-yaml'

" Terraform
Plug 'hashivim/vim-terraform'

" Docker
Plug 'ekalinin/Dockerfile.vim'

" Kubernetes
Plug 'andrewstuart/vim-kubernetes'

" JSON with better formatting
Plug 'elzr/vim-json'

" DevOps and Infrastructure plugins
Plug 'pearofducks/ansible-vim'        " Ansible playbooks
Plug 'towolf/vim-helm'                " Helm charts
Plug 'juliosueiras/vim-terraform-completion' " Better Terraform completion

" Devicons
Plug 'ryanoasis/vim-devicons'

" Better Theme
Plug 'morhetz/gruvbox'

call plug#end()

"------------------------
" GENERAL SETTINGS
"------------------------
syntax on                      " Enable syntax highlighting
set number                     " Show absolute line number
set relativenumber             " Show relative line numbers
set tabstop=4                  " 4-space tabs
set shiftwidth=4
set expandtab                  " Convert tabs to spaces
set autoindent
set smartindent
set clipboard=unnamedplus      " Use system clipboard
set mouse=a                    " Enable mouse support
set hidden                     " Allow background buffers
set nowrap                     " Don't wrap lines
set incsearch                  " Show search matches as you type
set ignorecase smartcase       " Smarter search behavior
set wildmenu                   " Better command-line completion
set termguicolors              " Enable true colors
set background=dark
set updatetime=100             " Faster updates for gitgutter
set laststatus=2               " Always show status line

colorscheme gruvbox            " Use gruvbox theme
filetype plugin indent on      " Enable filetype-specific plugins

"------------------------
" Persistent Undo - remembers undo history even after closing files
"------------------------
set undofile
set undodir=~/.vim/undodir

"------------------------
" NERDTree Settings
"------------------------
let g:NERDTreeGitStatusUseNerdFonts = 1

" Custom NERDTree symbols
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "━",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

nmap <C-n> :NERDTreeToggle<CR>     " Toggle file explorer with Ctrl+N
let NERDTreeShowHidden=1           " Show hidden files

" Auto open and close
autocmd bufenter * if (winnr("$") == 1 && &filetype == "nerdtree") | q | endif
autocmd VimEnter * NERDTree | wincmd p

"------------------------
" Airline (Status Line/Bar)
"------------------------
let g:airline#extensions#tabline#enabled = 1      " Show tabs on tabline
let g:airline_theme = 'gruvbox'                   " Use gruvbox theme
let g:airline_powerline_fonts = 1                 " Enable powerline fonts
let g:airline#extensions#branch#enabled = 1       " Show git branch info
let g:airline#extensions#hunks#enabled = 1        " Show git hunks in airline
let g:airline#extensions#coc#enabled = 1          " Show CoC status in airline
let g:airline#extensions#tabline#formatter = 'unique_tail_improved' " Show unique tab names

" Git hunks symbols in airline
let g:airline#extensions#hunks#hunk_symbols = ['✚', '✹', '━']

" Custom status bar
" Show only filename in status bar
let g:airline_section_c = '%t'

" Leave section X empty (file type vim is default)
let g:airline_section_x = ''

" Show current-line/total-lines (percent%)
let g:airline_section_z = '%l/%L ☰ (%p%%) | Col:%c'

"------------------------
" CoC (Auto-completion)
"------------------------
" CoC Global Extensions - auto install and load on startup
let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-yaml',
      \ 'coc-sh',
      \ 'coc-docker',
      \ 'coc-terraform',
      \ 'coc-pyright',
      \ 'coc-git',
      \ 'coc-tsserver',
      \ 'coc-prettier',
      \ 'coc-highlight',
      \ 'coc-pairs',
      \ 'coc-spell-checker',
      \ 'coc-diagnostic',
      \ 'coc-markdownlint',
      \ 'coc-word',
      \ 'coc-syntax'
      \ ]

" Use K to show documentation
nnoremap <silent> K :call CocAction('doHover')<CR>

" Format on save
autocmd BufWritePre * silent! :call CocAction('format')

" Using Tab to confirm auto completion
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"------------------------
" GitGutter
"------------------------
let g:gitgutter_enabled = 1             " Enable GitGutter
let g:gitgutter_signs = 1               " Show signs
let g:gitgutter_highlight_lines = 0     " Don't highlight lines
let g:gitgutter_highlight_linenrs = 1   " Highlight line numbers

" Custom git signs
let g:gitgutter_sign_added = '✚'
let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_removed = '━'
let g:gitgutter_sign_removed_first_line = '━'
let g:gitgutter_sign_modified_removed = '✹'

" Performance settings
let g:gitgutter_async = 1
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 1
let g:gitgutter_max_signs = 1000
let g:gitgutter_sign_priority = 10

" Always show sign column
set signcolumn=yes

" Gruvbox-style colors for diff signs
highlight GitGutterAdd    guifg=#b8bb26 ctermfg=Green           " green: additions
highlight GitGutterChange guifg=#fabd2f ctermfg=Yellow          " yellow: changes
highlight GitGutterDelete guifg=#fb4934 ctermfg=Red             " red: deletions
highlight GitGutterChangeDelete guifg=#fb4934 ctermfg=Red       " red: change + deletion

" GitGutter line number highlighting
highlight GitGutterAddLineNr    guifg=#b8bb26 ctermfg=Green     " green: additions
highlight GitGutterChangeLineNr guifg=#fabd2f ctermfg=Yellow    " yellow: changes
highlight GitGutterDeleteLineNr guifg=#fb4934 ctermfg=Red       " red: deletions


"------------------------
" Terraform and YAML settings
"------------------------
" Terraform
let g:terraform_fmt_on_save = 1 " Format on save
let g:terraform_align = 1       " Align blocks

" YAML (for Kubernetes, Ansible, etc.)
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab " Use 2 spaces for YAML
autocmd FileType yaml setlocal indentkeys-=<:> " Don't indent YAML

" JSON formatting
let g:vim_json_syntax_conceal = 0 " Disable JSON concealing
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab " Use 2 spaces for JSON

" Dockerfile
autocmd FileType dockerfile setlocal ts=2 sts=2 sw=2 expandtab " Use 2 spaces for Dockerfile
