const ray = @import("raylib");
const Engine = @import("../../engine/main.zig").Engine;

/// Common input handler system.
/// Handles events like closing the window, or toggling debug mode.
pub fn handleInput(engine: *Engine) void {
    // Toggle debug mode, if relevant.
    if (ray.IsKeyPressed(ray.KEY_F1)) {
        engine.toggleDebugMode();
    }

    // Update the engine's status on certain inputs.
    // For instance, if [Q] is pressed or if the user closes the window, the engine
    // will be stopped.
    if (ray.WindowShouldClose() or ray.IsKeyPressed(ray.KEY_Q)) {
        engine.changeStatus(.STOPPED);
    }
}
