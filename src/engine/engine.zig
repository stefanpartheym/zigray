const std = @import("std");
const ecs = @import("ecs");
const EngineState = @import("./state.zig").EngineState;

pub const Engine = struct {
    allocator: std.mem.Allocator,
    registry: ecs.Registry,
    state: EngineState,

    pub fn init(allocator: std.mem.Allocator, debugEnabled: bool) Engine {
        return Engine{
            .allocator = allocator,
            .registry = ecs.Registry.init(allocator),
            .state = EngineState{
                .debug = .{
                    .enabled = debugEnabled,
                },
            },
        };
    }

    pub fn deinit(self: *Engine) void {
        self.registry.deinit();
    }

    pub fn toggleDebugMode(self: *Engine) void {
        self.state.debug.enabled = !self.state.debug.enabled;
    }

    pub fn isDebugModeEnabled(self: *const Engine) bool {
        return self.state.debug.enabled;
    }
};
