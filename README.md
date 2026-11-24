# Sky Obby

A short obstacle-course ("obby") game for Roblox, written entirely in Luau.
Race across floating platforms in the sky, hit every checkpoint, dodge the
lava, and reach the golden win pad at the end.

The whole course is generated from code at runtime — there is no binary
place file in this repo. Stage layouts live in a single config module, and
a server-side builder constructs the platforms, checkpoint pads, and kill
bricks from that data when the server starts.

## Features

- **8 hand-designed stages** — gap jumps, a lava run, narrow beams, a
  staircase, a zigzag, lava bridges, and a final climb
- **Checkpoint system** — touch a stage's glowing pad and it becomes your
  respawn point; progress is tracked in `leaderstats`
- **leaderstats** — `Stage` (highest checkpoint reached) and `Wins`
  (completed runs) for every player
- **Win pad** — finishing the course records a win, announces it to every
  player with an on-screen banner, and sends you back to stage 1
- **Procedural course building** — platforms, kill bricks, and pads are
  built from a typed config table, so adding a stage is a data edit
- **Code-built UI** — the stage counter and win banner are created in
  Luau, no GUI assets needed
- **Fall recovery** — drop below the course and you respawn at your last
  checkpoint

## How to open

This is a [Rojo](https://rojo.space/) project. You need Roblox Studio and
Rojo (the Studio plugin plus the CLI, or the VS Code extension).

1. Clone this repository.
2. From the project folder, start the Rojo server:

   ```sh
   rojo serve
   ```

3. Open Roblox Studio, create a new baseplate place, open the Rojo
   plugin, and connect. The source tree syncs into the place:
   - `src/shared` → ReplicatedStorage
   - `src/server` → ServerScriptService
   - `src/client` → StarterPlayerScripts
4. Press **Play**. The course builds itself in the sky — look up!

Alternatively, build a standalone place file and open that:

```sh
rojo build -o sky-obby.rbxlx
```

## Controls

Standard Roblox controls:

| Input | Action |
| --- | --- |
| W A S D / Arrow keys | Move |
| Space | Jump |
| Mouse | Camera |
| Touch / gamepad | On-screen controls provided by Roblox |

## Project structure

```
default.project.json     Rojo project definition (service mapping)
src/
  shared/
    CourseConfig.lua     Stage data: platforms, kill bricks, colours
  server/
    CourseBuilder.lua    Builds the course into Workspace at runtime
    Main.server.lua      Checkpoints, leaderstats, win logic, fall check
  client/
    ProgressUI.client.lua  Stage counter + win banner UI (built in code)
```

## Tech

Luau (strict-mode typed), Rojo. No external dependencies.

## License

MIT — see [LICENSE](LICENSE).
