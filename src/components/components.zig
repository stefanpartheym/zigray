pub const Position = @import("position.zig").Position;
pub const Velocity = @import("velocity.zig").Velocity;
pub const Body = @import("body.zig").Body;
pub const Visual = @import("visual.zig").Visual;
pub const Collision = @import("collision.zig").Collision;
pub const Player = @import("player.zig").Player;

test {
    _ = Position;
    _ = Velocity;
}
