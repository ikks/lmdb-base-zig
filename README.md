Build and use LMDB in zig.

# Build Dependencies

[Zig 0.13](https://ziglang.org/download/)

# Usage

Supported use cases:
- [⬇️](#build-lmdb) Build a LMDB static library using the zig build system.
- [⬇️](#import-lmdb-in-a-zig-project) Import LMDB in a zig project.

## Build LMDB
Clone this repository, then run `zig build`. 

You will find a statically linked `lmdb` archive in `zig-out/lib/liblmdb.a`.

You can use this with any language or build system.

## Import LMDB in a Zig project

Fetch `lmdb` and save it to your `build.zig.zon`:
```
zig fetch --save=lmdb https://github.com/Syndica/lmdb-zig/archive/<COMMIT_HASH>.tar.gz
```

Add the import to a module:
```zig
const lmdb = b.dependency("lmdb", .{}).module("lmdb");
exe.root_module.addImport("lmdb", lmdb);
```

Import the `lmdb` module.
```zig
const lmdb = @import("lmdb");
```

## Test / Example

For a unit test demonstrating basic usage of lmdb, see `test.zig`. Run the test with `zig build test`.
