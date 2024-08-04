//! zigray library.

pub const animation = @import("./animation/main.zig");
pub const core = @import("./core/main.zig");
pub const ecs = @import("./ecs/main.zig");
pub const engine = @import("./engine/main.zig");
pub const graphics = @import("./graphics/main.zig");
pub const physics = @import("./physics/main.zig");

test {
    _ = @import("ecs/components.zig");
}
