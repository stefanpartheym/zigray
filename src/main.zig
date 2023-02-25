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

    initialize(name, version, screenWidth, screenHeight, fps);
    defer finalize();

    var reg = ecs.Registry.init(std.heap.page_allocator);

    setupEntities(&reg, screenWidth, screenHeight);

    while (!ray.WindowShouldClose()) {
        systems.input.handleInput(&reg);
        systems.movement.accelerate(&reg);
        systems.movement.move(&reg);
        systems.collision.collide(&reg) catch |err| {
            std.debug.print("ERROR (systems.collision.collide): {}\n", .{err});
        };
        systems.drawing.beginDrawing();
        systems.drawing.draw(&reg);
        systems.drawing.endDrawing();
    }
}

fn initialize(
    comptime name: []const u8,
    comptime version: []const u8,
    screenWidth: f32,
    screenHeight: f32,
    fps: u8,
) void {
    std.debug.print("## {s} (v{s}) ##\n", .{ name, version });

    ray.SetConfigFlags(ray.FLAG_WINDOW_HIGHDPI);
    ray.SetTraceLogLevel(ray.LOG_WARNING);
    ray.SetTargetFPS(fps);
    ray.InitWindow(@floatToInt(i32, screenWidth), @floatToInt(i32, screenHeight), name ++ " (v" ++ version ++ ")");
}

fn finalize() void {
    ray.CloseWindow();
}

fn setupEntities(reg: *ecs.Registry, screenWidth: f32, screenHeight: f32) void {
    var floor = reg.create();
    reg.add(floor, Position{ .x = screenWidth / 2, .y = screenHeight - 5 });
    reg.add(floor, Body{ .width = screenWidth, .height = 10 });
    reg.add(floor, Visual{ .color = ray.BROWN });
    reg.add(floor, Collision{});
    var ceiling = reg.create();
    reg.add(ceiling, Position{ .x = screenWidth / 2, .y = 5 });
    reg.add(ceiling, Body{ .width = screenWidth, .height = 10 });
    reg.add(ceiling, Visual{ .color = ray.BROWN });
    reg.add(ceiling, Collision{});
    var wallLeft = reg.create();
    reg.add(wallLeft, Position{ .x = 5, .y = screenHeight / 2 });
    reg.add(wallLeft, Body{ .width = 10, .height = screenHeight });
    reg.add(wallLeft, Visual{ .color = ray.BROWN });
    reg.add(wallLeft, Collision{});
    var wallRight = reg.create();
    reg.add(wallRight, Position{ .x = screenWidth - 5, .y = screenHeight / 2 });
    reg.add(wallRight, Body{ .width = 10, .height = screenHeight });
    reg.add(wallRight, Visual{ .color = ray.BROWN });
    reg.add(wallRight, Collision{});

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
    reg.add(player, Velocity{ .x = 8, .y = 8 });
    reg.add(player, Movement{});
    reg.add(player, Body{ .width = 50, .height = 50 });
    reg.add(player, Visual{ .color = ray.GREEN });
    reg.add(player, Collision{});
}
