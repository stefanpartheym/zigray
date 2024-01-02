const std = @import("std");

const ecs = @import("ecs");
const components = @import("../components/index.zig");
const Position = components.Position;
const Gravity = components.Gravity;

/// Gravitation system
pub fn gravitate(reg: *ecs.Registry) void {
    var view = reg.view(.{ Position, Gravity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var position = view.get(Position, entity);
        const gravity = view.getConst(Gravity, entity);
        position.offsetX += gravity.forceX;
        position.offsetY += gravity.forceY;
    }
}
