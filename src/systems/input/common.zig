const rl = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;

/// Common input handler system.
/// Handles events like closing the window, or toggling debug mode.
pub fn handleInput(engine: *Engine) void {
    // Toggle debug mode, if relevant.
    if (rl.isKeyPressed(rl.KeyboardKey.key_f1)) {
        engine.toggleDebugMode();
    }

    // Update the engine's status on certain inputs.
    // For instance, if [Q] is pressed or if the user closes the window, the engine
    // will be stopped.
    if (rl.windowShouldClose() or rl.isKeyPressed(rl.KeyboardKey.key_q)) {
        engine.changeStatus(.STOPPED);
    }

    if (rl.isKeyPressed(rl.KeyboardKey.key_f2)) {
        spawnTestBox(engine);
    }
}

//------------------------------------------------------------------------------

fn spawnTestBox(engine: *Engine) void {
    const ecs = @import("ecs");
    const components = @import("../../components/main.zig");
    var reg = engine.getRegistry();
    const displayWidth = engine.state.display.width;

    const OnCollisionFn = struct {
        pub fn f(r: *ecs.Registry, e: ecs.Entity, colliderEntity: ecs.Entity) void {
            // Destroy entity only, if colliding with a projectile.
            if (r.has(components.Projectile, colliderEntity) and !r.has(components.Destroy, e)) {
                r.add(e, components.Destroy{});
            }
        }
    };

    const entity = reg.create();
    reg.add(entity, components.Position{ .x = displayWidth / 2, .y = 25 });
    reg.add(entity, components.Velocity{});
    reg.add(entity, components.Gravity{});
    reg.add(entity, components.Body{ .width = 50, .height = 50 });
    reg.add(entity, components.Visual{ .color = rl.Color.gray });
    reg.add(entity, components.Collision{ .onCollision = OnCollisionFn.f });
}
