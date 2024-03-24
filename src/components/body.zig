const movement = @import("movement.zig");

pub const Body = struct {
    width: f32,
    height: f32,
    facingDirectionX: movement.MovementDirectionX = .right,
    facingDirectionY: movement.MovementDirectionY = .none,
};
