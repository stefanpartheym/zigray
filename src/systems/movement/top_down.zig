const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../../components/main.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Speed = components.Speed;
const Movement = components.Movement;
const Collision = components.Collision;

/// Acceleration system
/// Accelerates entities based on their speed and the direction they're moving.
pub fn accelerate(engine: *Engine) void {
    var view = engine.getRegistry().view(.{ Velocity, Speed, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const movement = view.getConst(Movement, entity);
        const speed = view.getConst(Speed, entity);
        const scaledSpeed = speed.movement * engine.getDeltaTime();

        if (movement.directionY == .up) {
            velocity.y += -scaledSpeed;
        } else if (movement.directionY == .down) {
            velocity.y += scaledSpeed;
        }

        if (movement.directionX == .left) {
            velocity.x += -scaledSpeed;
        } else if (movement.directionX == .right) {
            velocity.x += scaledSpeed;
        }
    }
}

/// Movement system (begin)
/// Prepares every movable entity by resetting their velocity on the X-axis.
/// This must happen before all other movement related systems, like
/// acceleration or collision handling.
pub fn beginMovement(engine: *Engine) void {
    var view = engine.getRegistry().view(.{ Position, Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        velocity.x = 0;
        velocity.y = 0;
    }
}

/// Movement system (end)
/// Applies the final velocity of the entity to its position.
/// This must happen after all other movement related systems, like acceleration
/// or collision handling.
pub fn endMovement(engine: *Engine) void {
    var view = engine.getRegistry().view(.{ Position, Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);
        position.x += velocity.x;
        position.y += velocity.y;
    }
}
