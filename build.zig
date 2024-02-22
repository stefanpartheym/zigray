const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zigray",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    var zigecs_dep = b.dependency("zig-ecs", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib_mod = b.addModule(
        "raylib",
        .{ .root_source_file = .{ .path = "src/raylib.zig" } },
    );
    exe.root_module.addImport("raylib", raylib_mod);
    exe.root_module.addImport("ecs", zigecs_dep.module("zig-ecs"));
    exe.linkLibC(); // LibC is required to link against raylib.
    exe.linkSystemLibrary("raylib");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
