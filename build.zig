const std = @import("std");
const Build = std.Build;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // get c library
    const lmdb_dep = b.dependency("lmdb", .{ .target = target, .optimize = optimize });
    const lmdb_path = lmdb_dep.path("libraries/liblmdb");

    // expose c library as zig library
    const translate_c = b.addTranslateC(.{
        .root_source_file = lmdb_path.path(b, "lmdb.h"),
        .target = target,
        .optimize = optimize,
    });

    const liblmdb_a = b.addStaticLibrary(.{
        .name = "lmdb",
        .target = target,
        .optimize = optimize,
    });
    // build c library
    liblmdb_a.addCSourceFiles(.{
        .root = lmdb_path,
        .files = &.{ "mdb.c", "midl.c" },
    });

    liblmdb_a.installHeadersDirectory(lmdb_path, "", .{ .include_extensions = &.{"lmdb.h"} });
    liblmdb_a.addIncludePath(lmdb_path);
    liblmdb_a.linkLibC();
    liblmdb_a.installHeader(lmdb_dep.path("libraries/liblmdb/lmdb.h"), "lmdb.h");
    b.installArtifact(liblmdb_a);

    const mod = b.addModule("lmdb", .{
        .root_source_file = translate_c.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{ b.install_path, "include" }) });
    mod.linkLibrary(liblmdb_a);
    mod.addIncludePath(lmdb_path);

    // test c library in zig
    const test_step = b.step("test", "Run tests");
    const tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("test.zig"),
    });
    tests.root_module.addImport("lmdb", mod);
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
