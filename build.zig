const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Defaults
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Executable
    const exe = b.addExecutable("zigray", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    // Command: run
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const exe_tests = b.addTest("src/test.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    // Command: test
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
