const ecs = @import("ecs");
const Position = @import("../components/components.zig").Position;
const Velocity = @import("../components/components.zig").Velocity;

pub fn move(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Velocity }, .{});
    var iter = view.iterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const velocity = view.getConst(Velocity, entity);
        position.x += velocity.getX();
        position.y += velocity.getY();
    }
}
