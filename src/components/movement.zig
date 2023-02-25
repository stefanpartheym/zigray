///
/// TODO:
/// An additional, more general type of movement is required, which also applies
/// to gravitation not only user input induced movement.
///

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
