const std = @import("std");
const ray = @import("raylib");
const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Velocity = components.Velocity;
const Gravity = components.Gravity;
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
        .x = entityPosition.getAbsoluteTempX(entityBody.width),
        .y = entityPosition.getAbsoluteTempY(entityBody.height),
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
    const normalizedCollisionValue =
        std.math.round(collisionValue * scaleFactor) / scaleFactor;
    const normalizedPositionOffset =
        std.math.round(positionOffset * scaleFactor) / scaleFactor;

    return normalizedCollisionValue <= normalizedPositionOffset;
}

fn isCollisionCauseX(direction: MovementDirectionX, offset: f32) bool {
    if (direction == .left) {
        return offset < 0;
    } else if (direction == .right) {
        return offset > 0;
    } else {
        return false;
    }
}

fn isCollisionCauseY(direction: MovementDirectionY, offset: f32) bool {
    if (direction == .up) {
        return offset < 0;
    } else if (direction == .down) {
        return offset > 0;
    } else {
        return false;
    }
}

fn resolveCollision(
    movement: Movement,
    positionA: Position,
    bodyA: Body,
    positionB: Position,
    bodyB: Body,
    potentialGravity: ?Gravity,
) CollisionResolveError!Position {
    var result = Position{ .x = positionA.tempX, .y = positionA.tempY };
    const collisionCheck = prepareCollisionCheckData(positionA, bodyA, positionB, bodyB);
    const collision = ray.GetCollisionRec(collisionCheck.entity, collisionCheck.collider);
    const gravity = potentialGravity orelse Gravity{ .forceX = 0, .forceY = 0 };

    const causedByX =
        (isCollisionCauseX(movement.directionX, positionA.offsetX) or gravity.forceX != 0) and
        isCollisionCause(collision.width, @abs(positionA.offsetX));
    const causedByY =
        (isCollisionCauseY(movement.directionY, positionA.offsetY) or gravity.forceY != 0) and
        isCollisionCause(collision.height, @abs(positionA.offsetY));

    if (!causedByX and !causedByY) {
        return CollisionResolveError.NoCollisionCauseDetected;
    }

    if (causedByY) {
        const correctionFactor: f32 = if (positionA.offsetY < 0) 1 else -1;
        result.y += collision.height * correctionFactor;
    }

    if (causedByX) {
        const correctionFactor: f32 = if (positionA.offsetX < 0) 1 else -1;
        result.x += collision.width * correctionFactor;
    }

    return result;
}

/// Collision detection and response system
pub fn collide(reg: *ecs.Registry) CollisionSystemError!void {
    var view = reg.view(.{ Position, Movement, Body, Collision }, .{});
    var viewColliders = reg.view(.{ Position, Collision }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var positionA = view.get(Position, entity);
        const bodyA = view.getConst(Body, entity);
        const movement = view.getConst(Movement, entity);

        var iterColliders = viewColliders.entityIterator();
        while (iterColliders.next()) |collider| {
            // Make sure not to check collisions the entity itself.
            if (collider == entity) {
                continue;
            }

            const positionB = view.getConst(Position, collider);
            const bodyB = view.getConst(Body, collider);

            // Resolve collision only, if a collision is detected.
            if (hasCollision(positionA.*, bodyA, positionB, bodyB)) {
                const newPosition = try resolveCollision(
                    movement,
                    positionA.*,
                    bodyA,
                    positionB,
                    bodyB,
                    view.getConst(Gravity, entity),
                );
                positionA.tempX = newPosition.x;
                positionA.tempY = newPosition.y;
            }
        }
    }
}
