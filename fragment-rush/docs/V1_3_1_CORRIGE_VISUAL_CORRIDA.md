# Fragment Rush v1.3.1 — Corrige Visual das Formas na Corrida

## Problema corrigido
Na v1.3, o Pavilhão mostrava formas diferentes, mas na corrida o player continuava parecendo igual e os rastros estavam discretos demais.

## Correções
- O polígono real do player agora muda conforme a forma equipada.
- `player_core`, `player_glow` e `player_ring` são atualizados com silhueta própria.
- Rastros ficaram mais visíveis e são desenhados como efeitos próprios, não só partículas pequenas.
- Cada forma tem trail específico:
  - Cristalino
  - Jade
  - Celestial
  - Nebular
  - Dourado
- Ao equipar forma, o visual é atualizado imediatamente.
- Ao comprar forma, o efeito “Nova Forma Desperta” atualiza o player na hora.

## Arquivo principal
- scripts/Main.gd
