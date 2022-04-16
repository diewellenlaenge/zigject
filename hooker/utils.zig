const builtin = @import("builtin");

pub fn generate_fn_type(comptime fn_type: anytype, comptime calling_convention: builtin.CallingConvention) type {
    var construct_fn = @typeInfo(@TypeOf(fn_type)).Fn;
    construct_fn.calling_convention = calling_convention;
    return @Type(construct_fn);
}
