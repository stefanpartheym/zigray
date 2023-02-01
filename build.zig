const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Packages
    const ecsPackage = std.build.Pkg{
        .name = "ecs",
        .path = std.build.FileSource{ .path = "deps/zig-ecs/src/ecs.zig" },
    };
    const raylibPackage = std.build.Pkg{
        .name = "raylib",
        .path = std.build.FileSource{ .path = "src/raylib.zig" },
    };
    const componentsPackage = std.build.Pkg{
        .name = "components",
        .path = std.build.FileSource{ .path = "src/components/components.zig" },
    };
    const packages = [_]std.build.Pkg{
        ecsPackage,
        raylibPackage,
        componentsPackage,
        std.build.Pkg{
            .name = "modules",
            .path = std.build.FileSource{ .path = "src/modules/modules.zig" },
            .dependencies = &.{ ecsPackage, raylibPackage, componentsPackage },
        },
    };

    // Defaults
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Executable
    const exe = b.addExecutable("zigray", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC(); // LibC is required to link against raylib.
    exe.linkSystemLibrary("raylib");
    exe.install();

    for (packages) |pkg| exe.addPackage(pkg);

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
    exe_tests.linkLibC();
    exe_tests.linkSystemLibrary("raylib");

    for (packages) |pkg| exe_tests.addPackage(pkg);

    // Command: test
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
