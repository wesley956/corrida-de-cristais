# Fragment Rush: Corrida dos Cristais

A Godot 4 mobile-style runner game exported to WebAssembly and served as a static web app.

## Project Structure

- `fragment-rush/` - Main project directory
  - `build/web/` - Pre-built Godot web export (HTML + WASM + PCK)
  - `scenes/` - Godot scene files (.tscn)
  - `scripts/` - GDScript source files (.gd)
  - `serve_web.py` - Python HTTP server with required CORS headers for WebAssembly
  - `Godot_v4.2.2-stable_linux.x86_64` - Godot editor binary

## Tech Stack

- **Game Engine**: Godot 4.2.2
- **Export Target**: Web (HTML5/WebAssembly)
- **Server**: Python `ThreadingHTTPServer` (serve_web.py)
- **Language**: GDScript

## Running the App

The app is served via `python fragment-rush/serve_web.py` on port 5000.

The server sets required headers for WebAssembly SharedArrayBuffer support:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

## Game Features

- Vertical mobile runner gameplay
- Lane-based movement (keyboard arrows/WASD or touch swipe)
- Collectible crystals
- Procedural obstacles
- Scoring, distance, combo system
- Power-ups
- Local high score and crystal persistence
- Cosmic procedural background
- Shop/form selection system

## Deployment

- Target: autoscale
- Run: `python fragment-rush/serve_web.py`
- Port: 5000
