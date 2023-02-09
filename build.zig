const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    declareModules(b);

    const ecsLibrary = b.addStaticLibrary(.{
        .name = "ecs",
        .root_source_file = std.build.FileSource{ .path = "deps/zig-ecs/src/ecs.zig" },
        .target = target,
        .optimize = optimize
    });
    // lib.setMainPkgPath("deps/zig-ecs/src/ecs.zig");
    ecsLibrary.install();

    // Executable
    const exe = b.addExecutable(.{
        .name = "zigray",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC(); // LibC is required to link against raylib.
    exe.linkSystemLibrary("raylib");
    exe.linkLibrary(ecsLibrary);
    exe.install();

    // Add modules to executable
    for (b.modules.keys()) |moduleKey| {
        exe.addModule(moduleKey, b.modules.get(moduleKey).?);
    }

    // Command: run
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe_tests.linkLibC();
    exe_tests.linkSystemLibrary("raylib");

    // Command: test
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

fn declareModules(b: *std.build.Builder) void {
    b.addModule(.{
        .name = "ecs",
        .source_file = std.build.FileSource{ .path = "deps/zig-ecs/src/ecs.zig" },
    });
    b.addModule(.{
        .name = "raylib",
        .source_file = std.build.FileSource{ .path = "src/raylib.zig" },
    });
}
