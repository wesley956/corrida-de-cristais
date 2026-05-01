# Fragment Rush v1.2.3 — Compile Fix

## Correções
- Corrige erro de tipagem em `NeoPavilionScreen.gd`:
  - `var sid := ids[i]`
  - `func(id := sid)`
- Troca por método tipado `_on_skin_button_pressed(skin_id: String)`.
- `FragmentUiController` usa variáveis sem tipo rígido para evitar falha quando uma cena carrega como Control durante reimport.
- `set_data()` em Menu/Pavilhão/Núcleo usa `call_deferred` quando a cena ainda não terminou o `_ready`.
- Reduz risco de erros como `Invalid set index 'accent' on base Nil`.

## Arquivos alterados
- scripts/ui/NeoPavilionScreen.gd
- scripts/ui/NeoMenuScreen.gd
- scripts/ui/NeoCoreScreen.gd
- scripts/ui/FragmentUiController.gd
