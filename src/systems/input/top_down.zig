const ray = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../../components/main.zig");
const Movement = components.Movement;
const Player = components.Player;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;

fn getDirectionX() MovementDirectionX {
    if (ray.IsKeyDown(ray.KEY_RIGHT) or ray.IsKeyDown(ray.KEY_L)) {
        return .right;
    } else if (ray.IsKeyDown(ray.KEY_LEFT) or ray.IsKeyDown(ray.KEY_H)) {
        return .left;
    } else {
        return .none;
    }
}

fn getDirectionY() MovementDirectionY {
    if (ray.IsKeyDown(ray.KEY_UP) or ray.IsKeyDown(ray.KEY_K)) {
        return .up;
    } else if (ray.IsKeyDown(ray.KEY_DOWN) or ray.IsKeyDown(ray.KEY_J)) {
        return .down;
    } else {
        return .none;
    }
}

pub fn handleInput(engine: *Engine) void {
    const directionX: MovementDirectionX = getDirectionX();
    const directionY: MovementDirectionY = getDirectionY();

    var view = engine.registry.view(.{ Movement, Player }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var movement = view.get(Movement, entity);
        movement.previousDirectionX = movement.directionX;
        movement.directionX = directionX;
        movement.previousDirectionY = movement.directionY;
        movement.directionY = directionY;
    }
}
