pub const Velocity = struct {
    x: f32 = 0,
    y: f32 = 0,
    staticY: f32 = 3,
    staticX: f32 = 0,

    pub fn getX(self: *const Velocity) f32 {
        return self.x + self.staticX;
    }

    pub fn getY(self: *const Velocity) f32 {
        return self.y + self.staticY;
    }
};

const std = @import("std");

test "get total X velocity" {
    const pos = Velocity{ .x = 5, .y = 0, .staticX = 3 };
    try std.testing.expectEqual(@as(f32, 8), pos.getX());
}

test "get total X velocity without staticX" {
    const pos = Velocity{ .x = 5, .y = 0, .staticX = 0 };
    try std.testing.expectEqual(@as(f32, 5), pos.getX());
}

test "get total Y velocity" {
    const pos = Velocity{ .x = 0, .y = 1 }; // Assuming default staticY = 3.
    try std.testing.expectEqual(@as(f32, 4), pos.getY());
}
