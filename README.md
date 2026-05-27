# zscan

**Tiny. Fast. `.gitignore`-aware.**

A blazing-fast file scanner written in Zig that respects `.gitignore` rules — including nested `.gitignore` files — while automatically skipping binary files.

Perfect for AI agents, code indexing, RAG pipelines, CLI tooling, and developer workflows.

---

## Why zscan?

Most file scanners are either:

* **Fast but huge**
* **Tiny but incomplete**
* **Ignore `.gitignore` semantics**
* **Or pull in massive dependencies**

`zscan` focuses on one thing:

> Scan source files correctly and extremely fast.

---

## Features

* ✅ Full `.gitignore` support
* ✅ Nested `.gitignore` scoping
* ✅ Automatically skips binary files
* ✅ Extremely small binary size
* ✅ Null-separated output (`-0`)
* ✅ Zero runtime dependencies
* ✅ Written in pure Zig

---

## Performance

### Windows

| Tool      |     Time | Binary Size |
| --------- | -------: | ----------: |
| **zscan** | **55ms** |    **88KB** |
| rg        |    230ms |       384KB |

### Linux

| Tool      |     Time | Binary Size |
| --------- | -------: | ----------: |
| **zscan** | **40ms** |    **60KB** |
| rg        |    444ms |       5.1MB |

---

## Example

### zscan

```sh
$ time zscan
.\.gitignore
.\build.zig
.\README.md
.\src\main.zig

real    0m0.055s
```

### ripgrep

```sh
$ time rg --files
src\main.zig
README.md
build.zig

real    0m0.230s
```

---

## Usage

```sh
zscan [root]
zscan -0 [root]
```

### Options

| Option | Description                          |
| ------ | ------------------------------------ |
| `root` | Directory to scan (default: `.`)     |
| `-0`   | Null-separated output for `xargs -0` |

---

## `.gitignore` Support

`zscan` correctly applies:

* Root `.gitignore`
* Nested `.gitignore`
* Scoped ignore rules per subtree

This makes it ideal for:

* AI coding agents
* Monorepos
* Code search
* Embedding pipelines
* Source indexing
* Build tooling

---

## Binary Detection

Binary files are skipped automatically using Git-style heuristics:

* Reads the first 8KB
* Detects null bytes
* Skips non-text files

---

## Installation

### Build from source

Requires Zig `0.16.0`.

```sh
zig build
```

---

## Philosophy

`zscan` is designed around a simple idea:

> Developer tools should be fast, correct, and small.

No giant dependency tree.
No runtime overhead.
No unnecessary features.

Just scan files fast.

---

## Use Cases

* AI Agent runtimes
* LLM context builders
* RAG preprocessing
* Source code indexing
* CLI pipelines
* Static analysis tools
* Lightweight developer tooling

---

## Tech Stack

* Language: Zig
* Dependency: None
* Output: Native single binary

---

## Roadmap

* [ ] `.ignore` support
* [ ] `.dockerignore` support
* [ ] Parallel directory walking
* [ ] File metadata output
* [ ] JSON mode
* [ ] WASI build target

---

## Star History

If you find `zscan` useful, consider giving it a star ⭐
