# balsamik.kak
A simple **WIP** file navigator for kakoune heavily inspired by vim's netrw and
tpope/vim-vinegar

## Installation
You can install it with andreyorst/plug.kak:
```
plug "velrest/balsamik.kak"
```

This is still in a very unoptimized and unusable state.

## Usage with alexherbo2/explore.kak
You can use balsamik easily with explore.kak you just have to set the following
in you configuration:
```
plug 'alexherbo2/explore.kak' config %{
    alias global explore-files balsamik
}
```

## vim-vinegar like mapping to open files with -
For this you just have to create a mapping and pass the current `bufname` to
balsamik:
```
hook global BufOpenFile .* %{
    map -- buffer normal - ": balsamik %val{bufname}<ret>"
}
```

## Todo
- Document keybindings
