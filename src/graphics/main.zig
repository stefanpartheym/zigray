const rl = @import("raylib");

pub const Sprite = struct {
    texture: *const rl.Texture,
    source: struct {
        x: u32,
        y: u32,
        width: i32,
        height: i32,
    },
};
