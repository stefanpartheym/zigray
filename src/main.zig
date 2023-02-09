const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");

// Modules
const modules = @import("modules/index.zig");

// Components
const components = @import("components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Player = components.Player;

pub fn main() void {
    const name = "zigray-test";
    const version = "0.0.1";
    const screenWidth = 800;
    const screenHeight = 600;
    const fps = 60;

    std.debug.print("## {s} (v{s}) ##\n", .{ name, version });

    ray.SetConfigFlags(ray.FLAG_WINDOW_HIGHDPI);
    ray.SetTraceLogLevel(ray.LOG_WARNING);
    ray.InitWindow(screenWidth, screenHeight, name ++ " (v" ++ version ++ ")");
    defer ray.CloseWindow();

    ray.SetTargetFPS(fps);

    var reg = ecs.Registry.init(std.heap.page_allocator);

    var ground = reg.create();
    reg.add(ground, Position{ .x = screenWidth / 2, .y = screenHeight - 5 });
    reg.add(ground, Body{ .width = screenWidth, .height = 10 });
    reg.add(ground, Visual{ .color = ray.BROWN });
    reg.add(ground, Collision{});

    var player = reg.create();
    reg.add(player, Player{});
    reg.add(player, Position{ .x = 400, .y = 450 });
    reg.add(player, Velocity{ .staticY = 4 });
    reg.add(player, Body{ .width = 50, .height = 50 });
    reg.add(player, Visual{ .color = ray.GREEN });
    reg.add(player, Collision{});

    while (!ray.WindowShouldClose()) {
        modules.input.handleInput(&reg);
        modules.movement.move(&reg);
        modules.collision.collide(&reg);
        modules.drawing.beginDrawing();
        modules.drawing.draw(&reg);
        modules.drawing.endDrawing();
    }
}
