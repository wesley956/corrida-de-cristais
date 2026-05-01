extends Node2D

# Fragment Rush: Corrida dos Cristais
# v0.7 - Nucleo de Cultivo + Tecnicas
# Runner mobile com atmosfera wuxia/cultivation: fluxo, ressonancia e ascensao.

const SAVE_PATH: String = "user://fragment_rush_save.json"
const LANES: Array[float] = [-230.0, 0.0, 230.0]
const PLAYER_Y: float = 980.0
const VIEW_W: float = 720.0
const VIEW_H: float = 1280.0

const C_DEEP_SKY: Color = Color(0.027, 0.078, 0.149, 1.0)
const C_DEEP_SKY_2: Color = Color(0.035, 0.120, 0.210, 1.0)
const C_CELESTIAL: Color = Color(0.322, 0.902, 1.0, 1.0)
const C_JADE: Color = Color(0.384, 0.949, 0.706, 1.0)
const C_NEBULA: Color = Color(0.541, 0.361, 1.0, 1.0)
const C_GOLD: Color = Color(1.0, 0.851, 0.502, 1.0)
const C_PEARL: Color = Color(0.918, 0.984, 1.0, 1.0)
const C_PANEL: Color = Color(0.043, 0.133, 0.220, 0.80)

var screen: String = "menu"
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var player: Node2D
var player_glow: Polygon2D
var player_core: Polygon2D
var player_ring: Polygon2D

var hud_layer: CanvasLayer
var menu_layer: CanvasLayer
var result_layer: CanvasLayer
var shop_layer: CanvasLayer
var pause_layer: CanvasLayer
var cultivation_layer: CanvasLayer

var score_label: Label
var crystal_label: Label
var combo_label: Label
var distance_label: Label
var best_label: Label
var hud_best_label: Label
var dash_label: Label
var status_label: Label
var resonance_label: Label
var resonance_bar: ProgressBar

var menu_card: Panel
var result_card: Panel
var shop_card: Panel
var pause_card: Panel
var cultivation_card: Panel

var title_label: Label
var subtitle_label: Label
var start_button: Button
var shop_button: Button
var close_shop_button: Button
var shop_info_label: Label
var daily_button: Button
var cultivation_button: Button
var shop_skin_buttons: Dictionary = {}
var cultivation_info_label: Label
var cultivation_close_button: Button
var cultivation_upgrade_buttons: Dictionary = {}

var result_title: Label
var result_stats: Label
var restart_button: Button
var menu_button: Button

var pause_title: Label
var pause_info_label: Label
var pause_button: Button
var resume_button: Button
var pause_menu_button: Button

var entities: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var qi_particles: Array[Dictionary] = []
var mountains: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var shockwaves: Array[Dictionary] = []
var afterimages: Array[Dictionary] = []

var player_lane: int = 1
var target_x: float = 0.0
var dash_cooldown: float = 0.0
var dash_timer: float = 0.0
var invulnerable_timer: float = 0.0
var magnet_timer: float = 0.0
var slowmo_timer: float = 0.0
var resonance_value: float = 0.0

var distance: float = 0.0
var score: int = 0
var crystals_run: int = 0
var perfect_grazes: int = 0
var combo: int = 0
var best_distance: float = 0.0
var total_crystals: int = 0
var selected_skin: String = "nucleo_errante"
var owned_skins: Dictionary = {"nucleo_errante": true}
var last_daily_reward: String = ""
var run_mission_bonus: int = 0
var completed_run_missions: Array[String] = []
var cultivation_xp: int = 0
var last_xp_gain: int = 0
var technique_levels: Dictionary = {"dash": 0, "jade": 0, "flow": 0}

const SKINS: Dictionary = {
	"nucleo_errante": {"name": "Núcleo Errante", "price": 0, "desc": "Forma inicial equilibrada."},
	"semente_jade": {"name": "Semente de Jade", "price": 1000, "desc": "Cultivo sereno e energia verde."},
	"orbe_celestial": {"name": "Orbe Celestial", "price": 2500, "desc": "Pureza luminosa do céu fragmentado."},
	"coracao_nebular": {"name": "Coração Nebular", "price": 4000, "desc": "Ressonância roxa e misteriosa."},
	"essencia_dourada": {"name": "Essência Dourada", "price": 6500, "desc": "Forma rara de ascensão cristalina."}
}

const TECHNIQUES: Dictionary = {
	"dash": {"name": "Passo Espiritual", "max": 5, "base_price": 650, "desc": "Reduz a recarga do dash."},
	"jade": {"name": "Chamado do Jade", "max": 5, "base_price": 800, "desc": "Aumenta a duração do ímã."},
	"flow": {"name": "Estado de Fluxo", "max": 5, "base_price": 1000, "desc": "Aumenta a duração da ascensão."}
}

const CULTIVATION_STAGES: Array[String] = [
	"Fluxo Inicial",
	"Qi Desperto",
	"Núcleo Refinado",
	"Fluxo Celestial",
	"Ascensão Cristalina"
]

var spawn_timer: float = 0.0
var crystal_spawn_timer: float = 0.0
var power_spawn_timer: float = 5.0
var speed: float = 390.0
var difficulty: float = 0.0

var touch_start: Vector2 = Vector2.ZERO
var is_touching: bool = false
var run_time: float = 0.0
var camera_shake: float = 0.0
var pulse_time: float = 0.0
var flash_alpha: float = 0.0
var combo_pop_timer: float = 0.0
var title_breathe: float = 0.0
var flow_timer: float = 0.0
var flow_activations: int = 0

func _ready() -> void:
	rng.randomize()
	load_save()
	create_background_layers()
	build_game_nodes()
	build_ui()
	show_menu()

func _process(delta: float) -> void:
	var real_delta: float = delta
	var game_delta: float = delta
	if slowmo_timer > 0.0 and screen == "game":
		game_delta *= 0.56
		slowmo_timer -= real_delta
	pulse_time += real_delta
	title_breathe = 1.0 + sin(pulse_time * 1.25) * 0.018
	flash_alpha = maxf(0.0, flash_alpha - real_delta * 2.9)
	combo_pop_timer = maxf(0.0, combo_pop_timer - real_delta * 5.2)
	update_background(real_delta)
	update_particles(real_delta)
	update_impact_fx(real_delta)
	if screen == "game":
		update_game(game_delta, real_delta)
	elif screen != "pause":
		update_menu_motion(real_delta)
	update_screen_shake(real_delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if screen != "game":
		return
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			is_touching = true
			touch_start = touch_event.position
		else:
			is_touching = false
			var swipe_delta: Vector2 = touch_event.position - touch_start
			if absf(swipe_delta.x) > 70.0:
				if swipe_delta.x > 0.0:
					move_lane(1)
				else:
					move_lane(-1)
			elif absf(swipe_delta.y) < 80.0:
				do_dash()
	if event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		var drag_delta: Vector2 = drag_event.position - touch_start
		if absf(drag_delta.x) > 95.0:
			move_lane(1 if drag_delta.x > 0.0 else -1)
			touch_start = drag_event.position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if screen == "game":
			pause_game()
		elif screen == "pause":
			resume_game()
	if screen == "game":
		if event.is_action_pressed("move_left"):
			move_lane(-1)
		if event.is_action_pressed("move_right"):
			move_lane(1)
		if event.is_action_pressed("dash") or event.is_action_pressed("ui_accept"):
			do_dash()

func screen_lane_x(lane: int) -> float:
	var safe_lane: int = clampi(lane, 0, LANES.size() - 1)
	return VIEW_W * 0.5 + LANES[safe_lane]

func build_game_nodes() -> void:
	target_x = screen_lane_x(player_lane)
	player = Node2D.new()
	player.name = "NucleoErrante"
	player.position = Vector2(target_x, PLAYER_Y)
	add_child(player)

	player_ring = Polygon2D.new()
	player_ring.polygon = make_diamond(76.0, 82.0)
	player_ring.color = Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.12)
	player.add_child(player_ring)

	player_glow = Polygon2D.new()
	player_glow.polygon = make_diamond(58.0, 66.0)
	player_glow.color = Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.25)
	player.add_child(player_glow)

	player_core = Polygon2D.new()
	player_core.polygon = make_diamond(35.0, 48.0)
	player_core.color = skin_color(selected_skin)
	player.add_child(player_core)

func make_diamond(width: float, height: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.0, -height),
		Vector2(width, 0.0),
		Vector2(0.0, height),
		Vector2(-width, 0.0)
	])

