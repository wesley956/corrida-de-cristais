extends Node
## ScreenFlowSystem.gd
## Ponte segura para centralizar fluxo de telas e visibilidade de layers.
##
## Nesta etapa:
## - Controla screen.
## - Controla visibilidade das layers principais.
## - Controla countdown básico da corrida.
##
## Ainda NÃO controla:
## - Resultado final.
## - Missões.
## - Save.
## - VFX.
## - Atualização interna de loja/núcleo/menu.

var screen: String = "menu"
var run_countdown: float = 0.0

var hud_layer_ref: CanvasLayer = null
var menu_layer_ref: CanvasLayer = null
var result_layer_ref: CanvasLayer = null
var shop_layer_ref: CanvasLayer = null
var pause_layer_ref: CanvasLayer = null
var cultivation_layer_ref: CanvasLayer = null
var tutorial_layer_ref: CanvasLayer = null
var transition_layer_ref: CanvasLayer = null

var neo_ui_ref: Node = null
var transition_label_ref: Label = null
var transition_subtitle_ref: Label = null
var biome_label_ref: Label = null

var has_bound_nodes: bool = false


func bind_screen_nodes(
	hud_layer: CanvasLayer,
	menu_layer: CanvasLayer,
	result_layer: CanvasLayer,
	shop_layer: CanvasLayer,
	pause_layer: CanvasLayer,
	cultivation_layer: CanvasLayer,
	tutorial_layer: CanvasLayer,
	transition_layer: CanvasLayer,
	neo_ui: Node,
	transition_label: Label,
	transition_subtitle: Label,
	biome_label: Label
) -> void:
	hud_layer_ref = hud_layer
	menu_layer_ref = menu_layer
	result_layer_ref = result_layer
	shop_layer_ref = shop_layer
	pause_layer_ref = pause_layer
	cultivation_layer_ref = cultivation_layer
	tutorial_layer_ref = tutorial_layer
	transition_layer_ref = transition_layer
	neo_ui_ref = neo_ui
	transition_label_ref = transition_label
	transition_subtitle_ref = transition_subtitle
	biome_label_ref = biome_label
	has_bound_nodes = true


func get_screen() -> String:
	return screen


func hide_all_layers() -> void:
	if not has_bound_nodes:
		return

	hud_layer_ref.visible = false
	menu_layer_ref.visible = false
	result_layer_ref.visible = false
	shop_layer_ref.visible = false
	pause_layer_ref.visible = false
	cultivation_layer_ref.visible = false
	tutorial_layer_ref.visible = false
	transition_layer_ref.visible = false

	if neo_ui_ref != null and neo_ui_ref.has_method("hide_all"):
		neo_ui_ref.hide_all()


func show_menu() -> void:
	screen = "menu"
	hide_all_layers()

	if not has_bound_nodes:
		return

	menu_layer_ref.visible = true
	hud_layer_ref.visible = false

	if neo_ui_ref != null and neo_ui_ref.has_method("show_menu"):
		neo_ui_ref.show_menu()


func show_shop() -> void:
	screen = "shop"
	hide_all_layers()

	if neo_ui_ref != null and neo_ui_ref.has_method("show_pavilion"):
		neo_ui_ref.show_pavilion()


func show_cultivation() -> void:
	screen = "cultivation"
	hide_all_layers()

	if neo_ui_ref != null and neo_ui_ref.has_method("show_core"):
		neo_ui_ref.show_core()


func show_tutorial() -> void:
	screen = "tutorial"
	hide_all_layers()

	if has_bound_nodes:
		tutorial_layer_ref.visible = true


func pause_game(current_screen: String) -> bool:
	if current_screen != "game":
		return false

	screen = "pause"

	if not has_bound_nodes:
		return true

	if neo_ui_ref != null and neo_ui_ref.has_method("hide_all"):
		neo_ui_ref.hide_all()

	hud_layer_ref.visible = false
	pause_layer_ref.visible = true

	return true


func resume_game(current_screen: String) -> bool:
	if current_screen != "pause":
		return false

	screen = "game"

	if has_bound_nodes:
		hud_layer_ref.visible = true
		pause_layer_ref.visible = false

	return true


func start_countdown(biome_name: String, duration: float = 2.2) -> Dictionary:
	screen = "countdown"
	run_countdown = duration
	hide_all_layers()

	if has_bound_nodes:
		transition_layer_ref.visible = true

		if transition_label_ref != null:
			transition_label_ref.text = biome_name.to_upper()

		if transition_subtitle_ref != null:
			transition_subtitle_ref.text = "O caminho se abre…"

	return {
		"screen": screen,
		"run_countdown": run_countdown
	}


func update_countdown(delta: float, biome_name: String) -> Dictionary:
	run_countdown -= delta
	var started_game: bool = false

	var n: int = ceili(run_countdown)
	if n > 0:
		if transition_label_ref != null:
			transition_label_ref.text = str(n)

		if transition_subtitle_ref != null:
			transition_subtitle_ref.text = "Prepare-se…"
	else:
		screen = "game"
		started_game = true

		if has_bound_nodes:
			transition_layer_ref.visible = false
			hud_layer_ref.visible = true

		if biome_label_ref != null:
			biome_label_ref.text = biome_name.to_upper()

	return {
		"screen": screen,
		"run_countdown": run_countdown,
		"started_game": started_game
	}
