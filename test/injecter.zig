const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;
const zigject = @import("zigject");

pub fn main() anyerror!void {
    const notepad = 36068;
    const dll = L("C:\\Users\\Admin\\GitHub\\diewellenlaenge\\zigject\\zig-out\\lib\\zigject-injectee.dll");
    const module = try zigject.inject.RemoteThread(notepad, dll);
    std.log.info("module: {x}\n", .{module});
}
