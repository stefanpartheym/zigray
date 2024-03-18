const math = @import("std").math;
const Velocity = @import("velocity.zig").Velocity;

pub const Aabb = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    velocityX: f32,
    velocityY: f32,
};

pub const AabbSweepResult = struct {
    normalX: f32 = 0,
    normalY: f32 = 0,
    time: f32 = 1,
    remainingTime: f32 = 0,

    pub fn assign(self: *AabbSweepResult, other: AabbSweepResult) void {
        self.time = other.time;
        self.remainingTime = other.remainingTime;
        self.normalX = other.normalX;
        self.normalY = other.normalY;
    }
};

pub fn createAabb(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    velocityX: f32,
    velocityY: f32,
) Aabb {
    return Aabb{
        .x = x,
        .y = y,
        .w = width,
        .h = height,
        .velocityX = velocityX,
        .velocityY = velocityY,
    };
}

pub fn createBroadphaseAabb(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    velocityX: f32,
    velocityY: f32,
) Aabb {
    const targetX = if (velocityX > 0) x else x + velocityX;
    const targetY = if (velocityY > 0) y else y + velocityY;
    const targetWidth = if (velocityX > 0) velocityX + width else width - velocityX;
    const targetHeight = if (velocityY > 0) velocityY + height else height - velocityY;
    return Aabb{
        .x = targetX,
        .y = targetY,
        .w = targetWidth,
        .h = targetHeight,
        .velocityX = velocityX,
        .velocityY = velocityY,
    };
}

/// Performs a basic AABB collision detection.
/// This is mainly used in broadphase collision detection.
pub fn check(a: Aabb, b: Aabb) bool {
    return a.x < b.x + b.w and // Left edge is within right side of the collider?
        a.x + a.w > b.x and // Right edge is within left side of the collider?
        a.y < b.y + b.h and // Top edge is within bottom side of the collider?
        a.y + a.h > b.y; // Bottom edge is within top side of the collider?

}

/// Performs an AABB sweep.
pub fn sweep(a: Aabb, b: Aabb) AabbSweepResult {
    var xInvEntry: f32 = undefined;
    var xInvExit: f32 = undefined;
    var yInvEntry: f32 = undefined;
    var yInvExit: f32 = undefined;

    // Find the distance between the objects on the near and far sides for both
    // x and y.
    if (a.velocityX > 0) {
        xInvEntry = b.x - (a.x + a.w);
        xInvExit = (b.x + b.w) - a.x;
    } else {
        xInvEntry = (b.x + b.w) - a.x;
        xInvExit = b.x - (a.x + a.w);
    }

    if (a.velocityY > 0) {
        yInvEntry = b.y - (a.y + a.h);
        yInvExit = (b.y + b.h) - a.y;
    } else {
        yInvEntry = (b.y + b.h) - a.y;
        yInvExit = b.y - (a.y + a.h);
    }

    // Calculate time of collision and time of leaving for each axis
    // (if statements are to prevent division by zero).
    var entryX: f32 = undefined;
    var exitX: f32 = undefined;
    var entryY: f32 = undefined;
    var exitY: f32 = undefined;

    if (a.velocityX == 0) {
        entryX = -math.inf(f32);
        exitX = math.inf(f32);
    } else {
        entryX = xInvEntry / a.velocityX;
        exitX = xInvExit / a.velocityX;
    }

    if (a.velocityY == 0) {
        entryY = -math.inf(f32);
        exitY = math.inf(f32);
    } else {
        entryY = yInvEntry / a.velocityY;
        exitY = yInvExit / a.velocityY;
    }

    // Get earliest/latest times of collision.
    const entryTime: f32 = @max(entryX, entryY);
    const exitTime: f32 = @min(exitX, exitY);

    // Check if there was no collision.
    if (entryTime > exitTime or (entryX < 0 and entryY < 0) or entryX > 1 or entryY > 1) {
        return .{
            .normalX = 0,
            .normalY = 0,
            .time = 1,
            .remainingTime = 0,
        };
    }
    // If there was a collision.
    else {
        var normalX: f32 = undefined;
        var normalY: f32 = undefined;
        // calculate normal of collided surface
        if (entryX > entryY) {
            if (xInvEntry < 0) {
                normalX = 1;
                normalY = 0;
            } else {
                normalX = -1;
                normalY = 0;
            }
        } else {
            if (yInvEntry < 0) {
                normalX = 0;
                normalY = 1;
            } else {
                normalX = 0;
                normalY = -1;
            }
        }

        // return the time of collision
        return .{
            .normalX = normalX,
            .normalY = normalY,
            .time = entryTime,
            .remainingTime = 1 - entryTime,
        };
    }
}

/// Respond to AABB collision by sliding the entity along the edge of the
/// collider.
pub fn responseSlide(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    const dotProduct =
        (velocity.x * sweepResult.normalY +
        velocity.y * sweepResult.normalX) *
        sweepResult.remainingTime;

    return .{
        .y = dotProduct * sweepResult.normalX,
        .x = dotProduct * sweepResult.normalY,
    };
}

/// Respond to AABB collision by pushing the entity along the edge of the
/// collider.
pub fn responsePush(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    const magnitude =
        math.sqrt((velocity.x * velocity.x + velocity.y * velocity.y)) *
        sweepResult.remainingTime;
    var dotProduct = velocity.x * sweepResult.normalY + velocity.y * sweepResult.normalX;

    if (dotProduct > 0) {
        dotProduct = 1;
    } else if (dotProduct < 0) {
        dotProduct = -1;
    }

    return .{
        .x = dotProduct * sweepResult.normalY * magnitude,
        .y = dotProduct * sweepResult.normalX * magnitude,
    };
}

/// Respond to AABB collision by bouncing the entity off the edge of the
/// collider.
pub fn responseBounce(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    var result: Velocity = .{
        .x = velocity.x * sweepResult.remainingTime,
        .y = velocity.y * sweepResult.remainingTime,
    };

    if (@abs(sweepResult.normalX) > 0.0001) result.x = -result.x;
    if (@abs(sweepResult.normalY) > 0.0001) result.y = -result.y;

    return result;
}
