const std = @import("std");
const builtin = @import("builtin");

// all calling conventions: https://github.com/ziglang/zig/blob/0576086395774389a9f38d960f9ed5102a813bdb/lib/std/builtin.zig#L134
// skip for now: async, inline, interrupt, signal, APCS, AAPCS, AAPCSVFP

pub fn main() anyerror!void {
    std.log.info("hooker()", .{});

    try switch (builtin.target.cpu.arch) {
        .i386 => @import("hooker_x86.zig").call(),
        .x86_64 => @import("hooker_x86_64.zig").call(),
        else => unreachable,
    };
}
