const ray = @import("raylib").raylib;
const ecs = @import("ecs");
const Velocity = @import("../components/components.zig").Velocity;
const Player = @import("../components/components.zig").Player;

pub fn handleInput(reg: *ecs.Registry) void {
    const factorX: f32 = 5;
    const factorY: f32 = 5;
    const velocityY: f32 = if (ray.IsKeyDown(ray.KEY_UP)) -3.5 else 0;
    const velocityX: f32 =
        if (ray.IsKeyDown(ray.KEY_LEFT)) @as(f32, -1)
        else if (ray.IsKeyDown(ray.KEY_RIGHT)) @as(f32, 1)
        else @as(f32, 0);

    var view = reg.view(.{ Velocity, Player }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        velocity.x = velocityX * factorX;
        velocity.y = velocityY * factorY;
    }
}
