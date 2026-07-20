# lilymacs keybinds

## Evil basics (vim)
| Key | Action |
|-----|--------|
| `i` | insert mode |
| `I` | insert at line start |
| `a` | append after cursor |
| `A` | append at line end |
| `o` / `O` | new line below / above |
| `ESC` or `C-c` | back to normal mode |
| `u` / `C-r` | undo / redo |
| `h j k l` | move left/down/up/right |
| `w` / `b` | next/prev word |
| `e` | end of word |
| `0` / `$` | line start / end |
| `gg` / `G` | file start / end |
| `C-u` / `C-d` | scroll up / down half page |
| `{` / `}` | prev/next blank line (paragraph) |
| `%` | jump to matching bracket |
| `*` | search word under cursor forward |
| `#` | search word under cursor backward |
| `n` / `N` | next/prev search result |
| `/` | search forward |
| `?` | search backward |

## Evil editing
| Key | Action |
|-----|--------|
| `d` | delete (operator) |
| `c` | change (operator) |
| `y` | yank/copy (operator) |
| `p` / `P` | paste after / before |
| `x` | delete char |
| `r` | replace char |
| `dd` | delete line |
| `cc` | change line |
| `yy` | yank line |
| `D` | delete to end of line |
| `C` | change to end of line |
| `Y` | yank to end of line |
| `ciw` | change inner word |
| `diw` | delete inner word |
| `cif` | change inner function (tree-sitter) |
| `dif` | delete inner function (tree-sitter) |
| `vaf` | select outer function (tree-sitter) |
| `vic` | select inner class (tree-sitter) |
| `ci"` / `ci'` | change inside quotes |
| `da(` | delete including parens |
| `.` | repeat last action |
| `>>` / `<<` | indent / dedent |
| `=` | auto-indent (operator) |
| `gcc` | toggle comment (evil-commentary) |
| `gc` | comment operator (e.g. `gcip` = comment paragraph) |

## Evil visual mode
| Key | Action |
|-----|--------|
| `v` | visual char mode |
| `V` | visual line mode |
| `C-v` | visual block mode |
| `gv` | reselect last selection |

## Windows  (SPC w...)
| Key | Action |
|-----|--------|
| `SPC wv` | split vertical (side by side) |
| `SPC ws` | split horizontal (stacked) |
| `SPC wd` | close current window |
| `SPC wo` | close all other windows (maximize) |
| `SPC wh/j/k/l` | focus left/down/up/right |
| `SPC w=` | equalize window sizes |
| `C-w >` / `C-w <` | resize wider / narrower |
| `C-w +` / `C-w -` | resize taller / shorter |

## Files  (SPC f...)
| Key | Action |
|-----|--------|
| `SPC ff` | fuzzy find files from root (telescope) |
| `SPC fg` | ripgrep from root |
| `SPC fs` | ripgrep symbol under cursor |
| `SPC fo` | recent files |
| `SPC fl` | search lines in current buffer |
| `SPC fi` | find file in emacs config |
| `SPC fp` | switch project (from ~/repos) |
| `SPC fr` | change search root directory |

## Buffers  (SPC b...)
| Key | Action |
|-----|--------|
| `SPC bb` | switch buffer |
| `SPC bp` | previous buffer |
| `SPC bn` | next buffer |
| `SPC bd` | kill/close buffer |
| `SPC bm` | buffer list (ibuffer) |

## Git / Magit  (SPC g...)
| Key | Action |
|-----|--------|
| `SPC gs` | git status (main magit view) |
| `SPC gl` | git log |
| `SPC gb` | git blame |
| `SPC gd` | git diff (unstaged changes) |
| `SPC gS` | show specific commit diff (VS Code style) |
| `SPC gc` | commit |
| `SPC gp` | push |
| `SPC gP` | pull |
| `SPC gh` / `SPC gH` | next / previous diff hunk (in buffer) |
| (in magit) `s` | stage file/hunk |
| (in magit) `u` | unstage |
| (in magit) `c c` | commit |
| (in magit) `P p` | push |
| (in magit) `F p` | pull |
| (in magit) `b b` | checkout branch |
| (in magit) `E` | open diff in ediff (side-by-side red/green) |
| (in magit) `q` | quit magit |
| (in ediff) `n` / `p` | next / previous hunk |
| (in ediff) `q` | quit ediff |

### VS Code-style commit diff (side-by-side red/green)

**View a commit's changes:**
1. `SPC gS` — pick a commit (tab-complete the hash or branch name)
2. Magit opens showing the full diff with word-level highlights
3. Press `E` to open it **side-by-side in ediff** — old on left (red), new on right (green)

**Gutter indicators (live in your buffers):**
- Green bars next to line numbers = added lines
- Red bars = deleted lines
- Blue bars = changed lines
- `SPC gh` / `SPC gH` — jump between hunks without leaving your file

**View unstaged changes:**
`SPC gd` opens the working-tree diff (what you've changed but haven't staged).

**In ediff (side-by-side view):**
| Key | Action |
|-----|--------|
| `n` / `p` | next / previous hunk |
| `a` / `b` | copy change from A→B or B→A |
| `q` | quit ediff |

## LSP / Eglot  (SPC l... and direct)
| Key | Action |
|-----|--------|
| `K` | show docs for thing at point |
| `gd` | go to definition |
| `gD` | go to definition in other window |
| `gr` | find references |
| `gi` | go to implementation |
| `SPC lr` | rename symbol |
| `SPC la` | code actions |
| `SPC lf` | format buffer |
| `SPC lR` | restart LSP |

## Compile / Errors  (SPC c...)
| Key | Action |
|-----|--------|
| `SPC cc` | compile (prompts for command) |
| `SPC cm` | recompile (repeat last) |
| `SPC cn` | next error |
| `SPC cp` | previous error |
| `SPC cl` | close popup windows (compile/xref/grep) |

## Terminal
| Key | Action |
|-----|--------|
| `SPC to` | open vterm in current directory |
| (in vterm) `C-c C-c` | send C-c to process |

## Org  (SPC o...)
| Key | Action |
|-----|--------|
| `SPC oa` | org agenda |
| `SPC oc` | org capture |
| `TAB` | cycle heading fold |
| `S-TAB` | cycle all headings |
| `t` | cycle TODO state |
| `RET` | follow link |

## Telescope file finder (when open)
| Key | Action |
|-----|--------|
| type | filter files |
| `C-n` / `C-j` / `↓` | next result |
| `C-p` / `C-k` / `↑` | previous result |
| `C-d` / `C-u` | scroll down/up 5 |
| `RET` | open file |
| `C-w` | clear input |
| `ESC` / `C-g` | cancel |

## Multiple cursors
| Key | Action |
|-----|--------|
| `C->` | mark next like this |
| `C-<` | mark previous like this |
| `C-c C-<` | mark all like this |
| `C-S-c C-S-c` | edit lines (visual selection) |

## Misc
| Key | Action |
|-----|--------|
| `SPC ;` | M-x (command palette) |
| `SPC u` | universal argument (C-u) |
| `M-p` / `M-n` | move line up / down |
| `C-x C-s` | save file |
| `C-x C-f` | open file (emacs default) |
| `q` (in help/special buffers) | quit |
