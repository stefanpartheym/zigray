const std = @import("std");
const ray = @import("raylib");
const Sprite = @import("../graphics/main.zig").Sprite;

pub const AnimationFrame = struct {
    sprite: Sprite,
    duration: f32 = 0.1,
};

pub const AnimationDefinition = []const AnimationFrame;
pub const AnimationDefinitions = []const AnimationDefinition;
