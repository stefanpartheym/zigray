const ecs = @import("ecs");
const rl = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const Rectangle = @import("../../core/main.zig").Rectangle;
const Sprite = @import("../../graphics/main.zig").Sprite;
const Text = @import("../../graphics/main.zig").Text;
const aabb = @import("../../physics/aabb.zig");
const components = @import("../components.zig");
const Position = components.Position;
const Body = components.Body;
const Visual = components.Visual;
const Collision = components.Collision;
const Velocity = components.Velocity;

pub fn beginRendering(engine: *Engine) void {
    rl.beginDrawing();
    // Always clear the screen first.
    rl.clearBackground(rl.Color.black);
    // Render background, if available.
    if (engine.background) |background| {
        renderVisual(background, .{
            .x = 0,
            .y = 0,
            .width = engine.config.display.width,
            .height = engine.config.display.height,
        });
    }
}

pub fn endRendering(engine: *Engine) void {
    // Render debug info ontop of everything else.
    if (engine.isDebugModeEnabled()) {
        rl.drawFPS(10, 10);
    }
    rl.endDrawing();
}

pub fn render(engine: *Engine) void {
    var reg = engine.getEcsRegistry();
    var view = reg.view(.{ Position, Body, Visual }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position = view.getConst(Position, entity);
        const body = view.getConst(Body, entity);
        const visual = view.getConst(Visual, entity);
        renderVisual(
            visual,
            .{
                .x = position.getAbsoluteX(body.width),
                .y = position.getAbsoluteY(body.height),
                .width = body.width,
                .height = body.height,
            },
        );
    }

    // Render bounding box of collidable entities in debug mode.
    if (engine.isDebugModeEnabled()) {
        var viewColliders = reg.view(.{ Position, Body, Collision }, .{});
        var iterColliders = viewColliders.entityIterator();
        while (iterColliders.next()) |entity| {
            renderCenterPoint(engine, entity);
            renderBoundingBox(engine, entity);
        }
    }
}

fn renderVisual(visual: Visual, dest: Rectangle) void {
    switch (visual) {
        .color => renderColor(visual.color, dest),
        .sprite => renderSprite(visual.sprite, dest),
        .text => renderText(visual.text, dest),
    }
}

fn renderText(text: Text, dest: Rectangle) void {
    rl.drawText(text.text, @intFromFloat(dest.x), @intFromFloat(dest.y), text.size, text.color);
}


fn renderColor(color: rl.Color, dest: Rectangle) void {
    rl.drawRectangle(
        @intFromFloat(dest.x),
        @intFromFloat(dest.y),
        @intFromFloat(dest.width),
        @intFromFloat(dest.height),
        color,
    );
}

fn renderSprite(sprite: Sprite, dest: Rectangle) void {
    var source: rl.Rectangle = .{
        .x = 0,
        .y = 0,
        .width = @floatFromInt(sprite.texture.width),
        .height = @floatFromInt(sprite.texture.height),
    };
    if (sprite.source) |spriteSource| {
        source = .{
            .x = @floatFromInt(spriteSource.x),
            .y = @floatFromInt(spriteSource.y),
            .width = @floatFromInt(spriteSource.width),
            .height = @floatFromInt(spriteSource.height),
        };
    }
    const flipFactor: f32 = if (sprite.flip) -1 else 1;
    source.width *= flipFactor;

    rl.drawTexturePro(
        sprite.texture.*,
        source,
        .{
            .x = dest.x,
            .y = dest.y,
            .width = dest.width,
            .height = dest.height,
        },
        .{ .x = 0, .y = 0 },
        0,
        rl.Color.white,
    );
}

fn renderCenterPoint(engine: *Engine, entity: ecs.Entity) void {
    var reg = engine.getEcsRegistry();
    const position = reg.getConst(Position, entity);

    rl.drawCircle(
        @intFromFloat(position.x),
        @intFromFloat(position.y),
        2,
        rl.Color.red,
    );
}

fn renderBoundingBox(engine: *Engine, entity: ecs.Entity) void {
    var reg = engine.getEcsRegistry();

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
