const std = @import("std");
const zigject = @import("zigject");

pub fn main() anyerror!void {
    const notepad = 19300;
    const dll = "C:\\Users\\Admin\\Coding\\diewellenlaenge\\zigject\\zig-out\\lib\\zigject-injectee.dll";
    _ = try zigject.inject.RemoteThread(notepad, dll);
}
