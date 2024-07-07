const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const gfx = @import("../graphics/main.zig");
const components = @import("../ecs/components.zig");
const config = @import("./config.zig");

pub const EngineState = enum {
    STOPPED,
    RUNNING,
};

pub const Engine = struct {
    allocator: std.mem.Allocator,
    registry: ecs.Registry,
    state: EngineState,
    config: config.EngineConfig,
    background: ?components.Visual,
    textureStore: gfx.TextureStore,

    pub fn init(allocator: std.mem.Allocator, options: config.EngineConfig) Engine {
        return Engine{
            .allocator = allocator,
            .registry = ecs.Registry.init(allocator),
            .state = .STOPPED,
            .config = options,
            .background = null,
            .textureStore = gfx.TextureStore.init(allocator),
        };
    }

    pub fn deinit(self: *Engine) void {
        self.textureStore.deinit();
        self.registry.deinit();
    }

    pub fn start(self: *Engine) void {
        const display = self.config.display;
        rl.setConfigFlags(.{
            .window_highdpi = display.useHighDpi,
        });
        rl.setTraceLogLevel(rl.TraceLogLevel.log_warning);
        rl.setTargetFPS(display.targetFps);
        rl.initWindow(
            @as(i32, @intFromFloat(display.width)),
            @as(i32, @intFromFloat(display.height)),
            display.title,
        );

        self.changeState(.RUNNING);
    }

    pub fn stop(self: *Engine) void {
        // Unloading textures must happen before closing the window.
        self.textureStore.unloadAll();
        rl.closeWindow();
    }

    pub fn getEcsRegistry(self: *Engine) *ecs.Registry {
        return &self.registry;
    }

    pub fn getDeltaTime(_: *const Engine) f32 {
        return rl.getFrameTime();
    }

    pub fn changeState(self: *Engine, newState: EngineState) void {
        self.state = newState;
    }

    pub fn isRunning(self: *const Engine) bool {
        return self.state == .RUNNING;
    }

    pub fn toggleDebugMode(self: *Engine) void {
        self.config.debug.enabled = !self.config.debug.enabled;
    }

    pub fn isDebugModeEnabled(self: *const Engine) bool {
        return self.config.debug.enabled;
    }
};
