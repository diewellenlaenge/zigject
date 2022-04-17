const std = @import("std");
const builtin = @import("builtin");

pub const HookMethod = enum {
    JmpInstruction,
    RetInstruction,
};

pub const HookError = error{
    UnsupportedCallingConvention,
    DifferentCallingConvention,
};

pub fn hook_pre(comptime orig_fn: anytype, comptime hook_pre_fn: anytype, method: HookMethod) HookError!void {
    const orig_ti = @typeInfo(@TypeOf(orig_fn)).Fn;
    const hook_pre_ti = @typeInfo(@TypeOf(hook_pre_fn)).Fn;

    const orig_cc = orig_ti.calling_convention;
    const hook_pre_cc = hook_pre_ti.calling_convention;

    // TODO: not only compare calling convention, but everything
    if (orig_cc != hook_pre_cc) {
        return HookError.DifferentCallingConvention;
    }

    switch (orig_ti.calling_convention) {
        .C => hook_pre_x64call(orig_fn, hook_pre_fn, method),
        else => return HookError.UnsupportedCallingConvention,
    }
}

// https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention
// The code for a typical prolog might be:
//    mov    [RSP + 8], RCX
//    push   R15
//    push   R14
//    push   R13
//    sub    RSP, fixed-allocation-size
//    lea    R13, 128[RSP]
fn hook_pre_x64call(comptime orig_fn: anytype, comptime hook_pre_fn: anytype, method: HookMethod) HookError!void {}
