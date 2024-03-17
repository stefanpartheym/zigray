const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");
const state = @import("./state.zig");

pub const EngineInitOptions = struct {
    debug: struct {
        enable: bool = false,
    },
    display: struct {
        width: f32 = 800,
        height: f32 = 600,
        targetFps: u8 = 60,
        useHighDpi: bool = true,
        title: [:0]const u8 = "",
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

    pub fn start(self: *const Engine) void {
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
    }

    pub fn stop(self: *const Engine) void {
        _ = self;
        ray.CloseWindow();
    }

    pub fn toggleDebugMode(self: *Engine) void {
        self.state.debug.enabled = !self.state.debug.enabled;
    }

    pub fn isDebugModeEnabled(self: *const Engine) bool {
        return self.state.debug.enabled;
    }
};
