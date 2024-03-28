const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../components.zig");

/// Destroys all entities that are tagged with a `Destroy ` component.
/// This is required for entities that are destroyed during collision resolution,
/// because collision resolution potentially runs multiple times per frame.
pub fn destroyTaggedEntities(engine: *Engine) void {
    var reg = engine.getRegistry();
    var view = reg.view(.{components.Destroy}, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        reg.destroy(entity);
    }
}
