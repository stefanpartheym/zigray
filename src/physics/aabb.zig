const math = @import("std").math;
const Velocity = @import("./velocity.zig").Velocity;

pub const Aabb = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    vx: f32,
    vy: f32,
};

pub const AabbSweepResult = struct {
    normalx: f32 = 0,
    normaly: f32 = 0,
    time: f32 = 1,
    remainingTime: f32 = 0,

    pub fn assign(self: *AabbSweepResult, other: AabbSweepResult) void {
        self.time = other.time;
        self.remainingTime = other.remainingTime;
        self.normalx = other.normalx;
        self.normaly = other.normaly;
    }
};

pub fn createAabb(x: f32, y: f32, w: f32, h: f32, vx: f32, vy: f32) Aabb {
    return Aabb{ .x = x, .y = y, .w = w, .h = h, .vx = vx, .vy = vy };
}

pub fn createBroadphaseAabb(x: f32, y: f32, w: f32, h: f32, vx: f32, vy: f32) Aabb {
    const pos_x = if (vx > 0) x else x + vx;
    const pos_y = if (vy > 0) y else y + vy;
    const width = if (vx > 0) vx + w else w - vx;
    const height = if (vy > 0) vy + h else h - vy;
    return Aabb{ .x = pos_x, .y = pos_y, .w = width, .h = height, .vx = vx, .vy = vy };
}

pub fn check(a: Aabb, b: Aabb) bool {
    return a.x < b.x + b.w and // left edge is past right edge of obstacle?
        a.x + a.w > b.x and // right edge is past left edge of obstacle?
        a.y < b.y + b.h and // top edge is past bottom edge of obstacle?
        a.y + a.h > b.y; // bottom edge is past top edge of obstacle?

}

pub fn sweep(a: Aabb, b: Aabb) AabbSweepResult {
    var xInvEntry: f32 = undefined;
    var xInvExit: f32 = undefined;
    var yInvEntry: f32 = undefined;
    var yInvExit: f32 = undefined;

    // find the distance between the objects on the near and far sides for both x and y
    if (a.vx > 0.0) {
        xInvEntry = b.x - (a.x + a.w);
        xInvExit = (b.x + b.w) - a.x;
    } else {
        xInvEntry = (b.x + b.w) - a.x;
        xInvExit = b.x - (a.x + a.w);
    }

    if (a.vy > 0.0) {
        yInvEntry = b.y - (a.y + a.h);
        yInvExit = (b.y + b.h) - a.y;
    } else {
        yInvEntry = (b.y + b.h) - a.y;
        yInvExit = b.y - (a.y + a.h);
    }

    // find time of collision and time of leaving for each axis (if statement is to prevent divide by zero)
    var xEntry: f32 = undefined;
    var xExit: f32 = undefined;
    var yEntry: f32 = undefined;
    var yExit: f32 = undefined;

    if (a.vx == 0.0) {
        xEntry = -math.inf(f32);
        xExit = math.inf(f32);
    } else {
        xEntry = xInvEntry / a.vx;
        xExit = xInvExit / a.vx;
    }

    if (a.vy == 0.0) {
        yEntry = -math.inf(f32);
        yExit = math.inf(f32);
    } else {
        yEntry = yInvEntry / a.vy;
        yExit = yInvExit / a.vy;
    }

    // find the earliest/latest times of collision
    const entryTime: f32 = @max(xEntry, yEntry);
    const exitTime: f32 = @min(xExit, yExit);

    if (entryTime > exitTime or (xEntry < 0.0 and yEntry < 0.0) or xEntry > 1.0 or yEntry > 1.0) {
        // if there was no collision
        return .{
            .normalx = 0,
            .normaly = 0,
            .time = 1,
            .remainingTime = 0,
        };
    } else {
        // if there was a collision
        var normalx: f32 = undefined;
        var normaly: f32 = undefined;
        // calculate normal of collided surface
        if (xEntry > yEntry) {
            if (xInvEntry < 0.0) {
                normalx = 1.0;
                normaly = 0.0;
            } else {
                normalx = -1.0;
                normaly = 0.0;
            }
        } else {
            if (yInvEntry < 0.0) {
                normalx = 0.0;
                normaly = 1.0;
            } else {
                normalx = 0.0;
                normaly = -1.0;
            }
        }

        // return the time of collision
        return .{
            .normalx = normalx,
            .normaly = normaly,
            .time = entryTime,
            .remainingTime = 1.0 - entryTime,
        };
    }
}

pub fn responseSlide(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    // Respond to collision by sliding the entity along the
    // edge of the collider.
    const dotprod =
        (velocity.x * sweepResult.normaly +
        velocity.y * sweepResult.normalx) *
        sweepResult.remainingTime;

    return .{
        .y = dotprod * sweepResult.normalx,
        .x = dotprod * sweepResult.normaly,
    };
}

/// Push entity along the collision edge.
pub fn responsePush(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    const magnitude =
        math.sqrt((velocity.x * velocity.x + velocity.y * velocity.y)) *
        sweepResult.remainingTime;
    var dotprod = velocity.x * sweepResult.normaly + velocity.y * sweepResult.normalx;

    if (dotprod > 0) {
        dotprod = 1;
    } else if (dotprod < 0) {
        dotprod = -1;
    }

    return .{
        .x = dotprod * sweepResult.normaly * magnitude,
        .y = dotprod * sweepResult.normalx * magnitude,
    };
}

// Bounce
pub fn responseBounce(velocity: Velocity, sweepResult: AabbSweepResult) Velocity {
    var result: Velocity = .{
        .x = velocity.x * sweepResult.remainingTime,
        .y = velocity.y * sweepResult.remainingTime,
    };

    if (@abs(sweepResult.normalx) > 0.0001) result.x = -result.x;
    if (@abs(sweepResult.normaly) > 0.0001) result.y = -result.y;

    return result;
}
