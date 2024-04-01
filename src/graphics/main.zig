const rl = @import("raylib");

const SpriteSource = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};
pub const Sprite = struct {
    texture: *const rl.Texture,
    source: ?SpriteSource = null,
    flip: bool = false,
};
