const ray = @import("raylib");
const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Movement = components.Movement;
const Player = components.Player;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;

pub fn handleInput(reg: *ecs.Registry) void {
    const directionX: MovementDirectionX =
        if (ray.IsKeyDown(ray.KEY_RIGHT))
            .right
        else if (ray.IsKeyDown(ray.KEY_LEFT))
            .left
        else
            .none;

    const directionY: MovementDirectionY =
        if (ray.IsKeyDown(ray.KEY_UP))
            .up
        else if (ray.IsKeyDown(ray.KEY_DOWN))
            .down
        else
            .none;

    var view = reg.view(.{ Movement, Player }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var movement = view.get(Movement, entity);
        movement.directionX = directionX;
        movement.directionY = directionY;
    }
}
