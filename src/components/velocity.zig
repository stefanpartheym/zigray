pub const Velocity = struct {
    x: f32,
    y: f32,
    currentX: f32 = 0,
    currentY: f32 = 0,
    accelerationX: f32 = 0.25,
    accelerationY: f32 = 0.25,

    fn accelerateXBy(self: *Velocity, acceleration: f32) void {
        if (self.currentX < self.x) {
            self.currentX += acceleration;
        }
    }

    fn accelerateYBy(self: *Velocity, acceleration: f32) void {
        if (self.currentY < self.y) {
            self.currentY += acceleration;
        }
    }

    pub fn accelerateX(self: *Velocity) void {
        self.accelerateXBy(self.accelerationX);
    }

    pub fn accelerateY(self: *Velocity) void {
        self.accelerateYBy(self.accelerationX);
    }
};
