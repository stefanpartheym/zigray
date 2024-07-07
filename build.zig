const std = @import("std");
const path = std.Build.path;

pub fn build(b: *std.Build) void {
    const options = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    };

    // Provide the engine as library.
    const lib = b.addStaticLibrary(.{
        .name = "zigray",
        .root_source_file = path(b, "src/root.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    b.installArtifact(lib);

    // Provide an executable for the test game using the engine.
    const exe = b.addExecutable(.{
        .name = "zigray",
        .root_source_file = path(b, "src/main.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    b.installArtifact(exe);

    // Dependencies
    const zigecs_dep = b.dependency("zig-ecs", options);
    const raylib_dep = b.dependency("raylib-zig", options);

    // TODO: Add the dependencies to the library.

    // Add the dependencies to the executable.
    exe.root_module.addImport("raylib", raylib_dep.module("raylib"));
    exe.root_module.addImport("ecs", zigecs_dep.module("zig-ecs"));
    exe.linkLibrary(raylib_dep.artifact("raylib"));

    // Run executable.
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the test game");
    run_step.dependOn(&run_cmd.step);

    // Declare library tests.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = path(b, "src/root.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Declare executable tests.
    const exe_unit_tests = b.addTest(.{
        .root_source_file = path(b, "src/main.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Run tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