func build_ui() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	menu_layer = CanvasLayer.new()
	add_child(menu_layer)
	result_layer = CanvasLayer.new()
	add_child(result_layer)
	shop_layer = CanvasLayer.new()
	add_child(shop_layer)
	pause_layer = CanvasLayer.new()
	add_child(pause_layer)
	cultivation_layer = CanvasLayer.new()
	add_child(cultivation_layer)

	# HUD - glassmorphism espiritual
	var hud_left_panel: Panel = make_panel(Vector2(22, 22), Vector2(205, 96), Color(0.03, 0.12, 0.20, 0.72), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.26))
	var hud_center_panel: Panel = make_panel(Vector2(237, 22), Vector2(246, 96), Color(0.03, 0.12, 0.20, 0.76), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.20))
	var hud_right_panel: Panel = make_panel(Vector2(493, 22), Vector2(205, 96), Color(0.03, 0.12, 0.20, 0.72), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.26))
	var resonance_panel: Panel = make_panel(Vector2(22, 130), Vector2(676, 56), Color(0.02, 0.11, 0.17, 0.70), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.22))
	for panel in [hud_left_panel, hud_center_panel, hud_right_panel, resonance_panel]:
		hud_layer.add_child(panel)

	var hud_left_title: Label = make_label("Cristais", 16, Vector2(14, 10), Color(0.73, 0.94, 1.0, 0.90))
	crystal_label = make_label("0", 34, Vector2(14, 24), C_CELESTIAL)
	score_label = make_label("Pontos 0", 16, Vector2(14, 62), Color(0.86, 0.96, 1.0, 0.86))
	hud_left_panel.add_child(hud_left_title)
	hud_left_panel.add_child(crystal_label)
	hud_left_panel.add_child(score_label)

	var hud_center_title: Label = make_label("Marca atual", 16, Vector2(0, 10), Color(0.80, 0.95, 1.0, 0.84))
	hud_center_title.size = Vector2(246, 24)
	hud_center_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label = make_label("0 m", 30, Vector2(0, 24), C_PEARL)
	distance_label.size = Vector2(246, 34)
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_best_label = make_label("Ascensão 0 m", 15, Vector2(0, 62), Color(0.72, 0.90, 1.0, 0.80))
	hud_best_label.size = Vector2(246, 22)
	hud_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_center_panel.add_child(hud_center_title)
	hud_center_panel.add_child(distance_label)
	hud_center_panel.add_child(hud_best_label)

	var hud_right_title: Label = make_label("Fluxo", 16, Vector2(14, 10), Color(0.78, 0.98, 0.90, 0.88))
	combo_label = make_label("x1", 32, Vector2(14, 22), C_GOLD)
	dash_label = make_label("Passo pronto", 16, Vector2(14, 62), Color(0.76, 0.98, 0.86, 0.84))
	hud_right_panel.add_child(hud_right_title)
	hud_right_panel.add_child(combo_label)
	hud_right_panel.add_child(dash_label)

	resonance_label = make_label("Ressonância", 16, Vector2(16, 8), Color(0.86, 0.98, 0.90, 0.90))
	resonance_bar = make_progress_bar(Vector2(16, 28), Vector2(644, 16))
	resonance_panel.add_child(resonance_label)
	resonance_panel.add_child(resonance_bar)

	status_label = make_label("", 28, Vector2(0, 220), C_GOLD)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size = Vector2(VIEW_W, 70)
	hud_layer.add_child(status_label)

	pause_button = make_button("Ⅱ", Vector2(644, 198), Vector2(54, 52))
	pause_button.add_theme_font_size_override("font_size", 22)
	pause_button.pressed.connect(pause_game)
	hud_layer.add_child(pause_button)

	# Menu principal
	menu_card = make_panel(Vector2(48, 150), Vector2(624, 730), Color(0.03, 0.11, 0.19, 0.62), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.22))
	menu_layer.add_child(menu_card)
	title_label = make_label("FRAGMENT RUSH\nCorrida dos Cristais", 44, Vector2(0, 48), C_PEARL)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size = Vector2(624, 118)
	subtitle_label = make_label("Cultive o fluxo. Atravesse o céu fragmentado.", 21, Vector2(58, 182), Color(0.78, 0.95, 1.0, 1.0))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.size = Vector2(508, 60)
	best_label = make_label("", 22, Vector2(0, 260), Color(0.74, 0.92, 1.0, 0.92))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.size = Vector2(624, 56)
	start_button = make_button("INICIAR CORRIDA", Vector2(102, 348), Vector2(420, 82))
	shop_button = make_button("PAVILHÃO DAS FORMAS", Vector2(116, 448), Vector2(392, 68))
	cultivation_button = make_button("NÚCLEO DE CULTIVO", Vector2(116, 532), Vector2(392, 68))
	daily_button = make_button("RECEBER ESSÊNCIA DIÁRIA", Vector2(116, 616), Vector2(392, 66))
	daily_button.add_theme_font_size_override("font_size", 18)
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(show_shop)
	cultivation_button.pressed.connect(show_cultivation)
	daily_button.pressed.connect(claim_daily_reward)
	for node in [title_label, subtitle_label, best_label, start_button, shop_button, cultivation_button, daily_button]:
		menu_card.add_child(node)

	# Resultado
	result_card = make_panel(Vector2(58, 160), Vector2(604, 845), Color(0.03, 0.11, 0.19, 0.68), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.26))
	result_layer.add_child(result_card)
	result_title = make_label("FLUXO INTERROMPIDO", 38, Vector2(0, 48), C_PEARL)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.size = Vector2(604, 70)
	result_stats = make_label("", 18, Vector2(56, 130), Color(0.86, 0.96, 1.0, 1.0))
	result_stats.size = Vector2(492, 475)
	restart_button = make_button("CULTIVAR NOVAMENTE", Vector2(92, 660), Vector2(420, 76))
	menu_button = make_button("VOLTAR À TRILHA", Vector2(132, 758), Vector2(340, 68))
	restart_button.pressed.connect(start_game)
	menu_button.pressed.connect(show_menu)
	for node in [result_title, result_stats, restart_button, menu_button]:
		result_card.add_child(node)

	# Loja/Pavilhão
	shop_card = make_panel(Vector2(48, 110), Vector2(624, 1040), Color(0.03, 0.11, 0.19, 0.68), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.24))
	shop_layer.add_child(shop_card)
	shop_info_label = make_label("", 21, Vector2(40, 34), C_PEARL)
	shop_info_label.size = Vector2(544, 250)
	shop_card.add_child(shop_info_label)

	var skin_order: Array[String] = ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for i in range(skin_order.size()):
		var skin_id: String = skin_order[i]
		var b: Button = make_button("", Vector2(54, 286 + i * 108), Vector2(516, 88))
		b.add_theme_font_size_override("font_size", 18)
		b.pressed.connect(func() -> void: buy_or_select_skin(skin_id))
		shop_skin_buttons[skin_id] = b
		shop_card.add_child(b)

	close_shop_button = make_button("VOLTAR", Vector2(162, 930), Vector2(300, 70))
	close_shop_button.pressed.connect(show_menu)
	shop_card.add_child(close_shop_button)

	# Núcleo de Cultivo
	cultivation_card = make_panel(Vector2(48, 110), Vector2(624, 1040), Color(0.03, 0.11, 0.19, 0.72), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.26))
	cultivation_layer.add_child(cultivation_card)
	cultivation_info_label = make_label("", 21, Vector2(40, 36), C_PEARL)
	cultivation_info_label.size = Vector2(544, 300)
	cultivation_card.add_child(cultivation_info_label)

	var technique_order: Array[String] = ["dash", "jade", "flow"]
	for i in range(technique_order.size()):
		var tech_id: String = technique_order[i]
		var tb: Button = make_button("", Vector2(54, 380 + i * 126), Vector2(516, 96))
		tb.add_theme_font_size_override("font_size", 18)
		tb.pressed.connect(func() -> void: upgrade_technique(tech_id))
		cultivation_upgrade_buttons[tech_id] = tb
		cultivation_card.add_child(tb)

	cultivation_close_button = make_button("VOLTAR", Vector2(162, 930), Vector2(300, 70))
	cultivation_close_button.pressed.connect(show_menu)
	cultivation_card.add_child(cultivation_close_button)

	# Tela de pausa
	pause_card = make_panel(Vector2(72, 305), Vector2(576, 515), Color(0.03, 0.11, 0.19, 0.76), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.30))
	pause_layer.add_child(pause_card)
	pause_title = make_label("FLUXO PAUSADO", 38, Vector2(0, 48), C_PEARL)
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_title.size = Vector2(576, 72)
	pause_info_label = make_label("Respire.\nA trilha continua quando você voltar.", 22, Vector2(56, 144), Color(0.82, 0.96, 1.0, 0.92))
	pause_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_info_label.size = Vector2(464, 96)
	resume_button = make_button("CONTINUAR", Vector2(88, 284), Vector2(400, 76))
	pause_menu_button = make_button("VOLTAR AO MENU", Vector2(108, 382), Vector2(360, 68))
	resume_button.pressed.connect(resume_game)
	pause_menu_button.pressed.connect(show_menu)
	for node in [pause_title, pause_info_label, resume_button, pause_menu_button]:
		pause_card.add_child(node)
	pause_layer.visible = false

