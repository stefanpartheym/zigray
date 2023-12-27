const ray = @import("raylib");
const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Body = components.Body;
const Visual = components.Visual;

pub fn beginDrawing() void {
    ray.BeginDrawing();
    ray.ClearBackground(ray.BLACK);
}

pub fn endDrawing() void {
    ray.DrawFPS(10, 10);
    ray.EndDrawing();
}

pub fn draw(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Body, Visual }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position = view.getConst(Position, entity);
        const body = view.getConst(Body, entity);
        const visual = view.getConst(Visual, entity);
        ray.DrawRectangle(
            @intFromFloat(position.getAbsoluteX(body.width)),
            @intFromFloat(position.getAbsoluteY(body.height)),
            @intFromFloat(body.width),
            @intFromFloat(body.height),
            visual.color,
        );
    }
}
