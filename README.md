# zscan — file scanner with .gitignore support

Scans a directory tree and prints file paths, respecting `.gitignore` rules including nested `.gitignore` files. Automatically skips binary files.

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
