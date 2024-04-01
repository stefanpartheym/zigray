const std = @import("std");
const rl = @import("raylib");

pub const TextureStoreError = error{
    TextureNotFound,
};

pub const TextureStore = struct {
    items: std.StringHashMap(rl.Texture),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .items = std.StringHashMap(rl.Texture).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.items.deinit();
    }

    pub fn unloadAll(self: *Self) void {
        var it = self.items.valueIterator();
        while (it.next()) |item| {
            rl.unloadTexture(item.*);
        }
    }

    pub fn load(self: *Self, key: []const u8, filePath: [:0]const u8) !*const rl.Texture {
        const entry = try self.items.getOrPutValue(key, rl.loadTexture(filePath));
        return entry.value_ptr;
    }

    pub fn get(self: *const Self, key: []const u8) TextureStoreError.TextureNotFound!*const rl.Texture {
        if (self.items.getPtr(key)) |item| {
            return item;
        } else {
            return TextureStoreError.TextureNotFound;
        }
    }
};
