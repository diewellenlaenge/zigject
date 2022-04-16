pub fn generate_fn_type(comptime calling_convention: anytype) type {
    return fn (p1: u32, p2: u32, p3: u32, p4: u32, p5: u32) callconv(calling_convention) u32;
}
