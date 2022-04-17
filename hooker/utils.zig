const std = @import("std");
const gpa = std.heap.GeneralPurposeAllocator;

pub fn generate_fn_type(comptime fn_type: anytype, comptime calling_convention: std.builtin.CallingConvention) type {
    var ti = @typeInfo(@TypeOf(fn_type));
    ti.Fn.calling_convention = calling_convention;
    return @Type(ti);
}
