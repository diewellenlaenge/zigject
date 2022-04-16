const callcon = @import("builtin").CallingConvention;

pub fn generate_fn_type(comptime calling_convention: anytype) type {
    return fn (p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(calling_convention) u32;
}

//pub fn generate_fn_type(comptime fn_type: anytype, comptime calling_conv: callcon) type {
//    var construct_fn = @typeInfo(@TypeOf(fn_type)).Fn;
//    construct_fn.calling_convention = calling_conv;
//    return @Type(construct_fn);
//}
