const ray = @import("raylib");
const Sprite = @import("../graphics/main.zig").Sprite;

pub const VisualType = enum {
    color,
    sprite,
};

pub const Visual = union(VisualType) {
    color: ray.Color,
    sprite: Sprite,
};
