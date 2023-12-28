const std = @import("std");

const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Movement = components.Movement;
const Gravity = components.Gravity;

/// Acceleration system
pub fn accelerate(reg: *ecs.Registry) void {
    var view = reg.view(.{ Velocity, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const movement = view.get(Movement, entity);

        if (movement.directionX != movement.previousDirectionX) {
            velocity.currentX = 0;
        }
        if (movement.directionX != .none) {
            velocity.accelerateX();
        }

        if (movement.directionY != movement.previousDirectionY) {
            velocity.currentY = 0;
        }
        if (movement.directionY != .none) {
            velocity.accelerateY();
        }
    }
}

/// Movement system (begin)
pub fn beginMovement(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        position.tempX = position.x;
        position.tempY = position.y;
        position.offsetX = 0;
        position.offsetY = 0;
    }
}

/// Movement system (end)
pub fn endMovement(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        position.x = position.tempX;
        position.y = position.tempY;
    }
}

/// Movement system (apply position offset)
pub fn applyPositionOffset(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        position.tempX += position.offsetX;
        position.tempY += position.offsetY;
    }
}

/// Movement system
pub fn move(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity, Movement }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);
        const movement = view.getConst(Movement, entity);

        const velocityFactorX: f32 =
            if (movement.directionX == .left) -1 else if (movement.directionX == .right) 1 else 0;
        const velocityFactorY: f32 =
            if (movement.directionY == .up) -1 else if (movement.directionY == .down) 1 else 0;

        position.offsetX += velocity.currentX * velocityFactorX;
        position.offsetY += velocity.currentY * velocityFactorY;
    }
}
