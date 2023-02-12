pub const MovementDirectionX = enum {
    none,
    left,
    right,
};
pub const MovementDirectionY = enum {
    none,
    up,
    down,
};

pub const Movement = struct {
    directionX: MovementDirectionX = .none,
    directionY: MovementDirectionY = .none,
};
