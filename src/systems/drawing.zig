const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");
const Engine = @import("../engine/engine.zig").Engine;
const components = @import("../components/index.zig");
const aabb = @import("../physics/aabb.zig");
const Position = components.Position;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Velocity = components.Velocity;

pub fn beginDrawing() void {
    ray.BeginDrawing();
    ray.ClearBackground(ray.BLACK);
}

pub fn endDrawing() void {
    ray.DrawFPS(10, 10);
    ray.EndDrawing();
}

pub fn draw(engine: *Engine) void {
    var view = engine.registry.view(.{ Position, Body, Visual }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position = view.getConst(Position, entity);
        const body = view.getConst(Body, entity);
        const visual = view.getConst(Visual, entity);
        ray.DrawRectangle(
            @intFromFloat(position.getAbsoluteX(body.width)),
            @intFromFloat(position.getAbsoluteY(body.height)),
            @intFromFloat(body.width),
            @intFromFloat(body.height),
            visual.color,
        );

        if (engine.isDebugModeEnabled() and engine.registry.has(Collision, entity)) {
            drawBoundingBox(engine, entity);
        }
    }
}

pub fn drawBoundingBox(engine: *Engine, entity: ecs.Entity) void {
    var velocityX: f32 = 0;
    var velocityY: f32 = 0;
    if (engine.registry.has(Velocity, entity)) {
        const vel = engine.registry.getConst(Velocity, entity);
        velocityX = vel.x;
        velocityY = vel.y;
    }
    const position = engine.registry.getConst(Position, entity);
    const body = engine.registry.getConst(Body, entity);
    const entityAabb = aabb.createAabb(
        position.getAbsoluteX(body.width),
        position.getAbsoluteY(body.height),
        body.width,
        body.height,
        velocityX,
        velocityY,
    );
    ray.DrawRectangleLines(
        @intFromFloat(entityAabb.x + entityAabb.velocityX),
        @intFromFloat(entityAabb.y + entityAabb.velocityY),
        @intFromFloat(entityAabb.w),
        @intFromFloat(entityAabb.h),
        ray.YELLOW,
    );
    ray.DrawRectangleLines(
        @intFromFloat(entityAabb.x),
        @intFromFloat(entityAabb.y),
        @intFromFloat(entityAabb.w),
        @intFromFloat(entityAabb.h),
        ray.RED,
    );
}
