const std = @import("std");
const rl = @import("raylib");

const utils = @import("../utils/main.zig");

const SpriteOrigin = struct {
    x: i32,
    y: i32,
};

const SpriteSource = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};

pub const Sprite = struct {
    texture: *const rl.Texture,
    origin: ?SpriteOrigin = null,
    source: ?SpriteSource = null,
    flip: bool = false,
};

pub const SpriteStore = utils.Store(Sprite);

//------------------------------------------------------------------------------

pub const SpriteSheetSpriteDefinition = struct {
    name: []u8,
    source: [4]i32,
    origin: [2]i32,
};

pub const SpriteSheetAnimationDefinition = struct {
    name: [:0]const u8,
    start: usize,
    length: usize,
    fps: usize,
};

pub const SpriteSheetDefinition = struct {
    sprites: []SpriteSheetSpriteDefinition,
    animations: []SpriteSheetAnimationDefinition,
};
