const std = @import("std");
const ecs = @import("ecs");
const components = @import("../components/index.zig");
const aabb = @import("../physics/aabb.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Gravity = components.Gravity;
const Movement = components.Movement;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;
const Body = components.Body;
const Collision = components.Collision;

/// Collision detection and response system
pub fn collide(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity, Body, Collision }, .{});
    var viewColliders = reg.view(.{ Position, Body, Collision }, .{});

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
                    const newVelocity = aabb.responseSlide(
                        .{ .x = entityVelocity.x, .y = entityVelocity.y },
                        sweepResult,
                    );
                    entityVelocity.x = newVelocity.x;
                    entityVelocity.y = newVelocity.y;
                }
            } else {
                entityCollision.aabbSweepResult.assign(.{});
            }
        }
    }
}
