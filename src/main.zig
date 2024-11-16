// SPDX-FileCopyrightText: 2024 Eric Joldasov
//
// SPDX-License-Identifier: CC0-1.0
const std = @import("std");

const c = @cImport({
    @cInclude("zstd.h");
});

pub fn main() error{ OutOfMemory, CompressionFailed, DecompressionFailed }!void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const source = @embedFile("self");

    // First compress this file
    const worst_case_len = c.ZSTD_compressBound(source.len);
    std.log.debug("worst_case_len = {d}", .{worst_case_len});
    if (c.ZSTD_isError(worst_case_len) != 0) {
        std.log.err("error when calculating compress bound: {s}", .{c.ZSTD_getErrorName(worst_case_len)});
        return error.CompressionFailed;
    }

    const compressed = try allocator.alloc(u8, worst_case_len);
    defer allocator.free(compressed);

    const compressed_len = c.ZSTD_compress(compressed.ptr, compressed.len, source.ptr, source.len, 5);
    std.log.debug("compressed_len = {d}", .{compressed_len});
    if (c.ZSTD_isError(compressed_len) != 0) {
        std.log.err("error when compressing: {s}", .{c.ZSTD_getErrorName(compressed_len)});
        return error.CompressionFailed;
    }

    std.log.debug("compressed = {s}", .{std.fmt.fmtSliceHexUpper(compressed[0..compressed_len])});

    // Now decompress
    const decompressed = try allocator.alloc(u8, source.len);
    defer allocator.free(decompressed);

    const decompressed_len = c.ZSTD_decompress(decompressed.ptr, decompressed.len, compressed.ptr, compressed_len);
    std.log.debug("decompressed_len = {d}", .{decompressed_len});
    if (c.ZSTD_isError(decompressed_len) != 0) {
        std.log.err("error when decompressing: {s}", .{c.ZSTD_getErrorName(decompressed_len)});
        return error.DecompressionFailed;
    }

    std.log.debug("decompressed = {s}", .{decompressed});

    std.testing.expectEqual(decompressed_len, source.len) catch return error.DecompressionFailed;
}
