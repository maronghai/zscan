# zscan — file scanner with .gitignore support

Scans a directory tree and prints file paths, respecting `.gitignore` rules including nested `.gitignore` files. Automatically skips binary files.


x | time@win | size@win | time@linux | size@linx
--- | --: | --: | --: | --:
zscan | 55ms | 88K | 40ms | 60KB
rg | 230ms | 384K | 444ms | 5.1MB


## win

### time@win

```sh
$ time zscan
.\.gitignore
.\build.zig
.\README.md
.\src\main.zig

real    0m0.055s
user    0m0.015s
sys     0m0.015s


$ time rg --files
src\main.zig
README.md
build.zig

real    0m0.230s
user    0m0.000s
sys     0m0.031s
```

### size@win

```sh
$ du -sh `which rg zscan`
384K    rg
88K     zscan
```

## Usage

```
zscan [root]
zscan -0 [root]
```

- `root` — directory to scan (default: `.`)
- `-0` — null-separated output instead of newlines (for piping to `xargs -0`)

## Features

- Reads `.gitignore` from the root directory and applies its rules
- Supports nested `.gitignore` — each subdirectory's rules are scoped to that subtree
- Binary detection — skips files containing null bytes in the first 8KB (git's heuristic)
- `-0` flag for safe handling of filenames with special characters

## Build

Requires Zig 0.16.0.

```
zig build
```
