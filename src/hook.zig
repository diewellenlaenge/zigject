const std = @import("std");
const builtin = @import("builtin");

pub const HookError = error{
    DifferentCallingConvention,
};

pub fn hook_pre(comptime orig_fn: anytype, comptime hook_pre_fn: anytype) HookError!void {
    const orig_ti = @typeInfo(@TypeOf(orig_fn)).Fn;
    const hook_pre_ti = @typeInfo(@TypeOf(hook_pre_fn)).Fn;

    const orig_cc = orig_ti.calling_convention;
    const hook_pre_cc = hook_pre_ti.calling_convention;

    if (orig_cc != hook_pre_cc) {
        return HookError.DifferentCallingConvention;
    }
}
