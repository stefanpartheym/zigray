const ecs = @import("ecs");
const ray = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;
const components = @import("../../components/main.zig");
const Movement = components.Movement;
const Player = components.Player;
const MovementDirectionX = components.MovementDirectionX;
const MovementDirectionY = components.MovementDirectionY;

fn getDirectionX() MovementDirectionX {
    if (ray.IsKeyDown(ray.KEY_RIGHT) or ray.IsKeyDown(ray.KEY_L)) {
        return .right;
    } else if (ray.IsKeyDown(ray.KEY_LEFT) or ray.IsKeyDown(ray.KEY_H)) {
        return .left;
    } else {
        return .none;
    }
}

pub fn handleInput(engine: *Engine) void {
    const reg = engine.getRegistry();

    const directionX: MovementDirectionX = getDirectionX();
    const jump = ray.IsKeyPressed(ray.KEY_SPACE);
    const shoot = ray.IsKeyPressed(ray.KEY_F);

    var view = reg.view(.{ Movement, Player }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var movement = view.get(Movement, entity);
        movement.previousDirectionX = movement.directionX;
        movement.directionX = directionX;
        movement.previousDirectionY = movement.directionY;
        movement.directionY = if (jump) .up else .none;

        if (directionX != .none) {
            const entityBody = reg.tryGet(components.Body, entity);
            if (entityBody) |body| {
                body.facingDirectionX = directionX;
            }
        }

        if (shoot and
            reg.has(components.Movement, entity) and
            reg.has(components.Body, entity) and
            reg.has(components.Position, entity))
        {
            shootProjectile(engine, entity, .{
                .position = reg.getConst(components.Position, entity),
                .movement = reg.getConst(components.Movement, entity),
                .body = reg.getConst(components.Body, entity),
            });
        }
    }
}

//------------------------------------------------------------------------------

/// Relevant state of the shooting entity.
const OriginState = struct {
    position: components.Position,
    body: components.Body,
    movement: Movement,
};

pub fn shootProjectile(engine: *Engine, entity: ecs.Entity, originState: OriginState) void {
    const body: components.Body = .{ .width = 10, .height = 10 };
    const movement: components.Movement = .{
        .directionX = originState.body.facingDirectionX,
    };
    var positionOffset: f32 = originState.body.width / 2;
    if (originState.body.facingDirectionX == .left) {
        positionOffset = body.width * -1;
    }
    const position: components.Position = .{
        .x = originState.position.x + positionOffset,
        .y = originState.position.y,
    };

    var reg = engine.getRegistry();
    const projectileEntity = reg.create();
    reg.add(projectileEntity, body);
    reg.add(projectileEntity, movement);
    reg.add(projectileEntity, position);
    reg.add(projectileEntity, components.Speed{ .movement = 800 });
    reg.add(projectileEntity, components.Velocity{});
    reg.add(projectileEntity, components.Gravity{ .forceY = 1 });
    reg.add(projectileEntity, components.Visual{ .color = ray.RED });
    reg.add(projectileEntity, components.Projectile{ .shotBy = entity });
    reg.add(projectileEntity, components.Collision{
        .onCollision = struct {
            pub fn f(r: *ecs.Registry, e: ecs.Entity, collider: ecs.Entity) void {
                const projectile = r.getConst(components.Projectile, e);
                // Destroy the projectile if it hits an entity, that isn't a
                // projectile itself and isn't the origin of the shot.
                if (!(r.has(components.Projectile, collider) or
                    r.has(components.Destroy, e) or
                    projectile.shotBy == collider))
                {
                    r.add(e, components.Destroy{});
                }
            }
        }.f,
    });
}
