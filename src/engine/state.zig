pub const DebugState = struct {
    enabled: bool = false,
};

pub const DisplayState = struct {
    width: f32,
    height: f32,
    targetFps: u8,
    useHighDpi: bool,
    title: [:0]const u8,
};

pub const PhysicsState = struct {
    gravity: struct {
        forceX: f32,
        forceY: f32,
    },
};

pub const EngineStatus = enum {
    STOPPED,
    RUNNING,
};

pub const EngineState = struct {
    status: EngineStatus,
    debug: DebugState,
    display: DisplayState,
    physics: PhysicsState,
};
