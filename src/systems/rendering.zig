const ecs = @import("ecs");
const rl = @import("raylib");
const Engine = @import("../engine/main.zig").Engine;
const components = @import("../components/main.zig");
const aabb = @import("../physics/aabb.zig");
const Position = components.Position;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Velocity = components.Velocity;

pub fn beginRendering() void {
    rl.beginDrawing();
    rl.clearBackground(rl.Color.black);
}

pub fn endRendering(engine: *Engine) void {
    if (engine.isDebugModeEnabled()) {
        rl.drawFPS(10, 10);
    }
    rl.endDrawing();
}

pub fn render(engine: *Engine) void {
    var reg = engine.getRegistry();
    var view = reg.view(.{ Position, Body, Visual }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position = view.getConst(Position, entity);
        const body = view.getConst(Body, entity);
        const visual = view.getConst(Visual, entity);
        switch (visual) {
            .color => renderColor(position, body, visual),
            .sprite => renderSprite(position, body, visual),
        }

        if (engine.isDebugModeEnabled() and reg.has(Collision, entity)) {
            renderCenterPoint(engine, entity);
            renderBoundingBox(engine, entity);
        }
    }
}

fn renderColor(position: Position, body: Body, visual: Visual) void {
    rl.drawRectangle(
        @intFromFloat(position.getAbsoluteX(body.width)),
        @intFromFloat(position.getAbsoluteY(body.height)),
        @intFromFloat(body.width),
        @intFromFloat(body.height),
        visual.color,
    );
}

fn renderSprite(position: Position, body: Body, visual: Visual) void {
    rl.drawTexturePro(
        visual.sprite.texture.*,
        .{
            .x = @floatFromInt(visual.sprite.source.x),
            .y = @floatFromInt(visual.sprite.source.y),
            .width = @floatFromInt(visual.sprite.source.width),
            .height = @floatFromInt(visual.sprite.source.height),
        },
        .{
            .x = position.getAbsoluteX(body.width),
            .y = position.getAbsoluteY(body.height),
            .width = body.width,
            .height = body.height,
        },
        .{
            .x = 0,
            .y = 0,
        },
        0,
        rl.Color.white,
    );
}

fn renderCenterPoint(engine: *Engine, entity: ecs.Entity) void {
    var reg = engine.getRegistry();
    const position = reg.getConst(Position, entity);

    rl.drawCircle(
        @intFromFloat(position.x),
        @intFromFloat(position.y),
        2,
        rl.Color.red,
    );
}

fn renderBoundingBox(engine: *Engine, entity: ecs.Entity) void {
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
    rl.drawRectangleLines(
        @intFromFloat(entityAabb.x + entityAabb.velocityX),
        @intFromFloat(entityAabb.y + entityAabb.velocityY),
        @intFromFloat(entityAabb.w),
        @intFromFloat(entityAabb.h),
        rl.Color.yellow,
    );
    rl.drawRectangleLines(
        @intFromFloat(entityAabb.x),
        @intFromFloat(entityAabb.y),
        @intFromFloat(entityAabb.w),
        @intFromFloat(entityAabb.h),
        rl.Color.red,
    );
}
