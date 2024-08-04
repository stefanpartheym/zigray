const rl = @import("raylib");
const graphics = @import("../../graphics/main.zig");

const VisualType = enum {
    color,
    sprite,
    text,
};

pub const Visual = union(VisualType) {
    color: rl.Color,
    sprite: graphics.Sprite,
    text: graphics.Text,
};