func make_panel(pos: Vector2, size_panel: Vector2, bg: Color, border: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = pos
	panel.size = size_panel
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(26)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", style)
	return panel

func make_progress_bar(pos: Vector2, size_bar: Vector2) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.position = pos
	bar.size = size_bar
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 0.0
	bar.show_percentage = false
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.04, 0.10, 0.16, 0.92)
	bg_style.set_corner_radius_all(12)
	bg_style.border_color = Color(1.0, 1.0, 1.0, 0.08)
	bg_style.set_border_width_all(1)
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = C_JADE
	fill_style.set_corner_radius_all(12)
	fill_style.border_color = Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.18)
	fill_style.set_border_width_all(1)
	bar.add_theme_stylebox_override("background", bg_style)
	bar.add_theme_stylebox_override("fill", fill_style)
	return bar

func make_label(text: String, size_font: int, pos: Vector2, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", size_font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.18))
	label.add_theme_constant_override("outline_size", 1)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label
func make_button(text: String, pos: Vector2, size_btn: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.position = pos
	button.size = size_btn
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", C_PEARL)
	button.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.16, 0.25, 0.78), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.40)))
	button.add_theme_stylebox_override("hover", make_button_style(Color(0.07, 0.22, 0.34, 0.92), C_JADE))
	button.add_theme_stylebox_override("pressed", make_button_style(Color(0.03, 0.16, 0.24, 0.95), C_GOLD))
	return button

func make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 18
	style.set_content_margin(SIDE_TOP, 8.0)
	style.set_content_margin(SIDE_BOTTOM, 8.0)
	style.set_content_margin(SIDE_LEFT, 18.0)
	style.set_content_margin(SIDE_RIGHT, 18.0)
	return style

func create_background_layers() -> void:
	stars.clear()
	qi_particles.clear()
	mountains.clear()
	for _i in range(90):
		var star: Dictionary = {
			"pos": Vector2(rng.randf_range(0.0, VIEW_W), rng.randf_range(0.0, VIEW_H)),
			"speed": rng.randf_range(12.0, 72.0),
			"size": rng.randf_range(1.0, 3.3),
			"alpha": rng.randf_range(0.18, 0.75)
		}
		stars.append(star)
	for _i in range(45):
		var qi: Dictionary = {
			"pos": Vector2(rng.randf_range(-80.0, VIEW_W + 80.0), rng.randf_range(0.0, VIEW_H)),
			"speed": rng.randf_range(10.0, 38.0),
			"drift": rng.randf_range(-14.0, 14.0),
			"size": rng.randf_range(2.0, 7.0),
			"alpha": rng.randf_range(0.08, 0.28)
		}
		qi_particles.append(qi)
	for i in range(9):
		var layer: float = float(i % 3)
		var mountain: Dictionary = {
			"x": rng.randf_range(-80.0, VIEW_W + 60.0),
			"y": rng.randf_range(170.0, 860.0),
			"w": rng.randf_range(120.0, 260.0),
			"h": rng.randf_range(35.0, 92.0),
			"speed": 8.0 + layer * 12.0,
			"alpha": 0.08 + layer * 0.035
		}
		mountains.append(mountain)

func update_background(delta: float) -> void:
	var speed_factor: float = 1.0 if screen == "game" else 0.26
	for i in range(stars.size()):
		var star: Dictionary = stars[i]
		var pos: Vector2 = star["pos"]
		pos.y += float(star["speed"]) * delta * speed_factor
		if pos.y > VIEW_H + 10.0:
			pos = Vector2(rng.randf_range(0.0, VIEW_W), -10.0)
		star["pos"] = pos
		stars[i] = star
	for i in range(qi_particles.size()):
		var qi: Dictionary = qi_particles[i]
		var qi_pos: Vector2 = qi["pos"]
		qi_pos.y += float(qi["speed"]) * delta * speed_factor
		qi_pos.x += float(qi["drift"]) * delta
		if qi_pos.y > VIEW_H + 20.0:
			qi_pos = Vector2(rng.randf_range(-80.0, VIEW_W + 80.0), -20.0)
		qi["pos"] = qi_pos
		qi_particles[i] = qi
	for i in range(mountains.size()):
		var mountain: Dictionary = mountains[i]
		var y: float = float(mountain["y"]) + float(mountain["speed"]) * delta * speed_factor
		if y > VIEW_H + 120.0:
			y = -120.0
			mountain["x"] = rng.randf_range(-90.0, VIEW_W + 80.0)
		mountain["y"] = y
		mountains[i] = mountain

func update_menu_motion(delta: float) -> void:
	if player == null:
		return
	var menu_x: float = VIEW_W * 0.5 + sin(pulse_time * 0.45) * 18.0
	var menu_y: float = 930.0 + sin(pulse_time * 0.8) * 12.0
	player.position = player.position.lerp(Vector2(menu_x, menu_y), minf(1.0, 2.0 * delta))
	player.rotation += delta * 0.25
	player.scale = Vector2.ONE * (1.0 + sin(pulse_time * 2.2) * 0.045)
	player_core.color = skin_color(selected_skin)
	player_glow.color = Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.24 + 0.07 * sin(pulse_time * 2.0))
	player_ring.color = Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.10 + 0.05 * sin(pulse_time * 1.4))
	if title_label != null and screen == "menu":
		title_label.scale = Vector2.ONE * title_breathe
	if menu_card != null and screen == "menu":
		menu_card.modulate.a = 0.94 + sin(pulse_time * 1.1) * 0.035

func update_screen_shake(delta: float) -> void:
	if camera_shake > 0.05:
		position = Vector2(rng.randf_range(-camera_shake, camera_shake), rng.randf_range(-camera_shake, camera_shake))
		camera_shake = maxf(0.0, camera_shake - delta * 36.0)
	else:
		position = Vector2.ZERO
		camera_shake = 0.0

func start_game() -> void:
	screen = "game"
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	hud_layer.visible = true
	entities.clear()
	particles.clear()
	shockwaves.clear()
	afterimages.clear()
	flash_alpha = 0.0
	combo_pop_timer = 0.0
	flow_timer = 0.0
	flow_activations = 0
	run_mission_bonus = 0
	completed_run_missions.clear()
	player_lane = 1
	target_x = screen_lane_x(player_lane)
	player.position = Vector2(target_x, PLAYER_Y)
	player.rotation = 0.0
	player.scale = Vector2.ONE
	player_core.color = skin_color(selected_skin)
	distance = 0.0
	score = 0
	crystals_run = 0
	perfect_grazes = 0
	combo = 0
	resonance_value = 0.0
	spawn_timer = 0.25
	crystal_spawn_timer = 0.2
	power_spawn_timer = 5.0
	speed = 390.0
	difficulty = 0.0
	dash_cooldown = 0.0
	dash_timer = 0.0
	invulnerable_timer = 0.0
	magnet_timer = 0.0
	slowmo_timer = 0.0
	status_label.text = ""
	status_label.modulate.a = 1.0
	update_hud()
	show_status("A trilha está aberta", C_JADE)

func show_menu() -> void:
	screen = "menu"
	menu_layer.visible = true
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	hud_layer.visible = false
	best_label.text = "%s  •  XP %d\nMarca: %d m  •  Cristais: %d" % [get_cultivation_stage_name(), cultivation_xp, int(best_distance), total_crystals]
	update_daily_button()

func pause_game() -> void:
	if screen != "game":
		return
	screen = "pause"
	hud_layer.visible = false
	pause_layer.visible = true
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	cultivation_layer.visible = false

