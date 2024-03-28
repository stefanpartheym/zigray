const ecs = @import("ecs");

pub const Collision = struct {
    collided: bool = false,
    grounded: bool = false,
    onCollision: ?*const fn (*ecs.Registry, ecs.Entity, ecs.Entity) void = undefined,
};
