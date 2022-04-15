const std = @import("std");
const heap = std.heap;

pub fn logUtf16String(utf16string: []const u16) !void {
    var gpallocator = heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpallocator.allocator();

    const utf8string = try std.unicode.utf16leToUtf8Alloc(alloc, utf16string);
    defer alloc.free(utf8string);

    std.log.info("{s}\n", .{utf8string});
}