func resume_game() -> void:
	if screen != "pause":
		return
	screen = "game"
	hud_layer.visible = true
	pause_layer.visible = false

func activate_flow_state() -> void:
	flow_timer = 5.8 + float(tech_level("flow")) * 0.45
	flow_activations += 1
	resonance_value = 100.0
	invulnerable_timer = maxf(invulnerable_timer, 1.2)
	flash_alpha = maxf(flash_alpha, 0.20)
	camera_shake = maxf(camera_shake, 8.0)
	combo_pop_timer = 1.0
	spawn_afterimage(player.position, C_GOLD, 0.55)
	spawn_shockwave(player.position, C_GOLD, 48.0, 260.0, 0.72)
	show_status("ESTADO DE FLUXO", C_GOLD)
	for _i in range(28):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-72.0, 72.0), rng.randf_range(-64.0, 64.0))
		spawn_particle(particle_pos, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.82), 7, 0.58)

func show_cultivation() -> void:
	screen = "cultivation"
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = true
	hud_layer.visible = false
	update_cultivation_ui()

func get_cultivation_stage_index() -> int:
	if cultivation_xp >= 6000:
		return 4
	if cultivation_xp >= 3000:
		return 3
	if cultivation_xp >= 1400:
		return 2
	if cultivation_xp >= 500:
		return 1
	return 0

func get_cultivation_stage_name() -> String:
	return CULTIVATION_STAGES[get_cultivation_stage_index()]

func next_stage_xp() -> int:
	var idx: int = get_cultivation_stage_index()
	match idx:
		0:
			return 500
		1:
			return 1400
		2:
			return 3000
		3:
			return 6000
		_:
			return cultivation_xp

func tech_level(tech_id: String) -> int:
	return int(technique_levels.get(tech_id, 0))

func technique_price(tech_id: String) -> int:
	var data: Dictionary = TECHNIQUES[tech_id]
	var level: int = tech_level(tech_id)
	return int(data["base_price"]) + level * 550

func update_cultivation_ui() -> void:
	var next_xp: int = next_stage_xp()
	var progress_line: String = "Estágio máximo alcançado"
	if next_xp > cultivation_xp:
		progress_line = "Próximo estágio: %d XP" % next_xp
	var lines: Array[String] = []
	lines.append("NÚCLEO DE CULTIVO")
	lines.append("")
	lines.append("Estágio: %s" % get_cultivation_stage_name())
	lines.append("XP de Cultivo: %d" % cultivation_xp)
	lines.append(progress_line)
	lines.append("")
	lines.append("Cristais Espirituais: %d" % total_crystals)
	lines.append("Aprimore técnicas para tornar cada corrida mais fluida.")
	cultivation_info_label.text = "\n".join(lines)

	for tech_id in cultivation_upgrade_buttons.keys():
		var b: Button = cultivation_upgrade_buttons[tech_id]
		var data: Dictionary = TECHNIQUES[tech_id]
		var level: int = tech_level(tech_id)
		var max_level: int = int(data["max"])
		var price: int = technique_price(tech_id)
		var status: String = "Nível %d/%d" % [level, max_level]
		if level >= max_level:
			status = "Nível máximo"
		var action: String = "MAX" if level >= max_level else "%d cristais" % price
		b.text = "%s  •  %s\n%s  •  %s" % [str(data["name"]), status, str(data["desc"]), action]
		if level >= max_level:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.10, 0.23, 0.22, 0.86), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.62)))
		else:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.16, 0.25, 0.78), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.40)))

func upgrade_technique(tech_id: String) -> void:
	if not TECHNIQUES.has(tech_id):
		return
	var data: Dictionary = TECHNIQUES[tech_id]
	var level: int = tech_level(tech_id)
	var max_level: int = int(data["max"])
	if level >= max_level:
		show_status("TÉCNICA NO MÁXIMO", C_GOLD)
		return
	var price: int = technique_price(tech_id)
	if total_crystals < price:
		show_status("CRISTAIS INSUFICIENTES", Color(1.0, 0.72, 0.72, 1.0))
		flash_alpha = maxf(flash_alpha, 0.07)
		return
	total_crystals -= price
	technique_levels[tech_id] = level + 1
	save_game()
	update_cultivation_ui()
	show_status("TÉCNICA APRIMORADA", C_GOLD)
	spawn_shockwave(player.position, C_GOLD, 38.0, 220.0, 0.58)

func show_shop() -> void:
	screen = "shop"
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = true
	pause_layer.visible = false
	cultivation_layer.visible = false
	hud_layer.visible = false
	update_shop_ui()

func update_shop_ui() -> void:
	var selected_name: String = str(SKINS.get(selected_skin, {}).get("name", "Núcleo Errante"))
	var lines: Array[String] = []
	lines.append("PAVILHÃO DAS FORMAS")
	lines.append("")
	lines.append("Cristais Espirituais: %d" % total_crystals)
	lines.append("Forma atual: %s" % selected_name)
	lines.append("")
	lines.append("Escolha, compre e cultive novas formas.")
	shop_info_label.text = "\n".join(lines)

	for skin_id in shop_skin_buttons.keys():
		var b: Button = shop_skin_buttons[skin_id]
		var data: Dictionary = SKINS[skin_id]
		var skin_name: String = str(data["name"])
		var price: int = int(data["price"])
		var owned: bool = bool(owned_skins.get(skin_id, false))
		var selected: bool = skin_id == selected_skin
		var suffix: String = ""
		if selected:
			suffix = "  •  EQUIPADO"
		elif owned:
			suffix = "  •  USAR"
		else:
			suffix = "  •  %d cristais" % price
		b.text = "%s\n%s" % [skin_name + suffix, str(data["desc"])]
		if selected:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.10, 0.23, 0.22, 0.86), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.62)))
		elif owned:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.18, 0.24, 0.82), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.48)))
		else:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.04, 0.12, 0.20, 0.76), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.28)))

func buy_or_select_skin(skin_id: String) -> void:
	if not SKINS.has(skin_id):
		return
	var data: Dictionary = SKINS[skin_id]
	var owned: bool = bool(owned_skins.get(skin_id, false))
	if owned:
		selected_skin = skin_id
		player_core.color = skin_color(selected_skin)
		save_game()
		update_shop_ui()
		show_status("FORMA SINTONIZADA", C_JADE)
		return

	var price: int = int(data["price"])
	if total_crystals >= price:
		total_crystals -= price
		owned_skins[skin_id] = true
		selected_skin = skin_id
		player_core.color = skin_color(selected_skin)
		save_game()
		update_shop_ui()
		show_status("NOVA FORMA DESPERTA", C_GOLD)
		spawn_shockwave(player.position, C_GOLD, 45.0, 230.0, 0.64)
	else:
		show_status("CRISTAIS INSUFICIENTES", Color(1.0, 0.72, 0.72, 1.0))
		flash_alpha = maxf(flash_alpha, 0.07)

func current_day_key() -> String:
	var date: Dictionary = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(date["year"]), int(date["month"]), int(date["day"])]

func update_daily_button() -> void:
	if daily_button == null:
		return
	var today: String = current_day_key()
	if last_daily_reward == today:
		daily_button.text = "ESSÊNCIA DIÁRIA RECEBIDA"
		daily_button.disabled = true
	else:
		daily_button.text = "RECEBER ESSÊNCIA DIÁRIA"
		daily_button.disabled = false

func claim_daily_reward() -> void:
	var today: String = current_day_key()
	if last_daily_reward == today:
		update_daily_button()
		return
	last_daily_reward = today
	total_crystals += 180
	save_game()
	update_daily_button()
	best_label.text = "Marca de Ascensão: %d m\nCristais Espirituais: %d" % [int(best_distance), total_crystals]
	show_status("+180 ESSÊNCIA DIÁRIA", C_GOLD)
	spawn_shockwave(player.position, C_GOLD, 40.0, 250.0, 0.65)

