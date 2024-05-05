const std = @import("std");

pub const StoreError = error{
    ItemNotFound,
};

pub fn Store(comptime T: type) type {
    return struct {
        items: std.StringHashMap(T),

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .items = std.StringHashMap(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn set(self: *Self, key: []const u8, value: T) !*const T {
            try self.items.put(key, value);
            return try self.get(key);
        }

        pub fn get(self: *const Self, key: []const u8) StoreError!*const T {
            if (self.items.getPtr(key)) |item| {
                return item;
            } else {
                return StoreError.ItemNotFound;
            }
        }
    };
}
