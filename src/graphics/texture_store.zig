const std = @import("std");
const rl = @import("raylib");

const utils = @import("../utils/main.zig");

pub const TextureStore = struct {
    store: utils.Store(rl.Texture),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .store = utils.Store(rl.Texture).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.store.deinit();
    }

    pub fn unloadAll(self: *Self) void {
        var it = self.store.items.valueIterator();
        while (it.next()) |item| {
            rl.unloadTexture(item.*);
        }
    }

    pub fn load(self: *Self, key: []const u8, filePath: [:0]const u8) !*const rl.Texture {
        return self.store.set(key, rl.loadTexture(filePath));
    }

    pub fn get(self: *const Self, key: []const u8) !*const rl.Texture {
        return self.store.get(key);
    }
};
