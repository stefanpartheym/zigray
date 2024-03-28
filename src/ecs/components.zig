// Components
pub const Position = @import("components/position.zig").Position;
pub const Velocity = @import("components/velocity.zig").Velocity;
pub const Speed = @import("components/speed.zig").Speed;
pub const Gravity = @import("components/gravity.zig").Gravity;
pub const Movement = @import("components/movement.zig").Movement;
pub const MovementDirectionX = @import("components/movement.zig").MovementDirectionX;
pub const MovementDirectionY = @import("components/movement.zig").MovementDirectionY;
pub const Body = @import("components/body.zig").Body;
pub const Visual = @import("components/visual.zig").Visual;
pub const Collision = @import("components/collision.zig").Collision;
pub const Player = @import("components/player.zig").Player;
pub const Projectile = @import("components/projectile.zig").Projectile;
pub const Animation = @import("components/animation.zig").Animation;

// Tags
pub const Destroy = @import("components/destroy.zig").Destroy;

// Tests
test {
    _ = Position;
    _ = Velocity;
}
