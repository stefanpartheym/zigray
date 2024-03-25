const std = @import("std");
const ecs = @import("ecs");
const ray = @import("raylib");
const Engine = @import("../engine/main.zig").Engine;
const components = @import("../components/main.zig");
const aabb = @import("../physics/aabb.zig");
const Position = components.Position;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Velocity = components.Velocity;

pub fn beginRendering() void {
    ray.BeginDrawing();
    ray.ClearBackground(ray.BLACK);
}

pub fn endRendering() void {
    ray.DrawFPS(10, 10);
    ray.EndDrawing();
}

pub fn render(engine: *Engine) void {
    var reg = engine.getRegistry();
    var view = reg.view(.{ Position, Body, Visual }, .{});
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

        if (engine.isDebugModeEnabled() and reg.has(Collision, entity)) {
            renderCenterPoint(engine, entity);
            renderBoundingBox(engine, entity);
        }
    }
}

pub fn renderCenterPoint(engine: *Engine, entity: ecs.Entity) void {
    var reg = engine.getRegistry();
    const position = reg.getConst(Position, entity);

    ray.DrawCircle(
        @intFromFloat(position.x),
        @intFromFloat(position.y),
        2,
        ray.RED,
    );
}

pub fn renderBoundingBox(engine: *Engine, entity: ecs.Entity) void {
    var reg = engine.getRegistry();

    var velocityX: f32 = 0;
    var velocityY: f32 = 0;
    if (reg.has(Velocity, entity)) {
        const vel = reg.getConst(Velocity, entity);
        velocityX = vel.x;
        velocityY = vel.y;
    }
    const position = reg.getConst(Position, entity);
    const body = reg.getConst(Body, entity);
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
