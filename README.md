# Inventory demo

This demo project was created in reply to a question on the r/godot subreddit.

Although I believe this is a decently structured project, it is a demo and has not received the optimizations a larger project would likely require.

## Using

The current project is created in Godot 4.7.1, and can be opened in the editor.

### Controls

| Key               | Action                     |
| ----------------- | -------------------------- |
| `WASD`            | movement                   |
| `space`           | jump                       |
| `shift`           | sprint                     |
| `E`               | open/close inventory       |
| `Left mouse`      | Pick up item               |
| `Right mouse btn` | Throw item                 |
| `Scrollwheel`     | Cycle through hotbar items |
| `1-9`             | Select hotbar item         |
| `0`               | Deselect hotbar item       |

In the inventory screen, (stacks of) items can be dragged around between slots.

## Development

### Autoloads

`EventManager` and `Items` are autoloads, configurable via `Project > Project settings... > Globals`.

### Key bindings

The project defines custom key binds, configurable via `Project > Project settings... > Input Map`.

### Items

In `/systems/items.gd`, several different methods of adding items are demonstrated. It's up to the user to decide what method or combination of methods suits them and their project best.

## License

The game code, shaders and other assets are created by me and licensed under the
MIT license.

The icons in /content/icons are derived from [Lucide](https://lucide.dev), distributed under the ISC license.

The Godot game engine is licensed as described on [https://godotengine.org/license/](https://godotengine.org/license/).
