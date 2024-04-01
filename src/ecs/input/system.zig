const ecs = @import("ecs");
const rl = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../components.zig");
const Movement = components.Movement;
const Player = components.Player;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;

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
        engine.changeState(.STOPPED);
    }

    if (rl.isKeyPressed(rl.KeyboardKey.key_f2)) {
        spawnTestBox(engine);
    }
}

/// Handles movement related input.
pub fn handleMovementInput(engine: *Engine) void {
    const reg = engine.getEcsRegistry();

    const directionX: MovementDirectionX = getDirectionX();
    const jump = rl.isKeyPressed(rl.KeyboardKey.key_space);
    const shoot = rl.isKeyPressed(rl.KeyboardKey.key_f);

    var view = reg.view(.{ Movement, Player }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var movement = view.get(Movement, entity);
        movement.directionX = directionX;
        movement.directionY = if (jump) .up else .none;

        if (directionX != .none) {
            const entityBody = reg.tryGet(components.Body, entity);
            if (entityBody) |body| {
                body.facingDirectionX = directionX;
            }
        }

        if (movement.directionY != movement.previousDirectionY) {
            movement.previousDirectionY = movement.directionY;
        }
        if (movement.directionX != movement.previousDirectionX) {
            const entityAnimation = reg.tryGet(components.Animation, entity);
            if (entityAnimation) |animation| {
                switch (directionX) {
                    .left => {
                        animation.definition = 1;
                        animation.frame = 0;
                        animation.flipFrame = true;
                    },
                    .right => {
                        animation.definition = 1;
                        animation.frame = 0;
                        animation.flipFrame = false;
                    },
                    .none => {
                        animation.definition = 0;
                        animation.frame = 0;
                        switch (movement.previousDirectionX) {
                            .left => animation.flipFrame = true,
                            .right, .none => animation.flipFrame = false,
                        }
                    },
                }
            }
            movement.previousDirectionX = movement.directionX;
        }

        if (shoot and
            reg.has(components.Movement, entity) and
            reg.has(components.Body, entity) and
            reg.has(components.Position, entity))
        {
            shootProjectile(engine, entity, .{
                .position = reg.getConst(components.Position, entity),
                .movement = reg.getConst(components.Movement, entity),
                .body = reg.getConst(components.Body, entity),
            });
        }
    }
}

//------------------------------------------------------------------------------

fn spawnTestBox(engine: *Engine) void {
    var reg = engine.getEcsRegistry();
    const displayWidth = engine.config.display.width;

    const OnCollisionFn = struct {
        pub fn f(r: *ecs.Registry, e: ecs.Entity, colliderEntity: ecs.Entity) void {
            // Destroy entity only, if colliding with a projectile.
            if (r.has(components.Projectile, colliderEntity) and !r.has(components.Destroy, e)) {
                r.add(e, components.Destroy{});
            }
        }
    };

    const solidColor = rl.getColor(0x181e2aff);
    const entity = reg.create();
    reg.add(entity, components.Position{ .x = displayWidth / 2, .y = 25 });
    reg.add(entity, components.Velocity{});
    reg.add(entity, components.Gravity{});
    reg.add(entity, components.Body{ .width = 50, .height = 50 });
    reg.add(entity, components.Visual{ .color = solidColor });
    reg.add(entity, components.Collision{ .onCollision = OnCollisionFn.f });
}

fn getDirectionX() MovementDirectionX {
    if (rl.isKeyDown(rl.KeyboardKey.key_right) or rl.isKeyDown(rl.KeyboardKey.key_l)) {
        return .right;
    } else if (rl.isKeyDown(rl.KeyboardKey.key_left) or rl.isKeyDown(rl.KeyboardKey.key_h)) {
        return .left;
    } else {
        return .none;
    }
}

/// Relevant state of the shooting entity.
const OriginState = struct {
    position: components.Position,
    body: components.Body,
    movement: Movement,
};

fn shootProjectile(engine: *Engine, entity: ecs.Entity, originState: OriginState) void {
    const body: components.Body = .{ .width = 10, .height = 10 };
    const movement: components.Movement = .{
        .directionX = originState.body.facingDirectionX,
    };
    var positionOffset: f32 = (originState.body.width / 2) - (body.width / 2);
    if (originState.body.facingDirectionX == .left) {
        positionOffset *= -1;
    }
    const position: components.Position = .{
        .x = originState.position.x + positionOffset,
        .y = originState.position.y,
    };

    var reg = engine.getEcsRegistry();
    const projectileEntity = reg.create();
    reg.add(projectileEntity, body);
    reg.add(projectileEntity, movement);
    reg.add(projectileEntity, position);
    reg.add(projectileEntity, components.Speed{ .movement = 800 });
    reg.add(projectileEntity, components.Velocity{});
    reg.add(projectileEntity, components.Gravity{ .forceY = 1 });
    reg.add(projectileEntity, components.Visual{ .color = rl.Color.red });
    reg.add(projectileEntity, components.Projectile{ .shotBy = entity });
    reg.add(projectileEntity, components.Collision{
        .onCollision = struct {
            pub fn f(r: *ecs.Registry, e: ecs.Entity, collider: ecs.Entity) void {
                const projectile = r.getConst(components.Projectile, e);
                // Destroy the projectile if it hits an entity, that isn't a
                // projectile itself and isn't the origin of the shot.
                if (!(r.has(components.Projectile, collider) or
                    r.has(components.Destroy, e) or
                    projectile.shotBy == collider))
                {
                    r.add(e, components.Destroy{});
                }
            }
        }.f,
    });
}
