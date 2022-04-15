const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    {
        const exe = b.addExecutable("zigject-injecter", "test/injecter.zig");
        exe.addPackagePath("zigject", "src/zigject.zig");
        exe.addPackagePath("win32", "src/lib/zigwin32/win32.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const lib = b.addSharedLibrary("zigject-injectee", "test/injectee.zig", std.build.LibExeObjStep.SharedLibKind.unversioned);
        lib.addPackagePath("win32", "src/lib/zigwin32/win32.zig");
        lib.setBuildMode(mode);
        lib.install();
    }
}
