const builtin = @import("builtin");

pub fn generate_fn_type(comptime fn_type: anytype, comptime calling_convention: anytype) type {
    var ti = @typeInfo(@TypeOf(fn_type));
    ti.Fn.calling_convention = calling_convention;
    return @Type(ti);
}
