const std = @import("std");
const io = std.io;
const heap = std.heap;
const win = std.os.windows;
const fs = std.fs;

const zigject = @import("zigject");
const utils = zigject.utils;
const win32 = @import("win32");

pub fn main() anyerror!void {
    var out_buf = [_]u8{0} ** win.MAX_PATH;
    const current_exe_dir = try std.fs.selfExeDirPath(&out_buf);

    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var joined_paths = try std.fs.path.join(alloc, &.{current_exe_dir, "../lib/zigject-injectee.dll"});
    defer alloc.free(joined_paths);

    var buf = [_]u8{0} ** win.MAX_PATH;
    std.mem.copy(u8, &buf, joined_paths);

    const path_len = try win.normalizePath(u8, &buf);
    const normalized = buf[0..path_len];
    std.log.info("normalized {s} with len {d}", .{normalized, normalized.len});

    const proc = try utils.toWide(alloc, "Notepad.exe");
    defer alloc.free(proc);
    const dll = try utils.toWide(alloc, normalized);
    defer alloc.free(dll);

    const proc_str = try utils.toNarrow(alloc, proc);
    defer alloc.free(proc_str);

    const pid = zigject.process.findFirstProcessIdByName(proc) catch {
        std.log.err("Could not find process {s}", .{proc_str});
        return;
    };

    const dll_str = try utils.toNarrow(alloc, dll);
    defer alloc.free(dll_str);

    std.log.info("Found process {s} with dll {s}", .{proc_str, dll_str});
    std.log.info("Process found with id {d}", .{pid});

    _ = try zigject.inject.remoteThread(pid, dll, true);
}
