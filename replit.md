# Fragment Rush: Corrida dos Cristais

## Overview
Godot 4.2.2 GDScript mobile runner game with a wuxia/bamboo aesthetic. The player controls an animated stickman running through wuxia biomes, collecting jade crystals and avoiding obstacles. The pre-built web export (`build/web/`) is served by a Python HTTP server on port 5000.

## Architecture

### Entry Point
- `fragment-rush/serve_web.py` — Python server on port 5000 with COOP/COEP headers for SharedArrayBuffer
- `fragment-rush/build/web/` — Pre-compiled Godot web export (binary + .pck)
- `fragment-rush/project.godot` — Godot 4.2.2 project config

### Main Scene
- `fragment-rush/scenes/Main.tscn` — Root Node2D with Main.gd attached

### Core Game Script
- `fragment-rush/scripts/Main.gd` — All game logic (~2700 lines):
  - **Stickman player**: procedural drawing with states (running/moving_left/moving_right/dash/hit)
  - **Wuxia aesthetic**: dark green bamboo backgrounds, jade colors, mist, lanterns, falling leaves
  - **8 skins**: nucleo_errante, semente_jade, corredor_rubi, coracao_nebular, essencia_dourada, corredor_sombrio, corredor_celestial, corredor_fragmentado
  - **Crystal rarities**: common (cyan), rare (jade), epic (violet), legendary (gold)
  - **Obstacle patterns**: single, wall_gap, alternate, narrow, barrage + 5 obstacle types
  - **Missions system**: 7 missions with rewards tracked per-run
  - **6 biomes**: Floresta de Bambu → Ponte na Névoa → Vale de Jade → Ruínas → Penhascos → Templo
  - **Save system**: `user://fragment_rush_save_v2.json` with migration from v1

### UI Scripts (Neo-UI system)
- `fragment-rush/scripts/ui/FragmentUiController.gd` — Wires 3 neo screens, emits signals to Main.gd
- `fragment-rush/scripts/ui/NeoMenuScreen.gd` — Menu screen with set_data()
- `fragment-rush/scripts/ui/NeoCoreScreen.gd` — Cultivation/techniques screen with set_data()
- `fragment-rush/scripts/ui/NeoPavilionScreen.gd` — Shop with 8 skin buttons (SKIN_IDS array)
- `fragment-rush/scripts/ui/FragmentUiTheme.gd` — Wuxia color palette (jade greens, gold, violet)
- `fragment-rush/scripts/ui/NeoBackground.gd` — Bamboo stalks, mist ribbons, firefly particles
- `fragment-rush/scripts/ui/OrbPreview.gd` — Animated stickman preview for each skin

### UI Scenes
- `fragment-rush/scenes/ui/NeoMenuScreen.tscn`
- `fragment-rush/scenes/ui/NeoCoreScreen.tscn`
- `fragment-rush/scenes/ui/NeoPavilionScreen.tscn` — GridContainer with 8 skin buttons (Skin0–Skin7)

## Signal Chain
```
neo_ui.(start/pavilion/core/daily/guide/back/skin_selected/skin_action/upgrade)_requested
→ Main.gd handlers
→ update_neo_menu() / update_neo_pavilion() / update_neo_core()
```

## Skin System
| ID | Name | Price | Rarity |
|---|---|---|---|
| nucleo_errante | Corredor Inicial | free | Comum |
| semente_jade | Corredor de Jade | 1000 | Raro |
| corredor_rubi | Corredor Rubi | 2200 | Raro |
| coracao_nebular | Corredor Nebular | 3800 | Épico |
| essencia_dourada | Corredor Dourado | 6000 | Lendário |
| corredor_sombrio | Corredor Sombrio | 9000 | Épico |
| corredor_celestial | Corredor Celestial | 13000 | Épico |
| corredor_fragmentado | Corredor Fragmentado | 18000 | Lendário |

## Re-exporting
Source changes in `scripts/` and `scenes/` require Godot 4.2.2 to re-export:
1. Open `fragment-rush/project.godot` in Godot 4.2.2
2. Project → Export → Web → Export Project → `build/web/index.html`
3. The Python server will immediately serve the new build

## Known Limitations
- The Replit preview iframe may show a "SharedArrayBuffer" error — this is a browser security restriction in iframes, not a server bug. The game works in standalone browser tabs and when deployed.
- The web server already sends the correct `COOP`/`COEP` headers for SharedArrayBuffer support.
