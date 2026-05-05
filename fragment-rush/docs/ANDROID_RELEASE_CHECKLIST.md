# Fragment Rush — Android Release Checklist

## Status atual

Projeto: Fragment Rush: Corrida dos Cristais
Engine alvo: Godot 4.2.x
Orientação: vertical/retrato
Viewport base: 720x1280
Renderer: mobile
Cena principal: res://scenes/Main.tscn

## Arquitetura atual

Sistemas separados:
- SaveManager.gd
- GameConfig.gd
- EventBus.gd
- PlayerController.gd
- SpawnerSystem.gd
- EntityFactory.gd
- EntitySystem.gd
- RunStateSystem.gd
- InputSystem.gd
- VfxSystem.gd
- HudSystem.gd
- ScreenFlowSystem.gd
- ResultSystem.gd

## Antes de compilar Android

1. Rodar teste headless do Godot.
2. Testar menu, corrida, dash, cristais, power-ups, colisão e resultado.
3. Configurar export templates do Godot 4.2.2.
4. Criar preset Android.
5. Definir package name: com.wesley.fragmentrush.
6. Configurar ícone e splash.
7. Exportar APK debug.
8. Testar no celular.
9. Ajustar performance, dificuldade e visual.
10. Exportar AAB release.

## Próxima fase recomendada

1. Gerar APK debug.
2. Testar gameplay real no celular.
3. Ajustar dificuldade e visual.
4. Adicionar ícone/splash definitivos.
5. Preparar monetização.
6. Gerar AAB release.
