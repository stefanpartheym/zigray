//! This module provides the complete raylib C-API.

pub const raylib = @cImport({
    @cInclude("raylib.h");
});