func update_game(delta: float, real_delta: float) -> void:
	run_time += real_delta
	difficulty += real_delta * 0.018
	speed = minf(820.0, 390.0 + distance * 0.03 + difficulty * 42.0)
	distance += speed * delta * 0.045
	var flow_multiplier: float = 1.65 if flow_timer > 0.0 else 1.0
	score += int(14.0 * delta * (1.0 + float(combo) * 0.08) * flow_multiplier)
	if flow_timer > 0.0:
		flow_timer = maxf(0.0, flow_timer - real_delta)
		invulnerable_timer = maxf(invulnerable_timer, 0.08)
		resonance_value = maxf(0.0, resonance_value - real_delta * 8.0)
		if rng.randf() < 0.38:
			spawn_afterimage(player.position, C_JADE, 0.25)
	else:
		resonance_value = maxf(0.0, resonance_value - real_delta * 2.5)
	if resonance_value >= 100.0 and flow_timer <= 0.0:
		activate_flow_state()
	if dash_cooldown > 0.0:
		dash_cooldown -= real_delta
	if dash_timer > 0.0:
		dash_timer -= real_delta
	if invulnerable_timer > 0.0:
		invulnerable_timer -= real_delta
	if magnet_timer > 0.0:
		magnet_timer -= real_delta

	player.position.x = lerpf(player.position.x, target_x, minf(1.0, 14.0 * real_delta))
	player.rotation = lerpf(player.rotation, (target_x - player.position.x) * 0.003, 8.0 * real_delta)
	var dash_scale: float = 0.14 if dash_timer > 0.0 else 0.0
	var flow_scale: float = 0.08 if flow_timer > 0.0 else 0.0
	player.scale = Vector2.ONE * (1.0 + sin(run_time * 9.0) * 0.025 + dash_scale + flow_scale)
	player_core.color = skin_color(selected_skin)
	player_glow.color = Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.22 + clampf(resonance_value / 100.0, 0.0, 0.18))
	player_ring.color = Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.10 + clampf(resonance_value / 120.0, 0.0, 0.20))
	if dash_timer > 0.0:
		spawn_particle(player.position, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.82), 9, 0.42)
		if rng.randf() < 0.55:
			spawn_afterimage(player.position, player_core.color, 0.30)
	if flow_timer > 0.0 and rng.randf() < 0.50:
		spawn_particle(player.position + Vector2(rng.randf_range(-68.0, 68.0), rng.randf_range(-24.0, 62.0)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.46), 3, 0.36)
	if speed > 560.0 and rng.randf() < 0.08:
		spawn_particle(player.position + Vector2(rng.randf_range(-42.0, 42.0), rng.randf_range(26.0, 72.0)), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.34), 2, 0.28)

	spawn_timer -= delta
	crystal_spawn_timer -= delta
	power_spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_obstacle_pattern()
		spawn_timer = maxf(0.38, 1.05 - difficulty * 0.025 - distance * 0.0008)
	if crystal_spawn_timer <= 0.0:
		spawn_crystal_line()
		crystal_spawn_timer = rng.randf_range(0.35, 0.72)
	if power_spawn_timer <= 0.0:
		spawn_powerup()
		power_spawn_timer = rng.randf_range(7.0, 12.0)

	update_entities(delta)
	update_hud()

func update_hud() -> void:
	score_label.text = "Pontos %d" % score
	crystal_label.text = str(crystals_run)
	distance_label.text = "%d m" % int(distance)
	hud_best_label.text = "Ascensão %d m" % int(best_distance)
	combo_label.text = "x%d" % max(combo, 1)
	var dash_ready: bool = dash_cooldown <= 0.0
	if flow_timer > 0.0:
		dash_label.text = "Fluxo %.1fs" % flow_timer
		dash_label.add_theme_color_override("font_color", C_GOLD)
		resonance_label.text = "Estado de Fluxo  %.1fs" % flow_timer
		resonance_bar.value = 100.0
	else:
		dash_label.text = "Passo pronto" if dash_ready else "Recarga %.1fs" % maxf(dash_cooldown, 0.0)
		dash_label.add_theme_color_override("font_color", C_JADE if dash_ready else Color(0.78, 0.92, 1.0, 0.78))
		resonance_label.text = "Ressonância  %d%%" % int(clampf(resonance_value, 0.0, 100.0))
		resonance_bar.value = clampf(resonance_value, 0.0, 100.0)
	if combo >= 2:
		combo_label.add_theme_color_override("font_color", C_GOLD)
	else:
		combo_label.add_theme_color_override("font_color", Color(0.76, 0.92, 0.84, 0.72))
	combo_label.scale = Vector2.ONE * (1.0 + combo_pop_timer * 0.08)
	resonance_bar.modulate.a = 0.86 + clampf(resonance_value / 100.0, 0.0, 0.14)

func move_lane(dir: int) -> void:
	var previous_lane: int = player_lane
	player_lane = clampi(player_lane + dir, 0, LANES.size() - 1)
	target_x = screen_lane_x(player_lane)
	if previous_lane != player_lane:
		spawn_afterimage(player.position, C_CELESTIAL, 0.28)
	camera_shake = maxf(camera_shake, 2.0)

func do_dash() -> void:
	if dash_cooldown <= 0.0:
		dash_timer = 0.18
		dash_cooldown = maxf(0.72, 1.15 - float(tech_level("dash")) * 0.08)
		invulnerable_timer = maxf(invulnerable_timer, 0.2)
		resonance_value = minf(100.0, resonance_value + 4.0)
		flash_alpha = maxf(flash_alpha, 0.10)
		spawn_afterimage(player.position, C_JADE, 0.45)
		spawn_shockwave(player.position, C_JADE, 18.0, 120.0, 0.38)
		show_status("PASSO ESPIRITUAL", C_JADE)
		for _i in range(15):
			var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-38.0, 38.0), rng.randf_range(-38.0, 38.0))
			spawn_particle(particle_pos, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.80), 7, 0.55)

func spawn_obstacle_pattern() -> void:
	var pattern: int = rng.randi_range(0, 4)
	if pattern == 0:
		spawn_obstacle(rng.randi_range(0, 2), "fragmento_caido")
	elif pattern == 1:
		var safe: int = rng.randi_range(0, 2)
		for lane in range(3):
			if lane != safe:
				spawn_obstacle(lane, "espinho_cristal")
	elif pattern == 2:
		spawn_obstacle(0, "selo_instavel")
		spawn_obstacle(2, "selo_instavel")
	elif pattern == 3:
		spawn_obstacle(rng.randi_range(0, 2), "ruptura_celestial")
	else:
		spawn_obstacle(rng.randi_range(0, 2), "fragmento_caido")
		spawn_obstacle(rng.randi_range(0, 2), "espinho_cristal")

func spawn_obstacle(lane: int, kind: String) -> void:
	var safe_lane: int = clampi(lane, 0, LANES.size() - 1)
	var obstacle: Dictionary = {
		"type": "obstacle",
		"kind": kind,
		"lane": safe_lane,
		"pos": Vector2(screen_lane_x(safe_lane), -90.0),
		"radius": 52.0,
		"scored_graze": false,
		"rot": rng.randf_range(-1.0, 1.0)
	}
	entities.append(obstacle)

func spawn_crystal_line() -> void:
	var lane: int = rng.randi_range(0, 2)
	var count: int = rng.randi_range(3, 6)
	for i in range(count):
		var crystal: Dictionary = {
			"type": "crystal",
			"kind": "espiritual",
			"lane": lane,
			"pos": Vector2(screen_lane_x(lane), -80.0 - float(i) * 72.0),
			"radius": 28.0,
			"value": 1,
			"rot": rng.randf_range(0.0, TAU)
		}
		entities.append(crystal)

func spawn_powerup() -> void:
	var kinds: Array[String] = ["magnet", "shield", "slowmo", "double"]
	var lane: int = rng.randi_range(0, 2)
	var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
	var power: Dictionary = {
		"type": "power",
		"kind": kind,
		"lane": lane,
		"pos": Vector2(screen_lane_x(lane), -100.0),
		"radius": 34.0,
		"rot": 0.0
	}
	entities.append(power)

func update_entities(delta: float) -> void:
	var remove_indices: Array[int] = []
	for i in range(entities.size()):
		var e: Dictionary = entities[i]
		var entity_type: String = str(e.get("type", ""))
		var pos: Vector2 = e["pos"]
		pos.y += speed * delta
		e["pos"] = pos

		var rot: float = float(e.get("rot", 0.0)) + delta * 3.2
		e["rot"] = rot

		var dist_to_player: float = pos.distance_to(player.position)
		if entity_type == "crystal":
			if magnet_timer > 0.0 and dist_to_player < 220.0:
				pos = pos.lerp(player.position, 8.0 * delta)
				e["pos"] = pos
				dist_to_player = pos.distance_to(player.position)
			if dist_to_player < 58.0:
				collect_crystal(e)
				remove_indices.append(i)
		elif entity_type == "power":
			if dist_to_player < 62.0:
				collect_power(str(e.get("kind", "")))
				remove_indices.append(i)
		elif entity_type == "obstacle":
			if dist_to_player < 66.0 and invulnerable_timer <= 0.0:
				game_over()
				return
			elif dist_to_player < 118.0 and not bool(e.get("scored_graze", false)) and absf(pos.y - player.position.y) < 70.0:
				e["scored_graze"] = true
				perfect_graze()
		if pos.y > VIEW_H + 150.0:
			remove_indices.append(i)
		entities[i] = e
	remove_indices.sort()
	remove_indices.reverse()
	for idx in remove_indices:
		if idx >= 0 and idx < entities.size():
			entities.remove_at(idx)

