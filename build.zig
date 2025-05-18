// SPDX-FileCopyrightText: 2024 Eric Joldasov
//
// SPDX-License-Identifier: 0BSD

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    main_mod.addImport("self", main_mod);

    const use_system_zstd = b.systemIntegrationOption("zstd", .{});
    switch (use_system_zstd) {
        true => main_mod.linkSystemLibrary("zstd", .{}),
        else => vendor_zstd: {
            const zstd_from_source = b.lazyDependency(
                "zstd_from_source",
                .{ .target = target, .optimize = optimize },
            ) orelse break :vendor_zstd;
            main_mod.linkLibrary(zstd_from_source.artifact("zstd"));
        },
    }

    const exe = b.addExecutable(.{
        .name = "zig-system-zstd",
        .root_module = main_mod,
    });
    b.installArtifact(exe);
}
