const ecs = @import("ecs");
const ray = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../components.zig");
const Animation = components.Animation;
// const Body = components.Body;
const Visual = components.Visual;

/// Updates the visual component of an entity for each frame with the current
/// animation frame.
pub fn animate(engine: *Engine) void {
    var reg = engine.getEcsRegistry();
    var view = reg.view(.{ Animation, Visual }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        // const body = view.getConst(Body, entity);
        var animation = view.get(Animation, entity);
        const visual = view.get(Visual, entity);

        // Get the current animation definition and frame.
        const definition = animation.definitions[animation.definition];
        const frame = definition[animation.frame];

        const flipFactor: i32 = if (animation.flipFrame) -1 else 1;
        // Update the visual component with the current frame.
        visual.* = .{
            .sprite = .{
                .texture = frame.sprite.texture,
                .source = .{
                    .x = frame.sprite.source.x,
                    .y = frame.sprite.source.y,
                    .width = frame.sprite.source.width * flipFactor,
                    .height = frame.sprite.source.height,
                },
            },
        };

        // Increase the frame time and the frame counter if needed.
        if (definition.len > 1) {
            animation.frameTime += engine.getDeltaTime();
            if (animation.frameTime >= frame.duration) {
                if (animation.frame < definition.len - 1) {
                    animation.frame = animation.frame + 1;
                } else {
                    animation.frame = 0;
                }

                animation.frameTime = 0;
            }
        }
    }
}
