const std = @import("std");
const zigject = @import("zigject");
const utils = @import("utils.zig");

var random_global: u32 = 12345;
var a1: u32 = 10;
var a2: u32 = 20;
var a3: u32 = 30;
var a4: u32 = 40;
var a5: u32 = 50;

var orig_stdcall: ?utils.generate_fn_type(stdcall, .Stdcall) = null;
var orig_thiscall: ?utils.generate_fn_type(thiscall, .Thiscall) = null;
var orig_fastcall: ?utils.generate_fn_type(fastcall, .Fastcall) = null;
var orig_vectorcall: ?utils.generate_fn_type(vectorcall, .Vectorcall) = null;
var orig_zigcall: ?utils.generate_fn_type(zigcall, .Unspecified) = null;
//var orig_x86naked: ?utils.generate_fn_type(x86naked, .Naked) = null;

pub fn call() anyerror!void {
    std.log.info("x86 call()", .{});

    var res: u32 = 0;

    std.log.info("", .{});
    try zigject.hook.hook_pre(stdcall, hook_pre_stdcall);
    std.log.info("calling   stdcall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = stdcall(a1, a2, a3, a4, a5);
    std.log.info("result    stdcall(): {d}", .{res});

    std.log.info("", .{});
    try zigject.hook.hook_pre(thiscall, hook_pre_thiscall);
    std.log.info("calling   thiscall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = thiscall(a1, a2, a3, a4, a5);
    std.log.info("result    thiscall(): {d}", .{res});

    std.log.info("", .{});
    try zigject.hook.hook_pre(fastcall, hook_pre_fastcall);
    std.log.info("calling   fastcall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = fastcall(a1, a2, a3, a4, a5);
    std.log.info("result    fastcall(): {d}", .{res});

    std.log.info("", .{});
    try zigject.hook.hook_pre(vectorcall, hook_pre_vectorcall);
    std.log.info("calling   vectorcall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = vectorcall(a1, a2, a3, a4, a5);
    std.log.info("result    vectorcall(): {d}", .{res});

    std.log.info("", .{});
    try zigject.hook.hook_pre(zigcall, hook_pre_zigcall);
    std.log.info("calling   zigcall({d}, {d}, {d}, {d}, {d})", .{ a1, a2, a3, a4, a5 });
    res = zigcall(a1, a2, a3, a4, a5);
    std.log.info("result    zigcall(): {d}", .{res});

    //std.log.info("", .{});
    //std.log.info("calling   x86naked()", .{});
    //asm volatile (
    //    \\jmp x86naked
    //    \\x86naked_return:
    //);
    //std.log.info("result    x86naked(): n/a", .{});
}

//
//
//
fn stdcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Stdcall) u32 {
    std.log.info("orig      stdcall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_stdcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Stdcall) u32 {
    std.log.info("hook_pre  stdcall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_stdcall.?(p1, p2, p3, p4, p5);
}

//
//
//
fn thiscall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Thiscall) u32 {
    std.log.info("orig      thiscall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_thiscall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Thiscall) u32 {
    std.log.info("hook_pre  thiscall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_thiscall.?(p1, p2, p3, p4, p5);
}

//
//
//
fn fastcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Fastcall) u32 {
    std.log.info("orig      fastcall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_fastcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Fastcall) u32 {
    std.log.info("hook_pre  fastcall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_fastcall.?(p1, p2, p3, p4, p5);
}

//
//
//
fn vectorcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Vectorcall) u32 {
    std.log.info("orig      vectorcall({d}, {d}, {d}, {d}, {d}) -> {d}", .{ p1, p2, p3, p4, p5, random_global });
    return random_global;
}

fn hook_pre_vectorcall(p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(.Vectorcall) u32 {
    std.log.info("hook_pre  vectorcall({d}, {d}, {d}, {d}, {d})", .{ p1, p2, p3, p4, p5 });
    return orig_vectorcall.?(p1, p2, p3, p4, p5);
}

//
//
// "zigcall" (zig internals calling   convention is not well-defined)
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
// TODO: doesn't work with x86, why?
//export fn x86naked() callconv(.Naked) void {
//    std.log.info("orig      x86naked()", .{});
//    asm volatile ("jmp x86naked_return");
//}
//
//fn hook_pre_x86naked() callconv(.Naked) void {
//    // TODO
//}
