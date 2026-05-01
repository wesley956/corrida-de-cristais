# Fragment Rush v1.2 — UI Scenes Rebuild

## Objetivo
Parar de remendar a interface dentro de um único `Main.gd` e começar uma base real de UI moderna usando cenas próprias do Godot.

## O que foi adicionado
- `scenes/ui/NeoMenuScreen.tscn`
- `scenes/ui/NeoPavilionScreen.tscn`
- `scenes/ui/NeoCoreScreen.tscn`
- `scripts/ui/FragmentUiTheme.gd`
- `scripts/ui/NeoBackground.gd`
- `scripts/ui/OrbPreview.gd`
- `scripts/ui/NeoMenuScreen.gd`
- `scripts/ui/NeoPavilionScreen.gd`
- `scripts/ui/NeoCoreScreen.gd`
- `scripts/ui/FragmentUiController.gd`

## Como usar
Esta versão entrega a base visual moderna em cenas separadas. A próxima etapa é ligar o `FragmentUiController` ao `Main.gd` e substituir gradualmente a UI antiga.

## Por que isso é importante
A UI deixa de ser “desenhada na mão” em um script gigante e passa a ser uma arquitetura própria, mais fácil de animar, ajustar, trocar layout e transformar em algo mais próximo do app Cultivation.
