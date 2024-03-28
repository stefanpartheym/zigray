const anim = @import("../../animation/main.zig");

pub const Animation = struct {
    definition: u8,
    frame: u8,
    frameTime: f32 = 0,
    flipFrame: bool = false,
    definitions: anim.AnimationDefinitions,
};
