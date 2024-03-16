const AabbSweepResult = @import("../physics/aabb.zig").AabbSweepResult;

pub const Collision = struct {
    slide: bool = true,
    aabbSweepResult: AabbSweepResult = AabbSweepResult{},
};
