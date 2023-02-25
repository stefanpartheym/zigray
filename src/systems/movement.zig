const std = @import("std");

const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Movement = components.Movement;

/// Acceleration system
/// TODO:
///   The system needs to check whether the direction has changed and reset the
///   "current" velocity back to `0` accordingly, to trigger reacceleration.
pub fn accelerate(reg: *ecs.Registry) void {
    var view = reg.view(.{ Velocity, Movement }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const movement = view.get(Movement, entity);

        if (movement.directionX == .none) {
            velocity.currentX = 0;
        }
        else if (velocity.currentX < velocity.x) {
            velocity.currentX += velocity.accelerationX;
        }

        if (movement.directionY == .none) {
            velocity.currentY = 0;
        }
        else if (velocity.currentY < velocity.y) {
            velocity.currentY += velocity.accelerationY;
        }
    }
}

/// Movement system
pub fn move(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity, Movement }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);
        const movement = view.getConst(Movement, entity);

        const velocityFactorX: f32 =
            if (movement.directionX == .left) -1
            else if (movement.directionX == .right) 1
            else 0;
        const velocityFactorY: f32 =
            if (movement.directionY == .up) -1
            else if (movement.directionY == .down) 1
            else 0;

        position.x += velocity.currentX * velocityFactorX;
        position.y += velocity.currentY * velocityFactorY;
    }
}