func collect_crystal(e: Dictionary) -> void:
	var multiplier: int = 2 if combo >= 8 else 1
	if flow_timer > 0.0:
		multiplier += 1
	var value: int = int(e.get("value", 1))
	crystals_run += value * multiplier
	score += 30 * multiplier
	combo += 1
	combo_pop_timer = 1.0
	resonance_value = minf(100.0, resonance_value + 0.8)
	var crystal_pos: Vector2 = e["pos"]
	spawn_particle(crystal_pos, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.85), 13, 0.5)
	if combo % 10 == 0:
		spawn_shockwave(player.position, C_GOLD, 22.0, 118.0, 0.46)
		show_status("Fluxo x%d" % combo, C_GOLD)

func collect_power(kind: String) -> void:
	match kind:
		"magnet":
			magnet_timer = 6.0 + float(tech_level("jade")) * 0.65
			show_status("CHAMADO DO JADE", C_JADE)
		"shield":
			invulnerable_timer = 5.0
			show_status("SELO PROTETOR", Color(0.70, 0.86, 1.0, 1.0))
		"slowmo":
			slowmo_timer = 3.0
			show_status("SILÊNCIO CELESTIAL", C_NEBULA)
		"double":
			combo += 5
			show_status("FLUXO ELEVADO", C_GOLD)
	resonance_value = minf(100.0, resonance_value + 8.0)
	flash_alpha = maxf(flash_alpha, 0.12)
	spawn_shockwave(player.position, C_JADE, 24.0, 150.0, 0.56)
	spawn_particle(player.position, Color(1.0, 1.0, 1.0, 0.75), 22, 0.7)

func perfect_graze() -> void:
	perfect_grazes += 1
	combo += 2
	var bonus: int = 90 + combo * 5
	score += bonus
	combo_pop_timer = 1.0
	resonance_value = minf(100.0, resonance_value + 13.0)
	camera_shake = 10.0
	flash_alpha = maxf(flash_alpha, 0.18)
	spawn_afterimage(player.position, C_GOLD, 0.45)
	spawn_shockwave(player.position, C_GOLD, 36.0, 230.0, 0.62)
	show_status("RESSONÂNCIA PERFEITA +%d" % bonus, C_GOLD)
	for _i in range(22):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-46.0, 46.0), rng.randf_range(-46.0, 46.0))
		spawn_particle(particle_pos, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.86), 8, 0.45)

func calculate_run_missions() -> Array[String]:
	var missions: Array[String] = []
	if int(distance) >= 500:
		missions.append("✓ Atravessou 500m da Trilha")
	if crystals_run >= 60:
		missions.append("✓ Coletou 60 Cristais Espirituais")
	if perfect_grazes >= 5:
		missions.append("✓ Alcançou 5 Ressonâncias Perfeitas")
	if flow_activations >= 1:
		missions.append("✓ Entrou em Estado de Fluxo")
	if combo >= 18:
		missions.append("✓ Sustentou Fluxo x18")
	return missions

func calculate_xp_gain() -> int:
	var gain: int = int(distance * 0.06)
	gain += perfect_grazes * 9
	gain += flow_activations * 24
	gain += completed_run_missions.size() * 18
	gain += int(max(combo, 1) * 0.8)
	return max(gain, 8)

func game_over() -> void:
	screen = "result"
	completed_run_missions = calculate_run_missions()
	run_mission_bonus = completed_run_missions.size() * 75
	last_xp_gain = calculate_xp_gain()
	cultivation_xp += last_xp_gain
	total_crystals += crystals_run + run_mission_bonus
	best_distance = maxf(best_distance, distance)
	save_game()
	hud_layer.visible = false
	result_layer.visible = true
	menu_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	var new_mark: String = "\nNova Marca de Ascensão!" if int(distance) >= int(best_distance) else ""
	var mission_text: String = "Nenhuma missão concluída"
	if completed_run_missions.size() > 0:
		mission_text = "\n".join(completed_run_missions)
	result_stats.text = "Distância: %d m\nPontuação: %d\nCristais da Corrida: %d\nBônus de Missões: +%d\nXP de Cultivo: +%d\nRessonâncias Perfeitas: %d\nEstados de Fluxo: %d\nMaior Fluxo: x%d\n%s\n\nMissões:\n%s\n\nEstágio: %s\nTotal de Cristais: %d\nMarca de Ascensão: %d m" % [int(distance), score, crystals_run, run_mission_bonus, last_xp_gain, perfect_grazes, flow_activations, max(combo, 1), new_mark, mission_text, get_cultivation_stage_name(), total_crystals, int(best_distance)]
	camera_shake = 17.0

func show_status(text: String, color: Color) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
	var tween: Tween = create_tween()
	status_label.modulate.a = 1.0
	status_label.scale = Vector2.ONE * 1.12
	status_label.position = Vector2(0, 218)
	tween.tween_property(status_label, "scale", Vector2.ONE, 0.20)
	tween.parallel().tween_property(status_label, "position:y", 198.0, 0.22)
	tween.tween_property(status_label, "modulate:a", 0.0, 0.92).set_delay(0.35)

func spawn_particle(pos: Vector2, color: Color, amount: int, lifetime: float) -> void:
	for _i in range(amount):
		var particle: Dictionary = {
			"pos": pos,
			"vel": Vector2(rng.randf_range(-160.0, 160.0), rng.randf_range(-220.0, 80.0)),
			"color": color,
			"life": lifetime,
			"max": lifetime,
			"size": rng.randf_range(3.0, 9.0)
		}
		particles.append(particle)

func update_particles(delta: float) -> void:
	var remove: Array[int] = []
	for i in range(particles.size()):
		var p: Dictionary = particles[i]
		var life: float = float(p["life"]) - delta
		var pos: Vector2 = p["pos"]
		var vel: Vector2 = p["vel"]
		pos += vel * delta
		vel *= 0.94
		p["life"] = life
		p["pos"] = pos
		p["vel"] = vel
		particles[i] = p
		if life <= 0.0:
			remove.append(i)
	remove.reverse()
	for idx in remove:
		particles.remove_at(idx)

func update_impact_fx(delta: float) -> void:
	var remove_shockwaves: Array[int] = []
	for i in range(shockwaves.size()):
		var s: Dictionary = shockwaves[i]
		var age: float = float(s["age"]) + delta
		var duration: float = float(s["duration"])
		s["age"] = age
		shockwaves[i] = s
		if age >= duration:
			remove_shockwaves.append(i)
	remove_shockwaves.reverse()
	for idx in remove_shockwaves:
		shockwaves.remove_at(idx)

	var remove_afterimages: Array[int] = []
	for i in range(afterimages.size()):
		var a: Dictionary = afterimages[i]
		var age: float = float(a["age"]) + delta
		var duration: float = float(a["duration"])
		a["age"] = age
		afterimages[i] = a
		if age >= duration:
			remove_afterimages.append(i)
	remove_afterimages.reverse()
	for idx in remove_afterimages:
		afterimages.remove_at(idx)

func spawn_shockwave(pos: Vector2, color: Color, start_radius: float, end_radius: float, duration: float) -> void:
	var shockwave: Dictionary = {
		"pos": pos,
		"color": color,
		"start": start_radius,
		"end": end_radius,
		"duration": duration,
		"age": 0.0
	}
	shockwaves.append(shockwave)

func spawn_afterimage(pos: Vector2, color: Color, duration: float) -> void:
	var afterimage: Dictionary = {
		"pos": pos,
		"color": color,
		"duration": duration,
		"age": 0.0,
		"rot": player.rotation,
		"scale": player.scale.x
	}
	afterimages.append(afterimage)
	if afterimages.size() > 16:
		afterimages.remove_at(0)

