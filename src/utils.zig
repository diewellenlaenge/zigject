const std = @import("std");
const heap = std.heap;

pub fn toWide(alloc: std.mem.Allocator, from: []const u8) ![]const u16 {
    return std.unicode.utf8ToUtf16LeWithNull(alloc, from);
}

pub fn toNarrow(alloc: std.mem.Allocator, from: []const u16) ![]const u8 {
    return std.unicode.utf16leToUtf8Alloc(alloc, from);
}

pub fn forcePtr(value: anytype) *anyopaque {
    return @intToPtr(*anyopaque, @ptrToInt(value));
}
