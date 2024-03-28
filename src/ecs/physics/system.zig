const Engine = @import("../../engine/engine.zig").Engine;
const aabb = @import("../../physics/aabb.zig");
const components = @import("../components.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Gravity = components.Gravity;
const Body = components.Body;
const Collision = components.Collision;

/// Gravitation system
pub fn handleGravitation(engine: *Engine) void {
    const engineGravity = engine.state.physics.gravity;
    var reg = engine.getRegistry();
    var view = reg.view(.{ Velocity, Gravity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velocity = view.get(Velocity, entity);
        const gravity = view.getConst(Gravity, entity);
        const gravityX = if (gravity.forceX) |forceX| forceX else engineGravity.forceX;
        const gravityY = if (gravity.forceY) |forceY| forceY else engineGravity.forceY;
        velocity.x += gravityX * engine.getDeltaTime();
        velocity.y += gravityY * engine.getDeltaTime();
    }
}

/// Collision detection and response system
pub fn handleCollision(engine: *Engine, iterations: usize) void {
    var reg = engine.getRegistry();
    var view = reg.view(.{ Position, Velocity, Body, Collision }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var entityCollision = view.get(Collision, entity);
        // Reset collision flags.
        entityCollision.collided = false;
        entityCollision.grounded = false;
    }

    for (0..iterations) |_| {
        handleCollisionOnce(engine);
    }
}

/// Detect and handle collisions.
/// A collision response could potentially lead to new collisions. Thus, it is
/// recommended to invoke this function multiple times per frame.
/// Use `handleCollision` and pass the number of iterations for this purpose.
pub fn handleCollisionOnce(engine: *Engine) void {
    var reg = engine.getRegistry();
    var view = reg.view(.{ Position, Velocity, Body, Collision }, .{});
    var viewColliders = reg.view(.{ Position, Body, Collision }, .{});

    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var entityVelocity = view.get(Velocity, entity);
        var entityCollision = view.get(Collision, entity);
        const entityPosition = view.getConst(Position, entity);
        const entityBody = view.getConst(Body, entity);

        const entityAabb = aabb.createAabb(
            entityPosition.getAbsoluteX(entityBody.width),
            entityPosition.getAbsoluteY(entityBody.height),
            entityBody.width,
            entityBody.height,
            entityVelocity.x,
            entityVelocity.y,
        );
        const entityBroadphaseAabb = aabb.createBroadphaseAabb(
            entityPosition.getAbsoluteX(entityBody.width),
            entityPosition.getAbsoluteY(entityBody.height),
            entityBody.width,
            entityBody.height,
            entityVelocity.x,
            entityVelocity.y,
        );

        var iterColliders = viewColliders.entityIterator();
        while (iterColliders.next()) |collider| {
            // Make sure not to check collisions the entity itself.
            if (collider == entity) {
                continue;
            }

            const colliderPosition = view.getConst(Position, collider);
            const colliderBody = view.getConst(Body, collider);
            const colliderAabb = aabb.createAabb(
                colliderPosition.getAbsoluteX(colliderBody.width),
                colliderPosition.getAbsoluteY(colliderBody.height),
                colliderBody.width,
                colliderBody.height,
                0,
                0,
            );

            if (aabb.check(entityBroadphaseAabb, colliderAabb)) {
                const sweepResult = aabb.sweep(entityAabb, colliderAabb);
                // Check if there is a collision:
                // Collision time < 1 indicates that there is a collision.
                // Collision time >= 1 indicates that there is no collision.
                if (sweepResult.time < 1) {
                    entityCollision.collided = true;
                    entityCollision.grounded = sweepResult.normalY != 0;

                    // Call onCollision callbacks on entity and collider, if
                    // available.
                    if (entityCollision.onCollision) |onCollision| {
                        onCollision(reg, entity, collider);
                    }
                    if (reg.has(Collision, collider)) {
                        const colliderCollision = reg.getConst(Collision, collider);
                        if (colliderCollision.onCollision) |onCollision| {
                            onCollision(reg, collider, entity);
                        }
                    }

                    // Calculate the corrected velocity based on the collision
                    // time.
                    const correctedVelocity: Velocity = .{
                        .x = entityVelocity.x * sweepResult.time,
                        .y = entityVelocity.y * sweepResult.time,
                    };

                    // Calculate the remaining velocity in response to the
                    // collision.
                    const responseVelocity = aabb.responseSlide(
                        .{ .x = entityVelocity.x, .y = entityVelocity.y },
                        sweepResult,
                    );

                    // Update the entity's velocity accordingly.
                    entityVelocity.x = correctedVelocity.x + responseVelocity.x;
                    entityVelocity.y = correctedVelocity.y + responseVelocity.y;
                }
            }
        }
    }
}
