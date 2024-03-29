# zigray

An amateur 2D platformer game engine using [zig](https://ziglang.org/), [raylib](https://www.raylib.com/) and and [ECS](https://github.com/prime31/zig-ecs).

## Roadmap

- [x] AABB collision detection
- [x] Jump movement
- [ ] Side scrolling
- [x] Shooting/projectiles
- [x] Sprites/textures/animations
- [ ] Enemies/AI

## Bugs

- [ ] Collision detection/response:
  - [ ] When the player moves upwards into an object, that is falling downwards (due to gravity), the collision is tunnelled and the player can move upwards through the object.
  - [ ] Sliding against a wall of multiple collider objects will result in the player being stuck to the wall and not moving once the edge of a collider object is reached.
- [ ] Gravity is too strong on higher frame rates.

## Assets

Assets used:

| File                           | Description                                                                                                  | Source                                                                                                      | License |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ------- |
| `./assets/character.atlas.png` | A slightly modified version of the original sprite sheet from [Dylan Falconer](https://github.com/Falconerd) | [Falconerd/games-from-scratch](https://github.com/Falconerd/engine-from-scratch/blob/rec/assets/player.png) | unknown |
