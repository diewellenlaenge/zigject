const std = @import("std");
const io = std.io;
const heap = std.heap;
const win = std.os.windows;
const fs = std.fs;

const zigject = @import("zigject");
const win32 = @import("win32");

fn toWide(from: []const u8) ![]const u16 {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    return std.unicode.utf8ToUtf16LeWithNull(alloc, from);
}

fn toNarrow(from: []const u16) ![]const u8 {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    return std.unicode.utf16leToUtf8Alloc(alloc, from);
}

pub fn main() anyerror!void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    var args = try std.process.argsWithAllocator(alloc);
    const base_path = try args.next(alloc).?;
    defer alloc.free(base_path);

    var concat_str = std.ArrayList(u8).init(alloc);
    defer concat_str.deinit();
    try concat_str.appendSlice(base_path);
    try concat_str.appendSlice("/../../lib/zigject-injectee.dll");

    var buf = [_]u8{0} ** win.MAX_PATH;
    std.mem.copy(u8, &buf, try concat_str.toOwnedSliceSentinel(0));
    const path_len = try win.normalizePath(u8, &buf);

    const normalized = buf[0..path_len];
    std.log.info("normalized {s} with len {d}", .{normalized, normalized.len});
    const proc = try toWide("Notepad.exe");
    const dll = try toWide(normalized);

    const pid = zigject.process.FindFirstProcessIdByName(proc) catch {
        std.log.err("Could not find process {s}", .{try toNarrow(proc)});
        return;
    };

    std.log.info("Found process {s} with dll {s}", .{ try toNarrow(proc), try toNarrow(dll) });

    std.log.info("Process found with id {d}", .{pid});

    _ = try zigject.inject.RemoteThread(pid, proc, true);
}
