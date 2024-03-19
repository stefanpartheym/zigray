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
    previousDirectionX: MovementDirectionX = .none,
    directionY: MovementDirectionY = .none,
    previousDirectionY: MovementDirectionY = .none,
    jump: bool = false,
};
