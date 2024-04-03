const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const Engine = @import("engine/main.zig").Engine;
const components = @import("ecs/components.zig");
const systems = @import("ecs/systems.zig");
const anim = @import("animation/main.zig");

pub fn main() !void {
    const name = "zigray-test";

    std.debug.print("## {s} ##\n", .{name});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer detectMemoryLeaks(gpa.deinit());

    var engine = Engine.init(
        gpa.allocator(),
        .{
            .debug = .{ .enabled = false },
            .display = .{
                .title = name,
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

    const backgroundTexture = try engine.textureStore.load("background", "assets/background.png");
    const playerSpriteSheet = try engine.textureStore.load("player", "assets/character.atlas.png");

    engine.background = .{ .sprite = .{ .texture = backgroundTexture } };

    const playerAnimations: anim.AnimationDefinitions = &[_]anim.AnimationDefinition{
        // Animation 0: Standing
        &[_]anim.AnimationFrame{
            .{
                .sprite = .{
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
                    .texture = playerSpriteSheet,
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
    setupEntities(&engine);
    spawnPlayer(engine.getEcsRegistry(), playerAnimations);

    while (engine.isRunning()) {
        systems.input.handleMovementInput(&engine);

        systems.movement.beginMovement(&engine);
        systems.movement.accelerate(&engine);
        systems.movement.jump(&engine);
        systems.physics.handleGravitation(&engine);
        systems.physics.handleCollision(&engine, 2);
        systems.movement.endMovement(&engine);

        systems.animation.animate(&engine);

        systems.graphics.beginRendering(&engine);
        systems.graphics.render(&engine);
        systems.graphics.endRendering(&engine);

        systems.input.handleInput(&engine);

        systems.cleanup.destroyTaggedEntities(&engine);
    }
}

/// Detect potential memory leaks and print a warning message accordingly.
fn detectMemoryLeaks(leakCheckResult: std.heap.Check) void {
    if (leakCheckResult == .leak) {
        std.debug.print("[WARN] Memory leak(s) detected.\n", .{});
    }
}

fn setupEntities(engine: *Engine) void {
    const Position = components.Position;
    const Body = components.Body;
    const Visual = components.Visual;
    const Collision = components.Collision;

    var reg = engine.getEcsRegistry();

    const displayWidth = engine.config.display.width;
    const displayHeight = engine.config.display.height;

    const solidColor = rl.getColor(0x181e2aff);

    const floor = reg.create();
    reg.add(floor, Position{ .x = displayWidth / 2, .y = displayHeight });
    reg.add(floor, Body{ .width = displayWidth, .height = 0 });
    reg.add(floor, components.Deadly{});
    reg.add(floor, Collision{});
    const ceiling = reg.create();
    reg.add(ceiling, Position{ .x = displayWidth / 2, .y = 5 });
    reg.add(ceiling, Body{ .width = displayWidth, .height = 10 });
    reg.add(ceiling, Visual{ .color = solidColor });
    reg.add(ceiling, Collision{});
    const wallLeft = reg.create();
    reg.add(wallLeft, Position{ .x = 5, .y = displayHeight / 2 });
    reg.add(wallLeft, Body{ .width = 10, .height = displayHeight });
    reg.add(wallLeft, Visual{ .color = solidColor });
    reg.add(wallLeft, Collision{});
    const wallRight = reg.create();
    reg.add(wallRight, Position{ .x = displayWidth - 5, .y = displayHeight / 2 });
    reg.add(wallRight, Body{ .width = 10, .height = displayHeight });
    reg.add(wallRight, Visual{ .color = solidColor });
    reg.add(wallRight, Collision{});

    // Platform 1
    const platform1 = reg.create();
    reg.add(platform1, Position{ .x = 150, .y = displayHeight / 2 - 25 });
    reg.add(platform1, Body{ .width = 300, .height = 50 });
    reg.add(platform1, Visual{ .color = solidColor });
    reg.add(platform1, Collision{});
    // Platform 2
    const platform2 = reg.create();
    reg.add(platform2, Position{ .x = displayWidth - 150, .y = displayHeight / 2 - 25 });
    reg.add(platform2, Body{ .width = 300, .height = 50 });
    reg.add(platform2, Visual{ .color = solidColor });
    reg.add(platform2, Collision{});
    // Platform 3
    const platform3 = reg.create();
    reg.add(platform3, Position{ .x = displayWidth / 2 - 175, .y = displayHeight - 100 });
    reg.add(platform3, Body{ .width = 250, .height = 50 });
    reg.add(platform3, Visual{ .color = solidColor });
    reg.add(platform3, Collision{});
}

/// Spawn the player entity at the starting position.
fn spawnPlayer(reg: *ecs.Registry, playerAnimations: anim.AnimationDefinitions) void {
    const player = reg.create();
    reg.add(player, components.Player{
        .onStateChange = struct {
            pub fn f(
                r: *ecs.Registry,
                e: ecs.Entity,
                _: components.Player.State,
                _: components.Player.State,
            ) void {
                const animation = r.getConst(components.Animation, e);
                spawnPlayer(r, animation.definitions);
            }
        }.f,
    });
    reg.add(player, components.Position{ .x = 50, .y = 50 });
    reg.add(player, components.Velocity{});
    reg.add(player, components.Speed{ .movement = 350, .jump = 900 });
    reg.add(player, components.Gravity{});
    reg.add(player, components.Movement{});
    reg.add(player, components.Body{ .width = 50, .height = 50 });
    reg.add(player, components.Visual{ .color = rl.Color.green });
    reg.add(player, components.Collision{
        .onCollision = struct {
            pub fn f(r: *ecs.Registry, e: ecs.Entity, colliderEntity: ecs.Entity) void {
                // Kill player, if colliding with a deadly entity.
                if (r.has(components.Deadly, colliderEntity) and !r.has(components.Destroy, e)) {
                    r.add(e, components.Destroy{});
                    var playerState = r.get(components.Player, e);
                    const oldState = playerState.state;
                    playerState.state = .dead;
                    if (playerState.onStateChange) |onStateChange| {
                        onStateChange(r, e, playerState.state, oldState);
                    }
                }
            }
        }.f,
    });
    reg.add(player, components.Animation{
        .definition = 0,
        .frame = 0,
        .definitions = playerAnimations,
    });
}
