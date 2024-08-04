const std = @import("std");

pub fn build(b: *std.Build) void {
    const options = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    };

    // Dependencies
    const zigecs_dep = b.dependency("entt", options);
    const raylib_dep = b.dependency("raylib-zig", options);

    // Provide the engine as module.
    const mod = b.addModule("zigray", .{
        .root_source_file = b.path("src/root.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    // Add dependencies to the module.
    mod.addImport("raylib", raylib_dep.module("raylib"));
    mod.addImport("ecs", zigecs_dep.module("zig-ecs"));
    mod.linkLibrary(raylib_dep.artifact("raylib"));

    // Provide an executable for the test game using the engine.
    const exe = b.addExecutable(.{
        .name = "zigray",
        .root_source_file = b.path("src/main.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    b.installArtifact(exe);

    // Add dependencies to the executable.
    // TODO: Use the module provided as `mod`.
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
        .root_source_file = b.path("src/root.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Declare executable tests.
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Run tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
