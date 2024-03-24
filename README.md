# zigray-test

Test game engine using zig and raylib.

## Roadmap

- [x] Jump movement
- [ ] Side scrolling
- [x] Shooting/projectiles
- [ ] Sprites/textures
- [ ] Enemies/AI

## Bugs

- [ ] Collision detection/response:
  - [ ] When the player moves upwards into an object, that is falling downwards (due to gravity), the collision is tunnelled and the player can move upwards through the object.
  - [ ] Sliding against a wall of multiple collider objects will result in the player being stuck to the wall and not moving once the edge of a collider object is reached.
