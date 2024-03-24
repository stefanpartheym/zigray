// Components
pub const Position = @import("position.zig").Position;
pub const Velocity = @import("velocity.zig").Velocity;
pub const Speed = @import("speed.zig").Speed;
pub const Gravity = @import("gravity.zig").Gravity;
pub const Movement = @import("movement.zig").Movement;
pub const MovementDirectionX = @import("movement.zig").MovementDirectionX;
pub const MovementDirectionY = @import("movement.zig").MovementDirectionY;
pub const Body = @import("body.zig").Body;
pub const Visual = @import("visual.zig").Visual;
pub const Collision = @import("collision.zig").Collision;
pub const Player = @import("player.zig").Player;
pub const Projectile = @import("projectile.zig").Projectile;

// Tags
pub const Destroy = @import("destroy.zig").Destroy;

test {
    _ = Position;
    _ = Velocity;
}
