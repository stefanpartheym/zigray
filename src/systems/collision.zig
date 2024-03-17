const std = @import("std");
const Engine = @import("../engine/engine.zig").Engine;
const aabb = @import("../physics/aabb.zig");
const components = @import("../components/main.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Gravity = components.Gravity;
const Body = components.Body;
const Collision = components.Collision;

/// Collision detection and response system
pub fn collide(engine: *Engine) void {
    var view = engine.registry.view(.{ Position, Velocity, Body, Collision }, .{});
    var viewColliders = engine.registry.view(.{ Position, Body, Collision }, .{});

    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const entityPosition = view.get(Position, entity);
        var entityVelocity = view.get(Velocity, entity);
        const entityBody = view.getConst(Body, entity);
        var entityCollision = view.get(Collision, entity);

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
                entityCollision.aabbSweepResult.assign(sweepResult);

                if (sweepResult.time < 1) {
                    const responseVelocity = aabb.responseSlideFast(
                        .{ .x = entityVelocity.x, .y = entityVelocity.y },
                        sweepResult,
                    );
                    entityVelocity.x = responseVelocity.x;
                    entityVelocity.y = responseVelocity.y;
                }
            } else {
                entityCollision.aabbSweepResult.assign(.{});
            }
        }
    }
}
