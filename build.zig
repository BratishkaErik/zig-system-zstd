// SPDX-FileCopyrightText: 2024 Eric Joldasov
//
// SPDX-License-Identifier: CC0-1.0

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-system-zstd",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    exe.root_module.addImport("self", &exe.root_module);

    const use_system_zstd = b.systemIntegrationOption("zstd", .{});
    switch (use_system_zstd) {
        true => exe.root_module.linkSystemLibrary("zstd", .{}),
        else => if (b.lazyDependency("zstd_from_source", .{})) |zstd_from_source| {
            exe.root_module.linkLibrary(zstd_from_source.artifact("zstd"));
        },
    }

    b.installArtifact(exe);
}
