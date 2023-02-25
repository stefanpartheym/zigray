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

pub const CollisionResolveError = error{
    NoCollisionCauseDetected,
};

pub const CollisionSystemError = error{
    NoCollisionCauseDetected,
    UnableToResolveCollision,
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

/// Returns whether or not the given collision value could be caused by the
/// given position offset.
fn isCollisionCause(collisionValue: f32, positionOffset: f32) bool {
    const scaleFactor = 4 * 10;
    const normalizedCollisionValue = std.math.round(collisionValue * scaleFactor) / scaleFactor;
    const normalizedPositionOffset = std.math.round(positionOffset * scaleFactor) / scaleFactor;

    return normalizedCollisionValue <= normalizedPositionOffset;
}

fn resolveCollision(
    movement: Movement,
    velocity: Velocity,
    positionA: Position,
    bodyA: Body,
    positionB: Position,
    bodyB: Body,
) CollisionResolveError!Position {
    var result = Position{ .x = positionA.x, .y = positionA.y };
    const collisionCheck = prepareCollisionCheckData(positionA, bodyA, positionB, bodyB);
    const collision = ray.GetCollisionRec(collisionCheck.entity, collisionCheck.collider);

    const causedByX =
        movement.directionX != .none and
        isCollisionCause(collision.width, velocity.currentX);
    const causedByY =
        movement.directionY != .none and
        isCollisionCause(collision.height, velocity.currentY);

    if (!causedByX and !causedByY) {
        return CollisionResolveError.NoCollisionCauseDetected;
    }

    if (causedByY) {
        if (movement.directionY == .up) {
            result.y += collision.height;
        }
        if (movement.directionY == .down) {
            result.y -= collision.height;
        }
    }

    if (causedByX) {
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
pub fn collide(reg: *ecs.Registry) CollisionSystemError!void {
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

            const maxIterations = 2;
            var currentIterations: u8 = 0;
            while (hasCollision(positionA.*, bodyA, positionB, bodyB)) {
                // Make sure to return an error, if collision could not be
                // resolved within 2 iterations.
                if (currentIterations > maxIterations) {
                    return CollisionSystemError.UnableToResolveCollision;
                }

                const newPosition = try resolveCollision(
                    movement,
                    velocity,
                    positionA.*,
                    bodyA,
                    positionB,
                    bodyB,
                );
                positionA.x = newPosition.x;
                positionA.y = newPosition.y;

                currentIterations += 1;
            }
        }
    }
}
