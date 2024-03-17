const std = @import("std");
const Engine = @import("../engine/index.zig").Engine;
const components = @import("../components/index.zig");
const Velocity = components.Velocity;
const Gravity = components.Gravity;

/// Gravitation system
pub fn gravitate(engine: *Engine) void {
    var view = engine.registry.view(.{ Velocity, Gravity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const gravity = view.getConst(Gravity, entity);
        velocity.x += gravity.forceX;
        velocity.y += gravity.forceY;
    }
}
