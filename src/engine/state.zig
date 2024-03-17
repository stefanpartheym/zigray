pub const DebugState = struct {
    enabled: bool = false,
};

pub const DisplayState = struct {
    width: f32,
    height: f32,
    targetFps: u8,
    useHighDpi: bool,
    title: [*c]const u8,
};

pub const EngineState = struct {
    debug: DebugState,
    display: DisplayState,
};
