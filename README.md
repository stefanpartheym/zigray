# zigray

An amateur 2D platformer game engine using [zig](https://ziglang.org/), [raylib](https://www.raylib.com/) and and [ECS](https://github.com/prime31/zig-ecs).

The main goal of this project is for me to learn gamed development and make a simple 2D platformer with it.

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

Assets used the test game.

| File                           | Description                                                                                                  | Source                                                                                                      | License |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ------- |
| `./assets/character.atlas.png` | A slightly modified version of the original sprite sheet from [Dylan Falconer](https://github.com/Falconerd) | [Falconerd/games-from-scratch](https://github.com/Falconerd/engine-from-scratch/blob/rec/assets/player.png) | unknown |

## Resources

Resources, links and respositories I used and learned from during development.

- [Dylan Falconer's "C Game + Engine from scratch" video series](https://www.youtube.com/watch?v=WficzyoTSsg&list=PLYokS5qr7lSsvgemrTwMSrQsdk4BRqJU6&pp=iAQB)
- [Swept AABB collision detection and response](https://gamedev.net/tutorials/programming/general-and-gameplay-programming/swept-aabb-collision-detection-and-response-r3084/)
- [craftpix.net: Great site with a lot of free game resources](https://craftpix.net/)
