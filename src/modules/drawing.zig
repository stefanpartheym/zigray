const ray = @import("raylib").raylib;
const ecs = @import("ecs");
const Position = @import("components").Position;
const Body = @import("components").Body;
const Visual = @import("components").Visual;

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
    var iter = view.iterator();
    while (iter.next()) |entity| {
        const position = view.getConst(Position, entity);
        const body = view.getConst(Body, entity);
        const visual = view.getConst(Visual, entity);
        ray.DrawRectangle(
            @floatToInt(c_int, position.getAbsoluteX(body.width)),
            @floatToInt(c_int, position.getAbsoluteY(body.height)),
            @floatToInt(c_int, body.width),
            @floatToInt(c_int, body.height),
            visual.color
        );
    }
}
