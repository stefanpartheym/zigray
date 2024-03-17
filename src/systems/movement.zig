const std = @import("std");
const Engine = @import("../engine/index.zig").Engine;
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Speed = components.Speed;
const Movement = components.Movement;
const Collision = components.Collision;
const Gravity = components.Gravity;

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
    var view = engine.registry.view(.{ Position, Velocity, Collision }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);

        // TODO:
        // The following code is assumed to be the default collision response
        // without any sliding, pushing or bouncing the entity.
        // As we are already responding to the collision in the collision
        // system, it would be incorrect to do it twice and could lead to
        // unpleasent behavior, like extremely slow sliding of the entity.
        // Instead, the movement should be simply done like the following:
        // ```zig
        // position.x += velocity.x;
        // position.y += velocity.y;
        // ```

        const collision = view.getConst(Collision, entity);
        position.x += velocity.x * collision.aabbSweepResult.time;
        position.y += velocity.y * collision.aabbSweepResult.time;
    }
}
