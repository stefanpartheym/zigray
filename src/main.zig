const std = @import("std");
const ray = @import("raylib");

const Engine = @import("engine/main.zig").Engine;
const systems = @import("systems/main.zig");

pub fn main() void {
    const name = "zigray-test";
    const version = "0.0.1";

    std.debug.print("## {s} (v{s}) ##\n", .{ name, version });

    var engine = Engine.init(
        std.heap.page_allocator,
        .{
            .debug = .{ .enable = false },
            .display = .{
                .title = name ++ " (v" ++ version ++ ")",
                .width = 800,
                .height = 600,
                .targetFps = 60,
                .useHighDpi = true,
            },
            .physics = .{
                .gravity = .{
                    .forceX = 0,
                    .forceY = 30,
                },
            },
        },
    );
    defer engine.deinit();

    setupEntities(&engine);

    engine.start();
    defer engine.stop();

    while (engine.isRunning()) {
        systems.input.sideScroller.handleInput(&engine);

        systems.movement.beginMovement(&engine);
        systems.movement.accelerate(&engine);
        systems.movement.jump(&engine);
        systems.physics.handleGravitation(&engine);
        systems.physics.handleCollision(&engine, 2);
        systems.movement.endMovement(&engine);

        systems.rendering.beginRendering();
        systems.rendering.render(&engine);
        systems.rendering.endRendering();

        systems.input.common.handleInput(&engine);
    }
}

fn setupEntities(engine: *Engine) void {
    const components = @import("components/main.zig");
    const Position = components.Position;
    const Velocity = components.Velocity;
    const Speed = components.Speed;
    const Gravity = components.Gravity;
    const Body = components.Body;
    const Visual = components.Visual;
    const Collision = components.Collision;
    const Player = components.Player;
    const Movement = components.Movement;

    var reg = &(engine.registry);

    const screenWidth = engine.state.display.width;
    const screenHeight = engine.state.display.height;

    const floor = reg.create();
    reg.add(floor, Position{ .x = screenWidth / 2, .y = screenHeight - 5 });
    reg.add(floor, Body{ .width = screenWidth, .height = 10 });
    reg.add(floor, Visual{ .color = ray.BROWN });
    reg.add(floor, Collision{});
    const ceiling = reg.create();
    reg.add(ceiling, Position{ .x = screenWidth / 2, .y = 5 });
    reg.add(ceiling, Body{ .width = screenWidth, .height = 10 });
    reg.add(ceiling, Visual{ .color = ray.BROWN });
    reg.add(ceiling, Collision{});
    const wallLeft = reg.create();
    reg.add(wallLeft, Position{ .x = 5, .y = screenHeight / 2 });
    reg.add(wallLeft, Body{ .width = 10, .height = screenHeight });
    reg.add(wallLeft, Visual{ .color = ray.BROWN });
    reg.add(wallLeft, Collision{});
    const wallRight = reg.create();
    reg.add(wallRight, Position{ .x = screenWidth - 5, .y = screenHeight / 2 });
    reg.add(wallRight, Body{ .width = 10, .height = screenHeight });
    reg.add(wallRight, Visual{ .color = ray.BROWN });
    reg.add(wallRight, Collision{});

    // Box 1 (on ground)
    const box1 = reg.create();
    reg.add(box1, Position{ .x = screenWidth / 2 + 100, .y = screenHeight - 35 });
    reg.add(box1, Velocity{});
    reg.add(box1, Gravity{});
    reg.add(box1, Body{ .width = 50, .height = 50 });
    reg.add(box1, Visual{ .color = ray.DARKGRAY });
    reg.add(box1, Collision{});

    // Box 2 (in the air)
    const box2 = reg.create();
    reg.add(box2, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 });
    reg.add(box2, Velocity{});
    reg.add(box2, Gravity{});
    reg.add(box2, Body{ .width = 50, .height = 50 });
    reg.add(box2, Visual{ .color = ray.GRAY });
    reg.add(box2, Collision{});

    // Box 3 (in the air)
    const box3 = reg.create();
    reg.add(box3, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 - 100 });
    reg.add(box3, Velocity{});
    reg.add(box3, Gravity{});
    reg.add(box3, Body{ .width = 50, .height = 50 });
    reg.add(box3, Visual{ .color = ray.LIGHTGRAY });
    reg.add(box3, Collision{});

    // Box 4 (in the air)
    const box4 = reg.create();
    reg.add(box4, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 - 200 });
    reg.add(box4, Velocity{});
    reg.add(box4, Gravity{});
    reg.add(box4, Body{ .width = 50, .height = 50 });
    reg.add(box4, Visual{ .color = ray.WHITE });
    reg.add(box4, Collision{});

    const player = reg.create();
    reg.add(player, Player{});
    reg.add(player, Position{ .x = screenWidth / 2, .y = 350 });
    reg.add(player, Velocity{});
    reg.add(player, Speed{ .x = 350, .y = 1000 });
    reg.add(player, Gravity{});
    reg.add(player, Movement{});
    reg.add(player, Body{ .width = 50, .height = 50 });
    reg.add(player, Visual{ .color = ray.GREEN });
    reg.add(player, Collision{});
}
