const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");

// Systems
const systems = @import("systems/index.zig");

// Components
const components = @import("components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Player = components.Player;
const Movement = components.Movement;

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

    var box1 = reg.create();
    reg.add(box1, Position{ .x = screenWidth / 2 + 100, .y = screenHeight - 35 });
    reg.add(box1, Body{ .width = 50, .height = 50 });
    reg.add(box1, Visual{ .color = ray.GRAY });
    reg.add(box1, Collision{});

    var box2 = reg.create();
    reg.add(box2, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 });
    reg.add(box2, Body{ .width = 50, .height = 50 });
    reg.add(box2, Visual{ .color = ray.GRAY });
    reg.add(box2, Collision{});

    var player = reg.create();
    reg.add(player, Player{});
    reg.add(player, Position{ .x = screenWidth / 2, .y = 350 });
    reg.add(player, Velocity{ .x = 5, .y = 5 });
    reg.add(player, Movement{});
    reg.add(player, Body{ .width = 50, .height = 50 });
    reg.add(player, Visual{ .color = ray.GREEN });
    reg.add(player, Collision{});

    while (!ray.WindowShouldClose()) {
        systems.input.handleInput(&reg);
        systems.movement.accelerate(&reg);
        systems.movement.move(&reg);
        systems.collision.collide(&reg) catch |err| {
            std.debug.print("ERROR (systems.collision.collide): {}\n", .{ err });
        };
        systems.drawing.beginDrawing();
        systems.drawing.draw(&reg);
        systems.drawing.endDrawing();
    }
}
