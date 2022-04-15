const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;
const zigject = @import("zigject");

pub fn main() anyerror!void {
    const notepad = 32464;
    const dll = L("C:\\Users\\Admin\\GitHub\\diewellenlaenge\\zigject\\zig-out\\lib\\zigject-injectee.dll");
    _ = try zigject.inject.RemoteThread(notepad, dll);
}