func skin_color(skin: String) -> Color:
	match skin:
		"semente_jade":
			return C_JADE
		"orbe_celestial":
			return Color(0.90, 0.98, 1.0, 1.0)
		"coracao_nebular":
			return C_NEBULA
		"essencia_dourada":
			return C_GOLD
		"nucleo_vazio":
			return Color(0.16, 0.09, 0.31, 1.0)
		_:
			return C_CELESTIAL

func save_game() -> void:
	var data: Dictionary = {
		"best_distance": best_distance,
		"total_crystals": total_crystals,
		"selected_skin": selected_skin,
		"owned_skins": owned_skins,
		"last_daily_reward": last_daily_reward,
		"cultivation_xp": cultivation_xp,
		"technique_levels": technique_levels
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file != null:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			best_distance = float(parsed.get("best_distance", 0.0))
			total_crystals = int(parsed.get("total_crystals", 0))
			selected_skin = str(parsed.get("selected_skin", "nucleo_errante"))
			last_daily_reward = str(parsed.get("last_daily_reward", ""))
			cultivation_xp = int(parsed.get("cultivation_xp", 0))
			var loaded_techniques: Variant = parsed.get("technique_levels", {"dash": 0, "jade": 0, "flow": 0})
			if typeof(loaded_techniques) == TYPE_DICTIONARY:
				technique_levels = loaded_techniques
			for required_tech in ["dash", "jade", "flow"]:
				if not technique_levels.has(required_tech):
					technique_levels[required_tech] = 0
			var loaded_skins: Variant = parsed.get("owned_skins", {"nucleo_errante": true})
			if typeof(loaded_skins) == TYPE_DICTIONARY:
				owned_skins = loaded_skins
			owned_skins["nucleo_errante"] = true
			if not bool(owned_skins.get(selected_skin, false)):
				selected_skin = "nucleo_errante"

func _draw() -> void:
	draw_cultivation_background()
	draw_premium_menu_glow()
	draw_spiritual_lanes()
	draw_speed_lines()
	draw_afterimages()
	draw_entities()
	draw_particles()
	draw_shockwaves()
	draw_player_aura()
	draw_flash_overlay()

func draw_premium_menu_glow() -> void:
	if screen != "menu":
		return
	var center: Vector2 = Vector2(VIEW_W * 0.5, 500.0)
	var glow_a: float = 0.06 + 0.025 * sin(pulse_time * 1.1)
	draw_circle(center, 330.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, glow_a))
	draw_circle(center + Vector2(0.0, 15.0), 210.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, glow_a * 0.72))
	for i in range(4):
		var radius: float = 170.0 + float(i) * 42.0 + sin(pulse_time * 0.9 + float(i)) * 4.0
		var alpha: float = 0.035 - float(i) * 0.005
		draw_arc(center, radius, pulse_time * 0.10 + float(i), PI * 1.45 + pulse_time * 0.10 + float(i), 92, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, alpha), 2.0, true)

func draw_speed_lines() -> void:
	if screen != "game":
		return
	var speed_factor: float = clampf((speed - 390.0) / 430.0, 0.0, 1.0)
	if speed_factor <= 0.02 and dash_timer <= 0.0 and flow_timer <= 0.0:
		return
	var flow_boost: float = 0.10 if flow_timer > 0.0 else 0.0
	var alpha: float = 0.055 + speed_factor * 0.08 + flow_boost
	for i in range(14):
		var x: float = rng.randf_range(36.0, VIEW_W - 36.0)
		var y: float = fmod(pulse_time * (330.0 + speed * 0.16) + float(i) * 96.0, VIEW_H + 120.0) - 80.0
		var length: float = 34.0 + speed_factor * 78.0 + (60.0 if dash_timer > 0.0 else 0.0)
		draw_line(Vector2(x, y), Vector2(x, y + length), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, alpha), 1.6 + speed_factor * 1.4)

func draw_afterimages() -> void:
	for a in afterimages:
		var age: float = float(a["age"])
		var duration: float = float(a["duration"])
		var t: float = clampf(age / duration, 0.0, 1.0)
		var pos: Vector2 = a["pos"]
		var c: Color = a["color"]
		var scale_v: float = float(a["scale"]) * (1.0 + t * 0.24)
		var rot: float = float(a["rot"])
		var alpha: float = (1.0 - t) * 0.24
		var pts: PackedVector2Array = make_diamond(35.0 * scale_v, 48.0 * scale_v)
		var transformed: PackedVector2Array = PackedVector2Array()
		for j in range(pts.size()):
			var point: Vector2 = pts[j]
			transformed.append(pos + point.rotated(rot))
		draw_colored_polygon(transformed, Color(c.r, c.g, c.b, alpha))

func draw_shockwaves() -> void:
	for s in shockwaves:
		var age: float = float(s["age"])
		var duration: float = float(s["duration"])
		var t: float = clampf(age / duration, 0.0, 1.0)
		var pos: Vector2 = s["pos"]
		var c: Color = s["color"]
		var radius: float = lerpf(float(s["start"]), float(s["end"]), t)
		var alpha: float = (1.0 - t) * 0.34
		draw_arc(pos, radius, 0.0, TAU, 96, Color(c.r, c.g, c.b, alpha), 4.0 * (1.0 - t) + 1.0, true)
		draw_circle(pos, radius * 0.42, Color(c.r, c.g, c.b, alpha * 0.13))

func draw_flash_overlay() -> void:
	if flash_alpha <= 0.001:
		return
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, flash_alpha * 0.35))
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, 90.0)), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, flash_alpha * 0.28))
	draw_rect(Rect2(Vector2(0.0, VIEW_H - 90.0), Vector2(VIEW_W, 90.0)), Color(C_JADE.r, C_JADE.g, C_JADE.b, flash_alpha * 0.22))
	if flow_timer > 0.0:
		var edge_alpha: float = 0.035 + 0.025 * sin(pulse_time * 7.0)
		draw_rect(Rect2(Vector2.ZERO, Vector2(8.0, VIEW_H)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, edge_alpha))
		draw_rect(Rect2(Vector2(VIEW_W - 8.0, 0.0), Vector2(8.0, VIEW_H)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, edge_alpha))

func draw_cultivation_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), C_DEEP_SKY)
	for y in range(0, int(VIEW_H), 64):
		var t: float = float(y) / VIEW_H
		var alpha_layer: float = 0.10 + 0.06 * sin((float(y) + pulse_time * 34.0) * 0.01)
		var layer_color: Color = C_DEEP_SKY_2.lerp(C_NEBULA, t * 0.32)
		layer_color.a = alpha_layer
		draw_rect(Rect2(0.0, float(y), VIEW_W, 64.0), layer_color)

	var moon_pos: Vector2 = Vector2(VIEW_W * 0.78, 155.0 + sin(pulse_time * 0.18) * 8.0)
	draw_circle(moon_pos, 92.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.045))
	draw_circle(moon_pos, 54.0, Color(0.88, 0.98, 1.0, 0.11))
	draw_circle(moon_pos + Vector2(10.0, -4.0), 40.0, Color(0.94, 1.0, 1.0, 0.13))

	for mountain in mountains:
		var mx: float = float(mountain["x"])
		var my: float = float(mountain["y"])
		var mw: float = float(mountain["w"])
		var mh: float = float(mountain["h"])
		var ma: float = float(mountain["alpha"])
		draw_floating_mountain(Vector2(mx, my), mw, mh, Color(0.45, 0.86, 0.95, ma))

	for s in stars:
		var star_pos: Vector2 = s["pos"]
		var star_size: float = float(s["size"])
		var star_alpha: float = float(s["alpha"])
		draw_circle(star_pos, star_size, Color(0.70, 0.94, 1.0, star_alpha))

	for qi in qi_particles:
		var qi_pos: Vector2 = qi["pos"]
		var qi_size: float = float(qi["size"])
		var qi_alpha: float = float(qi["alpha"])
		draw_circle(qi_pos, qi_size * 2.6, Color(C_JADE.r, C_JADE.g, C_JADE.b, qi_alpha * 0.22))
		draw_circle(qi_pos, qi_size, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, qi_alpha))

func draw_floating_mountain(base: Vector2, w: float, h: float, color: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		base + Vector2(-w * 0.50, h * 0.20),
		base + Vector2(-w * 0.25, -h * 0.35),
		base + Vector2(0.0, -h * 0.55),
		base + Vector2(w * 0.32, -h * 0.20),
		base + Vector2(w * 0.50, h * 0.18),
		base + Vector2(0.0, h * 0.55)
	])
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4]]), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, color.a * 0.50), 1.5)

