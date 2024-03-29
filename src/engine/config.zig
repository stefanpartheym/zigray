pub const DebugOptions = struct {
    enabled: bool = false,
};

pub const DisplayOptions = struct {
    width: f32,
    height: f32,
    targetFps: u8,
    useHighDpi: bool,
    title: [:0]const u8,
};

pub const PhysicsOptions = struct {
    gravity: struct {
        forceX: f32,
        forceY: f32,
    },
};

pub const EngineConfig = struct {
    debug: DebugOptions,
    display: DisplayOptions,
    physics: PhysicsOptions,
};
