const ray = @import("raylib");
const ecs = @import("ecs");
const Position = @import("../components/components.zig").Position;
const Velocity = @import("../components/components.zig").Velocity;
const Body = @import("../components/components.zig").Body;
const Collision = @import("../components/components.zig").Collision;

/// Collision detection system
/// NOTE: Currently only supports collisions on Y-axis.
pub fn collide(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity, Body, Collision }, .{});
    var viewColliders = reg.view(.{ Position, Collision }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var positionA = view.get(Position, entity);
        const velocityA = view.getConst(Velocity, entity);
        const bodyA = view.getConst(Body, entity);

        var iterColliders = viewColliders.iterator();
        while (iterColliders.next()) |collider| {
            if (collider == entity) {
                continue;
            }

            const positionB = view.getConst(Position, collider);
            const bodyB = view.getConst(Body, collider);

            const rectA = ray.Rectangle{
                .x = positionA.getAbsoluteX(bodyA.width),
                .y = positionA.getAbsoluteY(bodyA.height),
                .width = bodyA.width,
                .height = bodyA.height
            };
            const rectB = ray.Rectangle{
                .x = positionB.getAbsoluteX(bodyB.width),
                .y = positionB.getAbsoluteY(bodyB.height),
                .width = bodyB.width,
                .height = bodyB.height
            };

            if (ray.CheckCollisionRecs(rectA, rectB)) {
                const collision = ray.GetCollisionRec(rectA, rectB);
                if (velocityA.getY() > 0) {
                    positionA.y -= collision.height;
                }
                else if (velocityA.getY() < 0) {
                    positionA.y += collision.height;
                }
            }
        }
    }
}
