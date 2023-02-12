pub const Velocity = struct {
    x: f32,
    y: f32,
    currentX: f32 = 0,
    currentY: f32 = 0,
    accelerationX: f32 = 0.25,
    accelerationY: f32 = 0.25,

    staticX: f32 = 0,
    staticY: f32 = 0,
    staticCurrentX: f32 = 0,
    staticCurrentY: f32 = 0,
    staticAccelerationX: f32 = 0.25,
    staticAccelerationY: f32 = 0.25,
};
