const std = @import("std");
const io = std.io;
const heap = std.heap;

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

fn getOutput(comptime what: []const u8, comptime default: []const u8) anyerror![]const u8 {
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();

    try stdout.print("Enter {s}: (default: {s}) ", .{ what, default });

    var buf = [_]u8{0} ** 260;
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |input| {
        if (std.ascii.eqlIgnoreCase(input, "")) {
            return input;
        }
    }
    return default;
}

pub fn main() anyerror!void {
    const proc = try toWide(try getOutput("Proccess", "Notepad.exe"));
    var dll = try toWide(try getOutput("Dll", ".\\zig-out\\lib\\zigject-injectee.dll"));

    var buf = [_]u16{0} ** std.os.windows.MAX_PATH;

    _ = win32.storage.file_system.GetFullPathNameW(@ptrCast([*:0]const u16, &dll), buf.len, &buf, null);

    const pid = zigject.process.FindFirstProcessIdByName(proc) catch {
        std.log.err("Could not find process {s}", .{try toNarrow(proc)});
        return;
    };

    std.log.info("Found process {s} with dll {s}", .{ try toNarrow(proc), try toNarrow(dll) });

    std.log.info("Process found with id {d}", .{pid});

    _ = try zigject.inject.RemoteThread(pid, buf[0..], true);
}
