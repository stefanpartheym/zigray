const std = @import("std");
const rl = @import("raylib");
const Engine = @import("engine/main.zig").Engine;
const components = @import("ecs/components.zig");
const systems = @import("ecs/systems.zig");
const anim = @import("animation/main.zig");

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
                    .forceY = 25,
                },
            },
        },
    );
    defer engine.deinit();

    engine.start();
    defer engine.stop();

    const playerSpriteSheet = rl.loadTexture("assets/character.atlas.png");
    defer rl.unloadTexture(playerSpriteSheet);
    const playerAnimations: anim.AnimationDefinitions = &[_]anim.AnimationDefinition{
        // Animation 0: Standing
        &[_]anim.AnimationFrame{
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 0,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
        },
        // Animation 1: Moving
        &[_]anim.AnimationFrame{
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 24,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 48,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 72,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 96,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 120,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 144,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
            .{
                .sprite = .{
                    .texture = &playerSpriteSheet,
                    .source = .{
                        .x = 168,
                        .y = 24,
                        .width = 24,
                        .height = 24,
                    },
                },
            },
        },
    };
    setupEntities(&engine, playerAnimations);

    while (engine.isRunning()) {
        systems.input.handleMovementInput(&engine);

        systems.movement.beginMovement(&engine);
        systems.movement.accelerate(&engine);
        systems.movement.jump(&engine);
        systems.physics.handleGravitation(&engine);
        systems.physics.handleCollision(&engine, 2);
        systems.movement.endMovement(&engine);

        systems.animation.animate(&engine);

        systems.graphics.beginRendering();
        systems.graphics.render(&engine);
        systems.graphics.endRendering(&engine);

        systems.input.handleInput(&engine);

        systems.cleanup.destroyTaggedEntities(&engine);
    }
}

fn setupEntities(engine: *Engine, playerAnimations: anim.AnimationDefinitions) void {
    const ecs = @import("ecs");
    const Position = components.Position;
    const Velocity = components.Velocity;
    const Speed = components.Speed;
    const Gravity = components.Gravity;
    const Body = components.Body;
    const Visual = components.Visual;
    const Collision = components.Collision;
    const Player = components.Player;
    const Movement = components.Movement;
    const Animation = components.Animation;

    var reg = engine.getRegistry();

    const screenWidth = engine.state.display.width;
    const screenHeight = engine.state.display.height;

    const floor = reg.create();
    reg.add(floor, Position{ .x = screenWidth / 2, .y = screenHeight - 5 });
    reg.add(floor, Body{ .width = screenWidth, .height = 10 });
    reg.add(floor, Visual{ .color = rl.Color.brown });
    reg.add(floor, Collision{});
    const ceiling = reg.create();
    reg.add(ceiling, Position{ .x = screenWidth / 2, .y = 5 });
    reg.add(ceiling, Body{ .width = screenWidth, .height = 10 });
    reg.add(ceiling, Visual{ .color = rl.Color.brown });
    reg.add(ceiling, Collision{});
    const wallLeft = reg.create();
    reg.add(wallLeft, Position{ .x = 5, .y = screenHeight / 2 });
    reg.add(wallLeft, Body{ .width = 10, .height = screenHeight });
    reg.add(wallLeft, Visual{ .color = rl.Color.brown });
    reg.add(wallLeft, Collision{});
    const wallRight = reg.create();
    reg.add(wallRight, Position{ .x = screenWidth - 5, .y = screenHeight / 2 });
    reg.add(wallRight, Body{ .width = 10, .height = screenHeight });
    reg.add(wallRight, Visual{ .color = rl.Color.brown });
    reg.add(wallRight, Collision{});

    // Platform 1
    const platform1 = reg.create();
    reg.add(platform1, Position{ .x = 150, .y = screenHeight / 2 - 25 });
    reg.add(platform1, Body{ .width = 300, .height = 50 });
    reg.add(platform1, Visual{ .color = rl.Color.dark_gray });
    reg.add(platform1, Collision{});

    // Platform 2
    const platform2 = reg.create();
    reg.add(platform2, Position{ .x = screenWidth - 150, .y = screenHeight / 3 - 25 });
    reg.add(platform2, Body{ .width = 300, .height = 50 });
    reg.add(platform2, Visual{ .color = rl.Color.dark_gray });
    reg.add(platform2, Collision{});

    const OnCollisionFn = struct {
        pub fn f(r: *ecs.Registry, e: ecs.Entity, colliderEntity: ecs.Entity) void {
            // Destroy entity only, if colliding with a projectile.
            if (r.has(components.Projectile, colliderEntity) and !r.has(components.Destroy, e)) {
                r.add(e, components.Destroy{});
            }
        }
    };

    // Box 1 (on ground)
    const box1 = reg.create();
    reg.add(box1, Position{ .x = screenWidth / 2 + 100, .y = screenHeight - 35 });
    reg.add(box1, Velocity{});
    reg.add(box1, Gravity{});
    reg.add(box1, Body{ .width = 50, .height = 50 });
    reg.add(box1, Visual{ .color = rl.Color.dark_gray });
    reg.add(box1, Collision{ .onCollision = OnCollisionFn.f });

    // Box 2 (in the air)
    const box2 = reg.create();
    reg.add(box2, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 + 75 });
    reg.add(box2, Velocity{});
    reg.add(box2, Gravity{});
    reg.add(box2, Body{ .width = 50, .height = 50 });
    reg.add(box2, Visual{ .color = rl.Color.gray });
    reg.add(box2, Collision{ .onCollision = OnCollisionFn.f });

    // Box 3 (in the air)
    const box3 = reg.create();
    reg.add(box3, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 });
    reg.add(box3, Velocity{});
    reg.add(box3, Gravity{});
    reg.add(box3, Body{ .width = 50, .height = 50 });
    reg.add(box3, Visual{ .color = rl.Color.light_gray });
    reg.add(box3, Collision{ .onCollision = OnCollisionFn.f });

    // Box 4 (in the air)
    const box4 = reg.create();
    reg.add(box4, Position{ .x = screenWidth / 2 + 100, .y = screenHeight / 2 - 75 });
    reg.add(box4, Velocity{});
    reg.add(box4, Gravity{});
    reg.add(box4, Body{ .width = 50, .height = 50 });
    reg.add(box4, Visual{ .color = rl.Color.white });
    reg.add(box4, Collision{ .onCollision = OnCollisionFn.f });

    const player = reg.create();
    reg.add(player, Player{});
    reg.add(player, Position{ .x = screenWidth / 2, .y = 350 });
    reg.add(player, Velocity{});
    reg.add(player, Speed{ .movement = 350, .jump = 900 });
    reg.add(player, Gravity{});
    reg.add(player, Movement{});
    reg.add(player, Body{ .width = 50, .height = 50 });
    reg.add(player, Visual{ .color = rl.Color.green });
    reg.add(player, Collision{});
    reg.add(player, Animation{
        .definition = 0,
        .frame = 0,
        .definitions = playerAnimations,
    });
}
