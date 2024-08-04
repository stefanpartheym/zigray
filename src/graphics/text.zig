const rl = @import("raylib");

pub const Text = struct {
    text: [:0]const u8,
    color: rl.Color,
    size: i32 = 12,
};
