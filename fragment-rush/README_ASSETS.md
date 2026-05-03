# Fragment Rush — Assets Organizados V1

Este pacote foi organizado para ser extraído dentro da pasta `fragment-rush` do projeto Godot.

## Estrutura

```text
assets/
  characters/stick_runner/frames/run/
  characters/stick_runner/frames/dash/
  characters/stick_runner/frames/hit/
  crystals/
  obstacles/
  backgrounds/bamboo/
  backgrounds/bridge/
  backgrounds/jade/
  vfx/
  ui/
```

## O que eu organizei

- Renomeei os frames do personagem para `run_01.png`, `dash_01.png`, `hit_01.png` etc.
- Separei os obstáculos que estavam dentro da pasta `Cristais`.
- Corrigi o nome `vfx_pickup_burst.pn.png` para `vfx_pickup_burst.png`.
- Padronizei os fundos em pastas por ambiente: `bamboo`, `bridge`, `jade`.
- Mantive os PNGs originais sem reduzir qualidade.

## Como inserir

Extraia este ZIP dentro da pasta `fragment-rush`, onde ficam:

```text
project.godot
scripts/
scenes/
```

Depois rode:

```bash
ls assets
```

## Próximo passo

A próxima etapa é adaptar o Godot para usar estes assets:

- criar `scenes/entities/StickRunner.tscn`
- criar `scripts/entities/StickRunner.gd`
- trocar o player desenhado por código por `AnimatedSprite2D`
- trocar cristais/obstáculos desenhados por código por sprites
- trocar o fundo procedural por camadas PNG com parallax