func draw_spiritual_lanes() -> void:
	var path_color: Color = Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.08)
	var flow_alpha: float = 0.10 + 0.05 * sin(pulse_time * 1.8)
	draw_polygon(PackedVector2Array([
		Vector2(70.0, VIEW_H),
		Vector2(650.0, VIEW_H),
		Vector2(500.0, 0.0),
		Vector2(220.0, 0.0)
	]), PackedColorArray([Color(0.02, 0.18, 0.26, 0.18), Color(0.02, 0.18, 0.26, 0.18), Color(0.03, 0.12, 0.20, 0.02), Color(0.03, 0.12, 0.20, 0.02)]))
	for lane_offset in LANES:
		var x: float = VIEW_W * 0.5 + lane_offset
		draw_line(Vector2(x, 0.0), Vector2(x, VIEW_H), path_color, 4.0)
		draw_line(Vector2(x, 0.0), Vector2(x, VIEW_H), Color(C_JADE.r, C_JADE.g, C_JADE.b, flow_alpha * 0.32), 1.4)
	for i in range(9):
		var y: float = fmod(pulse_time * 95.0 + float(i) * 155.0, VIEW_H + 160.0) - 80.0
		draw_arc(Vector2(VIEW_W * 0.5, y), 220.0, PI * 0.05, PI * 0.95, 42, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.055), 2.0, true)

func draw_entities() -> void:
	for e in entities:
		var entity_type: String = str(e.get("type", ""))
		var p: Vector2 = e["pos"]
		var rot: float = float(e.get("rot", 0.0))
		if entity_type == "crystal":
			draw_crystal(p, 22.0, C_CELESTIAL, rot)
		elif entity_type == "power":
			draw_powerup(p, str(e.get("kind", "")), rot)
		else:
			draw_obstacle_by_kind(p, str(e.get("kind", "")), rot)

func draw_particles() -> void:
	for part in particles:
		var part_life: float = float(part["life"])
		var part_max: float = maxf(0.001, float(part["max"]))
		var alpha: float = maxf(0.0, part_life / part_max)
		var c: Color = part["color"]
		var part_pos: Vector2 = part["pos"]
		var part_size: float = float(part["size"])
		c.a *= alpha
		draw_circle(part_pos, part_size * alpha * 2.4, Color(c.r, c.g, c.b, c.a * 0.20))
		draw_circle(part_pos, part_size * alpha, c)

func draw_player_aura() -> void:
	if player == null:
		return
	var aura_power: float = clampf(resonance_value / 100.0, 0.0, 1.0)
	if flow_timer > 0.0:
		aura_power = 1.0
	var breathe: float = 1.0 + sin(pulse_time * 3.2) * 0.05
	var p: Vector2 = player.position
	draw_circle(p, 112.0 * breathe + aura_power * 32.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.055 + aura_power * 0.08))
	draw_circle(p, 70.0 * breathe + aura_power * 20.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.035 + aura_power * 0.06))
	for i in range(3):
		var r: float = 78.0 + float(i) * 18.0 + sin(pulse_time * 2.0 + float(i)) * 5.0
		var start_angle: float = pulse_time * (0.55 + float(i) * 0.08) + float(i) * 0.9
		var arc_color: Color = C_JADE if i % 2 == 0 else C_CELESTIAL
		draw_arc(p, r, start_angle, start_angle + PI * 1.18, 64, Color(arc_color.r, arc_color.g, arc_color.b, 0.12 + aura_power * 0.10), 2.0, true)
	if flow_timer > 0.0:
		draw_circle(p, 158.0 + sin(pulse_time * 6.0) * 8.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.10))
		draw_arc(p, 148.0, -pulse_time * 1.2, -pulse_time * 1.2 + PI * 1.55, 96, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.26), 3.0, true)
	if dash_timer > 0.0:
		draw_circle(p, 132.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.10))

func draw_crystal(p: Vector2, r: float, color: Color, rot: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var raw: Array[Vector2] = [
		Vector2(0.0, -r * 1.45),
		Vector2(r * 0.92, 0.0),
		Vector2(0.0, r * 1.45),
		Vector2(-r * 0.92, 0.0)
	]
	for point in raw:
		pts.append(p + point.rotated(rot))
	draw_circle(p, r * 1.7, Color(color.r, color.g, color.b, 0.12))
	draw_colored_polygon(pts, Color(color.r, color.g, color.b, 0.92))
	var line_pts: PackedVector2Array = PackedVector2Array(pts)
	line_pts.append(pts[0])
	draw_polyline(line_pts, Color(1.0, 1.0, 1.0, 0.82), 2.0)
	draw_line(p, pts[0], Color(1.0, 1.0, 1.0, 0.42), 1.2)
	draw_line(p, pts[2], Color(1.0, 1.0, 1.0, 0.30), 1.2)

func draw_powerup(p: Vector2, kind: String, rot: float) -> void:
	var outer: Color = C_NEBULA
	var inner: Color = C_GOLD
	if kind == "magnet":
		outer = C_JADE
		inner = C_CELESTIAL
	elif kind == "shield":
		outer = Color(0.70, 0.86, 1.0, 1.0)
		inner = C_PEARL
	elif kind == "slowmo":
		outer = C_NEBULA
		inner = Color(0.92, 0.80, 1.0, 1.0)
	draw_circle(p, 42.0, Color(outer.r, outer.g, outer.b, 0.16))
	draw_arc(p, 32.0, rot, rot + PI * 1.65, 36, Color(outer.r, outer.g, outer.b, 0.85), 3.0, true)
	draw_circle(p, 19.0, Color(inner.r, inner.g, inner.b, 0.90))
	draw_circle(p, 8.0, Color(1.0, 1.0, 1.0, 0.88))

func draw_obstacle_by_kind(p: Vector2, kind: String, rot: float) -> void:
	if kind == "ruptura_celestial":
		draw_rupture(p, rot)
	elif kind == "espinho_cristal":
		draw_obstacle_spike(p, 50.0, Color(C_NEBULA.r, C_NEBULA.g, C_NEBULA.b, 0.90), rot)
	elif kind == "selo_instavel":
		draw_unstable_seal(p, rot)
	else:
		draw_obstacle_spike(p, 48.0, Color(0.45, 0.88, 0.95, 0.75), rot)

func draw_rupture(p: Vector2, rot: float) -> void:
	draw_circle(p, 62.0, Color(C_NEBULA.r, C_NEBULA.g, C_NEBULA.b, 0.18))
	draw_arc(p, 52.0, rot, rot + PI * 1.3, 36, Color(C_NEBULA.r, C_NEBULA.g, C_NEBULA.b, 0.9), 6.0, true)
	draw_arc(p, 34.0, -rot, -rot + PI * 1.55, 36, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.42), 3.0, true)
	draw_line(p + Vector2(-22.0, -42.0).rotated(rot), p + Vector2(20.0, 44.0).rotated(rot), Color(1.0, 1.0, 1.0, 0.58), 2.0)

func draw_unstable_seal(p: Vector2, rot: float) -> void:
	draw_circle(p, 54.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.09))
	draw_arc(p, 46.0, rot, rot + PI * 1.8, 52, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.76), 4.0, true)
	draw_arc(p, 30.0, -rot * 1.2, -rot * 1.2 + PI * 1.4, 42, Color(C_NEBULA.r, C_NEBULA.g, C_NEBULA.b, 0.56), 3.0, true)
	for i in range(4):
		var angle: float = rot + TAU * float(i) / 4.0
		var a: Vector2 = p + Vector2(cos(angle), sin(angle)) * 18.0
		var b: Vector2 = p + Vector2(cos(angle), sin(angle)) * 42.0
		draw_line(a, b, Color(1.0, 1.0, 1.0, 0.44), 1.6)

func draw_obstacle_spike(p: Vector2, r: float, color: Color, rot: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var count: int = 8
	for i in range(count):
		var rr: float = r if i % 2 == 0 else r * 0.50
		var a: float = rot + TAU * float(i) / float(count)
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	draw_circle(p, r * 1.25, Color(color.r, color.g, color.b, 0.12))
	draw_colored_polygon(pts, color)
	var line_pts: PackedVector2Array = PackedVector2Array(pts)
	line_pts.append(pts[0])
	draw_polyline(line_pts, Color(1.0, 1.0, 1.0, 0.48), 2.0)
