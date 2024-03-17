const std = @import("std");
const Engine = @import("../engine/index.zig").Engine;
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Speed = components.Speed;
const Movement = components.Movement;

/// Acceleration system
pub fn accelerate(engine: *Engine) void {
    var view = engine.registry.view(.{ Velocity, Speed, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const speed = view.getConst(Speed, entity);
        const movement = view.getConst(Movement, entity);

        if (movement.directionX == .left) {
            velocity.x += -speed.x;
        } else if (movement.directionX == .right) {
            velocity.x += speed.x;
        }

        if (movement.directionY == .up) {
            velocity.y += -speed.y;
        } else if (movement.directionY == .down) {
            velocity.y += speed.y;
        }
    }
}

/// Movement system (begin)
pub fn beginMovement(engine: *Engine) void {
    var view = engine.registry.view(.{ Position, Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        velocity.x = 0;
        velocity.y = 0;
    }
}

/// Movement system (end)
pub fn endMovement(engine: *Engine) void {
    var view = engine.registry.view(.{ Position, Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);
        position.x += velocity.x;
        position.y += velocity.y;
    }
}
