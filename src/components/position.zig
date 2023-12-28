/// The `Position` component stores 2D-position coordinates that relate to the
/// center point of the entity it describes the position for.
pub const Position = struct {
    x: f32,
    y: f32,
    tempX: f32 = 0,
    tempY: f32 = 0,
    offsetX: f32 = 0,
    offsetY: f32 = 0,

    pub fn getAbsoluteTempX(self: *const Position, width: f32) f32 {
        return self.tempX - (width / 2);
    }

    pub fn getAbsoluteTempY(self: *const Position, height: f32) f32 {
        return self.tempY - (height / 2);
    }

    /// Convert the X coordinate relative to the entities center point to an
    /// absoulte X coordinate to be used for low level grid operations.
    pub fn getAbsoluteX(self: *const Position, width: f32) f32 {
        return self.x - (width / 2);
    }

    /// Convert the Y coordinate relative to the entities center point to an
    /// absoulte Y coordinate to be used for low level grid operations.
    pub fn getAbsoluteY(self: *const Position, height: f32) f32 {
        return self.y - (height / 2);
    }
};

const std = @import("std");

test "translate center point based X coordinate to absolute coordinate" {
    const pos = Position{ .x = 500, .y = 0 };
    try std.testing.expectEqual(@as(f32, 475), pos.getAbsoluteX(@as(f32, 50)));
}

test "translate center point based Y coordinate to absolute coordinate" {
    const pos = Position{ .x = 0, .y = 100 };
    try std.testing.expectEqual(@as(f32, 50), pos.getAbsoluteY(@as(f32, 100)));
}
