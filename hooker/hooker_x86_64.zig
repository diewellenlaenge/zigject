const std = @import("std");
const zigject = @import("zigject");
const utils = @import("utils.zig");

var random_global: u32 = 12345;
var a1: u32 = 10;
var a2: u32 = 20;
var a3: u32 = 30;
var a4: u32 = 40;
var a5: u32 = 50;

//var orig_x64call: ?@TypeOf(x64call) = null;
var orig_sysvcall: ?@TypeOf(sysvcall) = null;
var orig_zigcall: ?@TypeOf(zigcall) = null;
//var orig_x64naked: ?@TypeOf(x64naked) = null;

var orig_x64call: zigject.hook.Hook(x64call, hook_pre_x64call, zigject.hook.HookMethod.JmpInstruction) = undefined;

pub fn call() anyerror!void {
    std.log.info("x86_64 call()", .{});

    var res: u32 = 0;

    std.log.info("", .{});
    orig_x64call = try zigject.hook.hook_pre(orig_x64call);
    std.log.info("calling   x64call({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = x64call(a1, a2, a3, a4, a5);
    std.log.info("result    x64call(): {d}", .{res});

    // std.log.info("", .{});
    // try zigject.hook.hook_pre(sysvcall, hook_pre_sysvcall, zigject.hook.HookMethod.JmpInstruction);
    // std.log.info("calling   sysv({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    // res = sysvcall(a1, a2, a3, a4, a5);
    // std.log.info("result    sysv(): {d}", .{res});

    // std.log.info("", .{});
    // try zigject.hook.hook_pre(zigcall, hook_pre_zigcall, zigject.hook.HookMethod.JmpInstruction);
    // std.log.info("calling   zigcall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    // res = zigcall(a1, a2, a3, a4, a5);
    // std.log.info("result    zigcall(): {d}", .{res});

    // std.log.info("", .{});
    // try zigject.hook.hook_pre(x64naked, hook_pre_x64naked, zigject.hook.HookMethod.JmpInstruction);
    // std.log.info("calling   x64naked()", .{});
    // asm volatile ("jmp x64naked");
    // asm volatile ("x64naked_return:");
    // std.log.info("result from x64naked(): n/a", .{});
}

//
//
// .C propagates to Microsoft x64 calling convention on 64bit target
fn x64call(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.C) u32 {
    std.log.info("orig      x64call({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_x64call(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.C) u32 {
    std.log.info("hook_pre  x64call({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_x64call.trampoline_fn.?(p1, p2, p3, p4, p5);
}

//
//
//
fn sysvcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.SysV) u32 {
    std.log.info("orig      sysvcall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_sysvcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.SysV) u32 {
    std.log.info("hook_pre  sysvcall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_sysvcall.?(p1, p2, p3, p4, p5);
}

//
//
// "zigcall" (zig internals calling convention is not well-defined)
fn zigcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Unspecified) u32 {
    std.log.info("orig      zigcall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_zigcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Unspecified) u32 {
    std.log.info("hook_pre  zigcall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_zigcall.?(p1, p2, p3, p4, p5);
}

//
//
//
// export fn x64naked() callconv(.Naked) void {
//     std.log.info("orig      naked()", .{});
//     asm volatile ("jmp x64naked_return");
// }

// fn hook_pre_x64naked() callconv(.Naked) void {
//     // TODO
// }
