const ecs = @import("ecs");

const PlayerState = enum {
    alive,
    dead,
};

pub const Player = struct {
    state: PlayerState = .alive,
    onStateChange: ?*const fn (
        *ecs.Registry,
        ecs.Entity,
        newState: PlayerState,
        oldState: PlayerState,
    ) void = undefined,

    pub const State = PlayerState;
};
