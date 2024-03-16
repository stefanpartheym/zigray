const AabbSweepResult = @import("../physics/aabb.zig").AabbSweptResult;

pub const Collision = struct {
    slide: bool = true,
    aabbSweepResult: AabbSweepResult = AabbSweepResult{},
};
