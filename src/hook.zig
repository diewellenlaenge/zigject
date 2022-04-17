const std = @import("std");
const builtin = @import("builtin");

pub const HookMethod = enum {
    JmpInstruction,
    RetInstruction,
    Int3Instruction,
    TrapFlag,
    DebugRegister0,
    DebugRegister1,
    DebugRegister2,
    DebugRegister3,
};

pub const HookError = error{
    UnsupportedCallingConvention,
    DifferentCallingConvention,
    UnsupportedHookMethd,
};

pub fn Hook(comptime orig_fn: anytype, comptime hook_pre_fn: anytype, comptime method: anytype) type {
    return struct {
        orig_fn: @TypeOf(orig_fn) = orig_fn,
        hook_pre_fn: @TypeOf(hook_pre_fn) = hook_pre_fn,
        method: @TypeOf(method) = method,
        trampoline_fn: ?@TypeOf(orig_fn) = null,
    };
}

pub fn hook_pre(hook: anytype) HookError!@TypeOf(hook) {
    const orig_ti = @typeInfo(@TypeOf(hook.orig_fn)).Fn;
    const hook_pre_ti = @typeInfo(@TypeOf(hook.hook_pre_fn)).Fn;

    const orig_cc = orig_ti.calling_convention;
    const hook_pre_cc = hook_pre_ti.calling_convention;

    // TODO: not only compare calling convention, but everything
    if (orig_cc != hook_pre_cc) {
        return HookError.DifferentCallingConvention;
    }

    var hook_ = switch (hook.method) {
        .JmpInstruction => try hook_jmp(hook),
        else => return HookError.UnsupportedHookMethd,
    };

    // switch (orig_ti.calling_convention) {
    //     .C => try hook_pre_x64call(orig_fn, hook_pre_fn, method),
    //     else => return HookError.UnsupportedCallingConvention,
    // }

    return hook_;
}

pub fn hook_pre_old(comptime orig_fn: anytype, comptime hook_pre_fn: anytype, method: HookMethod) HookError!Hook {
    const orig_ti = @typeInfo(@TypeOf(orig_fn)).Fn;
    const hook_pre_ti = @typeInfo(@TypeOf(hook_pre_fn)).Fn;

    const orig_cc = orig_ti.calling_convention;
    const hook_pre_cc = hook_pre_ti.calling_convention;

    // TODO: not only compare calling convention, but everything
    if (orig_cc != hook_pre_cc) {
        return HookError.DifferentCallingConvention;
    }

    var hook = Hook{ .orig_fn = orig_fn, .hook_pre_fn = hook_pre_fn, .method = method, .trampoline_fn = undefined };

    hook = switch (method) {
        .JmpInstruction => try hook_jmp(hook),
        else => return HookError.UnsupportedHookMethd,
    };

    switch (orig_ti.calling_convention) {
        .C => try hook_pre_x64call(orig_fn, hook_pre_fn, method),
        else => return HookError.UnsupportedCallingConvention,
    }

    return hook;
}

/// helper to "just" hook something and don't care about technical details
pub fn hook_simple(comptime orig_fn: anytype, comptime hook_pre_fn: anytype) HookError!Hook {
    return hook_pre(orig_fn, hook_pre_fn, HookMethod.JmpInstruction);
}

pub fn hook_jmp(hook: anytype) HookError!@TypeOf(hook) {
    var hook_ = hook;
    hook_.method = HookMethod.DebugRegister1;
    return hook_;
}

// https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention
// The code for a typical prolog might be:
//    mov    [RSP + 8], RCX
//    push   R15
//    push   R14
//    push   R13
//    sub    RSP, fixed-allocation-size
//    lea    R13, 128[RSP]
fn hook_pre_x64call(comptime orig_fn: anytype, comptime hook_pre_fn: anytype, method: HookMethod) HookError!void {
    _ = orig_fn;
    _ = hook_pre_fn;
    _ = method;
}
