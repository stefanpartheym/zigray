const rl = @import("raylib");
const Sprite = @import("../graphics/main.zig").Sprite;

pub const VisualType = enum {
    color,
    sprite,
};

pub const Visual = union(VisualType) {
    color: rl.Color,
    sprite: Sprite,
};
