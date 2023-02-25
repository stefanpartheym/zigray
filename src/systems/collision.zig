const std = @import("std");
const ray = @import("raylib");
const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Movement = components.Movement;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;
const Body = components.Body;
const Collision = components.Collision;

const RectCollisionCause = enum {
    x,
    y,
};

const CollisionCheckData = struct {
    entity: ray.Rectangle,
    collider: ray.Rectangle,
};

fn prepareCollisionCheckData(
    entityPosition: Position,
    entityBody: Body,
    colliderPosition: Position,
    colliderBody: Body,
) CollisionCheckData {
    const entityRect = ray.Rectangle{
        .x = entityPosition.getAbsoluteX(entityBody.width),
        .y = entityPosition.getAbsoluteY(entityBody.height),
        .width = entityBody.width,
        .height = entityBody.height,
    };
    const colliderRect = ray.Rectangle{
        .x = colliderPosition.getAbsoluteX(colliderBody.width),
        .y = colliderPosition.getAbsoluteY(colliderBody.height),
        .width = colliderBody.width,
        .height = colliderBody.height,
    };

    return CollisionCheckData{
        .entity = entityRect,
        .collider = colliderRect,
    };
}

fn hasCollision(
    entityPosition: Position,
    entityBody: Body,
    colliderPosition: Position,
    colliderBody: Body,
) bool {
    const collisionCheck = prepareCollisionCheckData(
        entityPosition,
        entityBody,
        colliderPosition,
        colliderBody,
    );
    return ray.CheckCollisionRecs(collisionCheck.entity, collisionCheck.collider);
}

fn resolveCollision(
    movement: Movement,
    velocity: Velocity,
    positionA: Position,
    bodyA: Body,
    positionB: Position,
    bodyB: Body
) Position {
    var result = Position{ .x = positionA.x, .y = positionA.y };
    const collisionCheck = prepareCollisionCheckData(positionA, bodyA, positionB, bodyB);
    const collision = ray.GetCollisionRec(collisionCheck.entity, collisionCheck.collider);

    // TODO: Condition needs to be enhanced to avoid non-reactiveness when a
    // velocity below 0.25 is used.
    if (collision.height <= velocity.currentY and movement.directionY != .none) {
        if (movement.directionY == .up) {
            result.y += collision.height;
        }
        if (movement.directionY == .down) {
            result.y -= collision.height;
        }
    }

    // TODO: Condition needs to be enhanced to avoid non-reactiveness when a
    // velocity below 0.25 is used.
    if (collision.width <= velocity.currentX and movement.directionX != .none) {
        if (movement.directionX == .left) {
            result.x += collision.width;
        }
        if (movement.directionX == .right) {
            result.x -= collision.width;
        }
    }

    return result;
}

/// Collision detection and response system
pub fn collide(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity, Movement, Body, Collision }, .{});
    var viewColliders = reg.view(.{ Position, Collision }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var positionA = view.get(Position, entity);
        const bodyA = view.getConst(Body, entity);
        const velocity = view.getConst(Velocity, entity);
        const movement = view.getConst(Movement, entity);

        var iterColliders = viewColliders.iterator();
        while (iterColliders.next()) |collider| {
            // Make sure not to check collisions for the same entity.
            if (collider == entity) {
                continue;
            }

            const positionB = view.getConst(Position, collider);
            const bodyB = view.getConst(Body, collider);

            while (hasCollision(positionA.*, bodyA, positionB, bodyB)) {
                const newPosition = resolveCollision(
                    movement,
                    velocity,
                    positionA.*,
                    bodyA,
                    positionB,
                    bodyB,
                );
                positionA.x = newPosition.x;
                positionA.y = newPosition.y;
                // TODO: Make sure there are only two iterations max. Return error otherwise.
            }
        }
    }
}
