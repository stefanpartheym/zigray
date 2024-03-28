const rl = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../../components/main.zig");
const Movement = components.Movement;
const Player = components.Player;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;

fn getDirectionX() MovementDirectionX {
    if (rl.isKeyDown(rl.KeyboardKey.key_right) or rl.isKeyDown(rl.KeyboardKey.key_l)) {
        return .right;
    } else if (rl.isKeyDown(rl.KeyboardKey.key_left) or rl.isKeyDown(rl.KeyboardKey.key_h)) {
        return .left;
    } else {
        return .none;
    }
}

fn getDirectionY() MovementDirectionY {
    if (rl.isKeyDown(rl.KeyboardKey.key_up) or rl.isKeyDown(rl.KeyboardKey.key_k)) {
        return .up;
    } else if (rl.isKeyDown(rl.KeyboardKey.key_down) or rl.isKeyDown(rl.KeyboardKey.key_j)) {
        return .down;
    } else {
        return .none;
    }
}

pub fn handleInput(engine: *Engine) void {
    const directionX: MovementDirectionX = getDirectionX();
    const directionY: MovementDirectionY = getDirectionY();

    var view = engine.getRegistry().view(.{ Movement, Player }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var movement = view.get(Movement, entity);
        movement.previousDirectionX = movement.directionX;
        movement.directionX = directionX;
        movement.previousDirectionY = movement.directionY;
        movement.directionY = directionY;
    }
}
