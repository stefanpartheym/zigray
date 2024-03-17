const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");
const state = @import("state.zig");

pub const EngineInitOptions = struct {
    debug: struct {
        enable: bool = false,
    },
    display: struct {
        targetFps: u8 = 160,
        width: f32,
        height: f32,
        useHighDpi: bool,
        title: [:0]const u8,
    },
};

pub const Engine = struct {
    allocator: std.mem.Allocator,
    registry: ecs.Registry,
    state: state.EngineState,

    pub fn init(allocator: std.mem.Allocator, options: EngineInitOptions) Engine {
        return Engine{
            .allocator = allocator,
            .registry = ecs.Registry.init(allocator),
            .state = state.EngineState{
                .status = .STOPPED,
                .debug = .{
                    .enabled = options.debug.enable,
                },
                .display = .{
                    .width = options.display.width,
                    .height = options.display.height,
                    .targetFps = options.display.targetFps,
                    .useHighDpi = options.display.useHighDpi,
                    .title = options.display.title,
                },
            },
        };
    }

    pub fn deinit(self: *Engine) void {
        self.registry.deinit();
    }

    pub fn start(self: *Engine) void {
        const display = self.state.display;
        if (display.useHighDpi) {
            ray.SetConfigFlags(ray.FLAG_WINDOW_HIGHDPI);
        }
        ray.SetTraceLogLevel(ray.LOG_WARNING);
        ray.SetTargetFPS(display.targetFps);
        ray.InitWindow(
            @as(i32, @intFromFloat(display.width)),
            @as(i32, @intFromFloat(display.height)),
            display.title,
        );

        self.changeStatus(.RUNNING);
    }

    pub fn stop(self: *const Engine) void {
        _ = self;
        ray.CloseWindow();
    }

    pub fn changeStatus(self: *Engine, newStatus: state.EngineStatus) void {
        self.state.status = newStatus;
    }

    pub fn isRunning(self: *const Engine) bool {
        return self.state.status == .RUNNING;
    }

    pub fn toggleDebugMode(self: *Engine) void {
        self.state.debug.enabled = !self.state.debug.enabled;
    }

    pub fn isDebugModeEnabled(self: *const Engine) bool {
        return self.state.debug.enabled;
    }
};
