const std = @import("std");

const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Movement = components.Movement;

pub fn accelerate(reg: *ecs.Registry) void {
    var view = reg.view(.{ Velocity, Movement }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const movement = view.get(Movement, entity);

        if (movement.directionX == .none) {
            velocity.currentX = 0;
            if (velocity.staticCurrentX < velocity.staticX) {
                velocity.staticCurrentX += velocity.staticAccelerationX;
            }
        }
        else if (velocity.currentX < velocity.x) {
            velocity.currentX += velocity.accelerationX;
            velocity.staticCurrentX = 0;
        }

        if (movement.directionY == .none) {
            velocity.currentY = 0;
            if (velocity.staticCurrentY < velocity.staticY) {
                velocity.staticCurrentY += velocity.staticAccelerationY;
            }
        }
        else if (velocity.currentY < velocity.y) {
            velocity.currentY += velocity.accelerationY;
            velocity.staticCurrentY = 0;
        }
    }
}

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

        position.x += velocity.currentX * velocityFactorX + velocity.staticCurrentX;
        position.y += velocity.currentY * velocityFactorY + velocity.staticCurrentY;
    }
}
