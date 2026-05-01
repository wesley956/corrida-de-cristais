extends Node2D

# Fragment Rush: Corrida dos Cristais
# v1.4 - Resultado Premium + Recompensas Animadas
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
var tutorial_layer: CanvasLayer
var transition_layer: CanvasLayer
var neo_ui: FragmentUiController

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
var tutorial_card: Panel
var transition_card: Panel

var title_label: Label
var subtitle_label: Label
var start_button: Button
var shop_button: Button
var close_shop_button: Button
var shop_info_label: Label
var shop_title_label: Label
var shop_preview_name_label: Label
var shop_preview_meta_label: Label
var shop_preview_desc_label: Label
var shop_action_button: Button
var daily_button: Button
var cultivation_button: Button
var help_button: Button
var shop_skin_buttons: Dictionary = {}
var selected_shop_skin: String = "nucleo_errante"
var cultivation_info_label: Label
var cultivation_stage_label: Label
var cultivation_next_circle_label: Label
var cultivation_close_button: Button
var cultivation_upgrade_buttons: Dictionary = {}
var tutorial_title: Label
var tutorial_text: Label
var tutorial_close_button: Button
var biome_label: Label
var transition_label: Label
var transition_subtitle: Label
var result_summary_label: Label
var result_xp_label: Label
var result_xp_bar: ProgressBar
var result_form_label: Label
var result_form_bar: ProgressBar

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
var skin_trails: Array[Dictionary] = []

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
var tutorial_seen: bool = false
var current_biome_index: int = 0
var rare_crystals_run: int = 0
var circles_unlocked_run: int = 0
var form_unlock_timer: float = 0.0
var form_unlock_name: String = ""
var form_unlock_skin: String = ""
var crystal_rain_timer: float = 11.0
var crystal_rain_active: float = 0.0
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

const RESONANCE_CIRCLES: Array = [
	{
		"name": "Círculo Ciano",
		"xp": 500,
		"color": Color(0.322, 0.902, 1.0, 1.0),
		"effect": "+Ressonância ao coletar cristais"
	},
	{
		"name": "Círculo de Jade",
		"xp": 1400,
		"color": Color(0.384, 0.949, 0.706, 1.0),
		"effect": "+Alcance do Chamado do Jade"
	},
	{
		"name": "Círculo Nebular",
		"xp": 3000,
		"color": Color(0.541, 0.361, 1.0, 1.0),
		"effect": "+Bônus em Ressonância Perfeita"
	},
	{
		"name": "Círculo Dourado",
		"xp": 6000,
		"color": Color(1.0, 0.851, 0.502, 1.0),
		"effect": "+Valor dos Cristais Raros"
	},
	{
		"name": "Círculo Celestial",
		"xp": 10000,
		"color": Color(0.918, 0.984, 1.0, 1.0),
		"effect": "+Duração do Estado de Fluxo"
	}
]

const BIOMES: Array = [
	{
		"name": "Trilha do Céu Fragmentado",
		"at": 0.0,
		"deep": Color(0.027, 0.078, 0.149, 1.0),
		"mist": Color(0.035, 0.120, 0.210, 1.0),
		"accent": Color(0.322, 0.902, 1.0, 1.0),
		"secondary": Color(0.384, 0.949, 0.706, 1.0)
	},
	{
		"name": "Vale de Jade Suspenso",
		"at": 700.0,
		"deep": Color(0.018, 0.105, 0.115, 1.0),
		"mist": Color(0.035, 0.175, 0.155, 1.0),
		"accent": Color(0.384, 0.949, 0.706, 1.0),
		"secondary": Color(0.322, 0.902, 1.0, 1.0)
	},
	{
		"name": "Ruínas da Lua Partida",
		"at": 1500.0,
		"deep": Color(0.050, 0.042, 0.145, 1.0),
		"mist": Color(0.105, 0.070, 0.225, 1.0),
		"accent": Color(0.541, 0.361, 1.0, 1.0),
		"secondary": Color(1.0, 0.851, 0.502, 1.0)
	},
	{
		"name": "Portão da Ascensão",
		"at": 2500.0,
		"deep": Color(0.115, 0.070, 0.028, 1.0),
		"mist": Color(0.190, 0.115, 0.045, 1.0),
		"accent": Color(1.0, 0.851, 0.502, 1.0),
		"secondary": Color(0.918, 0.984, 1.0, 1.0)
	}
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
var run_countdown: float = 0.0
var result_reveal_timer: float = 0.0
var result_count_crystals: float = 0.0
var result_count_xp: float = 0.0
var result_target_crystals: int = 0
var result_target_xp: int = 0
var result_badge_pulse: float = 0.0

func _ready() -> void:
	rng.randomize()
	load_save()
	create_background_layers()
	build_game_nodes()
	build_ui()
	show_menu()
	if not tutorial_seen:
		show_tutorial()

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
	if screen == "countdown":
		update_countdown(real_delta)
	elif screen == "game":
		update_game(game_delta, real_delta)
	elif screen == "result":
		update_result_motion(real_delta)
	else:
		if screen != "pause":
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
	update_player_skin_visuals()

func make_diamond(width: float, height: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.0, -height),
		Vector2(width, 0.0),
		Vector2(0.0, height),
		Vector2(-width, 0.0)
	])

func make_skin_polygon(skin_id: String, width: float, height: float) -> PackedVector2Array:
	var variant: int = skin_shape_variant(skin_id)
	if variant == 0:
		return make_diamond(width, height)

	var sides: int = 6
	if variant == 1:
		sides = 7
	elif variant == 2:
		sides = 8
	elif variant == 3:
		sides = 5
	elif variant >= 4:
		sides = 10

	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(sides):
		var a: float = TAU * float(i) / float(sides) - PI * 0.5
		var even: bool = i % 2 == 0
		var rx: float = width * (1.05 if even else 0.70)
		var ry: float = height * (1.00 if even else 0.62)
		if variant == 1:
			rx = width * (0.92 if even else 0.58)
			ry = height * (0.96 if even else 0.70)
		elif variant == 2:
			rx = width * (1.10 if even else 0.46)
			ry = height * (1.08 if even else 0.52)
		elif variant == 3:
			rx = width * (1.18 if even else 0.58)
			ry = height * (0.92 if even else 0.70)
		elif variant >= 4:
			rx = width * (1.22 if even else 0.72)
			ry = height * (1.06 if even else 0.72)
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	return pts

func update_player_skin_visuals() -> void:
	if player_core == null or player_glow == null or player_ring == null:
		return
	var base_c: Color = skin_color(selected_skin)
	var secondary_c: Color = skin_secondary_color(selected_skin)
	var variant: int = skin_shape_variant(selected_skin)
	var power: float = skin_rarity_power(selected_skin)

	player_core.polygon = make_skin_polygon(selected_skin, 35.0 + float(variant) * 1.8, 48.0 + float(variant) * 2.0)
	player_core.color = Color(base_c.r, base_c.g, base_c.b, 0.92)

	player_glow.polygon = make_skin_polygon(selected_skin, 58.0 + float(variant) * 2.8, 66.0 + float(variant) * 3.0)
	player_glow.color = Color(secondary_c.r, secondary_c.g, secondary_c.b, 0.20 + minf(0.16, (power - 1.0) * 0.12))

	player_ring.polygon = make_skin_polygon(selected_skin, 76.0 + float(variant) * 3.6, 82.0 + float(variant) * 3.8)
	player_ring.color = Color(base_c.r, base_c.g, base_c.b, 0.10 + minf(0.14, (power - 1.0) * 0.08))

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
	tutorial_layer = CanvasLayer.new()
	add_child(tutorial_layer)
	transition_layer = CanvasLayer.new()
	add_child(transition_layer)

	neo_ui = FragmentUiController.new()
	add_child(neo_ui)
	neo_ui.start_requested.connect(start_game)
	neo_ui.pavilion_requested.connect(show_shop)
	neo_ui.core_requested.connect(show_cultivation)
	neo_ui.daily_requested.connect(claim_daily_reward)
	neo_ui.guide_requested.connect(show_tutorial)
	neo_ui.back_requested.connect(show_menu)
	neo_ui.skin_selected.connect(select_shop_skin)
	neo_ui.skin_action_requested.connect(activate_selected_shop_skin)
	neo_ui.upgrade_requested.connect(upgrade_technique)

	# HUD - glassmorphism espiritual
	var hud_left_panel: Panel = make_panel(Vector2(22, 22), Vector2(188, 82), Color(0.03, 0.12, 0.20, 0.72), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.26))
	var hud_center_panel: Panel = make_panel(Vector2(226, 22), Vector2(268, 82), Color(0.03, 0.12, 0.20, 0.76), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.20))
	var hud_right_panel: Panel = make_panel(Vector2(510, 22), Vector2(188, 82), Color(0.03, 0.12, 0.20, 0.72), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.26))
	var resonance_panel: Panel = make_panel(Vector2(86, 118), Vector2(548, 48), Color(0.02, 0.11, 0.17, 0.70), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.22))
	for panel in [hud_left_panel, hud_center_panel, hud_right_panel, resonance_panel]:
		hud_layer.add_child(panel)

	var hud_left_title: Label = make_label("Cristais", 16, Vector2(14, 10), Color(0.73, 0.94, 1.0, 0.90))
	crystal_label = make_label("0", 32, Vector2(14, 22), C_CELESTIAL)
	score_label = make_label("Pontos 0", 14, Vector2(14, 55), Color(0.86, 0.96, 1.0, 0.86))
	hud_left_panel.add_child(hud_left_title)
	hud_left_panel.add_child(crystal_label)
	hud_left_panel.add_child(score_label)

	var hud_center_title: Label = make_label("Marca atual", 16, Vector2(0, 10), Color(0.80, 0.95, 1.0, 0.84))
	hud_center_title.size = Vector2(268, 22)
	hud_center_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label = make_label("0 m", 30, Vector2(0, 21), C_PEARL)
	distance_label.size = Vector2(268, 34)
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_best_label = make_label("Ascensão 0 m", 14, Vector2(0, 55), Color(0.72, 0.90, 1.0, 0.80))
	hud_best_label.size = Vector2(268, 22)
	hud_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_center_panel.add_child(hud_center_title)
	hud_center_panel.add_child(distance_label)
	hud_center_panel.add_child(hud_best_label)

	var hud_right_title: Label = make_label("Fluxo", 16, Vector2(14, 10), Color(0.78, 0.98, 0.90, 0.88))
	combo_label = make_label("x1", 32, Vector2(14, 20), C_GOLD)
	dash_label = make_label("Passo pronto", 14, Vector2(14, 55), Color(0.76, 0.98, 0.86, 0.84))
	hud_right_panel.add_child(hud_right_title)
	hud_right_panel.add_child(combo_label)
	hud_right_panel.add_child(dash_label)

	resonance_label = make_label("Ressonância", 16, Vector2(16, 8), Color(0.86, 0.98, 0.90, 0.90))
	resonance_bar = make_progress_bar(Vector2(16, 26), Vector2(516, 14))
	resonance_panel.add_child(resonance_label)
	resonance_panel.add_child(resonance_bar)

	status_label = make_label("", 28, Vector2(0, 220), C_GOLD)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size = Vector2(VIEW_W, 70)
	hud_layer.add_child(status_label)

	pause_button = make_button("Ⅱ", Vector2(645, 180), Vector2(52, 50))
	pause_button.add_theme_font_size_override("font_size", 22)
	pause_button.pressed.connect(pause_game)
	hud_layer.add_child(pause_button)

	biome_label = make_label("", 16, Vector2(0, 208), Color(0.82, 0.96, 1.0, 0.86))
	biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	biome_label.size = Vector2(VIEW_W, 34)
	hud_layer.add_child(biome_label)

	# Menu principal
	menu_card = make_panel(Vector2(48, 132), Vector2(624, 790), Color(0.02, 0.08, 0.14, 0.02), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.00))
	menu_layer.add_child(menu_card)
	title_label = make_label("FRAGMENT RUSH\nCorrida dos Cristais", 42, Vector2(0, 18), C_PEARL)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size = Vector2(624, 118)
	subtitle_label = make_label("Neo-cultivo cristalino em alta velocidade.", 19, Vector2(58, 140), Color(0.78, 0.95, 1.0, 0.92))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.size = Vector2(508, 60)
	best_label = make_label("", 18, Vector2(46, 285), Color(0.74, 0.92, 1.0, 0.92))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.size = Vector2(532, 74)
	start_button = make_button("INICIAR CORRIDA", Vector2(96, 430), Vector2(432, 84))
	shop_button = make_button("PAVILHÃO", Vector2(72, 548), Vector2(225, 64))
	cultivation_button = make_button("NÚCLEO", Vector2(327, 548), Vector2(225, 64))
	daily_button = make_button("ESSÊNCIA DIÁRIA", Vector2(116, 635), Vector2(392, 60))
	help_button = make_button("COMO JOGAR", Vector2(166, 715), Vector2(292, 54))
	daily_button.add_theme_font_size_override("font_size", 18)
	help_button.add_theme_font_size_override("font_size", 17)
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(show_shop)
	cultivation_button.pressed.connect(show_cultivation)
	daily_button.pressed.connect(claim_daily_reward)
	help_button.pressed.connect(show_tutorial)
	for node in [title_label, subtitle_label, best_label, start_button, shop_button, cultivation_button, daily_button, help_button]:
		menu_card.add_child(node)

	# Resultado premium
	result_card = make_panel(Vector2(48, 118), Vector2(624, 1000), Color(0.03, 0.11, 0.19, 0.72), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.28))
	result_layer.add_child(result_card)
	result_title = make_label("FLUXO INTERROMPIDO", 36, Vector2(0, 34), C_PEARL)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.size = Vector2(624, 64)
	result_summary_label = make_label("", 28, Vector2(38, 112), C_GOLD)
	result_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_summary_label.size = Vector2(548, 90)
	result_stats = make_label("", 15, Vector2(48, 226), Color(0.86, 0.96, 1.0, 1.0))
	result_stats.size = Vector2(528, 285)
	result_xp_label = make_label("", 17, Vector2(48, 522), Color(0.88, 1.0, 0.92, 0.95))
	result_xp_label.size = Vector2(528, 34)
	result_xp_bar = make_progress_bar(Vector2(48, 558), Vector2(528, 18))
	result_form_label = make_label("", 17, Vector2(48, 592), Color(1.0, 0.90, 0.62, 0.96))
	result_form_label.size = Vector2(528, 34)
	result_form_bar = make_progress_bar(Vector2(48, 628), Vector2(528, 18))
	restart_button = make_button("CULTIVAR NOVAMENTE", Vector2(92, 728), Vector2(440, 76))
	menu_button = make_button("VOLTAR AO MENU", Vector2(142, 906), Vector2(340, 62))
	var result_pavilion_button: Button = make_button("PAVILHÃO", Vector2(66, 820), Vector2(270, 62))
	var result_core_button: Button = make_button("NÚCLEO", Vector2(384, 820), Vector2(270, 62))
	restart_button.pressed.connect(start_game)
	menu_button.pressed.connect(show_menu)
	result_pavilion_button.pressed.connect(show_shop)
	result_core_button.pressed.connect(show_cultivation)
	for node in [result_title, result_summary_label, result_stats, result_xp_label, result_xp_bar, result_form_label, result_form_bar, restart_button, result_pavilion_button, result_core_button, menu_button]:
		result_card.add_child(node)

	# Pavilhão Celestial das Formas — vitrine holográfica
	shop_card = make_panel(Vector2(34, 76), Vector2(652, 1078), Color(0.02, 0.08, 0.14, 0.02), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.00))
	shop_layer.add_child(shop_card)
	shop_title_label = make_label("PAVILHÃO CELESTIAL", 32, Vector2(0, 28), C_PEARL)
	shop_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_title_label.size = Vector2(652, 58)
	shop_preview_name_label = make_label("", 30, Vector2(0, 382), C_PEARL)
	shop_preview_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_preview_name_label.size = Vector2(652, 52)
	shop_preview_meta_label = make_label("", 18, Vector2(0, 430), C_GOLD)
	shop_preview_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_preview_meta_label.size = Vector2(652, 36)
	shop_preview_desc_label = make_label("", 18, Vector2(70, 470), Color(0.82, 0.96, 1.0, 0.90))
	shop_preview_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_preview_desc_label.size = Vector2(512, 80)
	shop_info_label = make_label("", 16, Vector2(54, 84), Color(0.82, 0.96, 1.0, 0.72))
	shop_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_info_label.size = Vector2(544, 46)
	shop_action_button = make_button("", Vector2(126, 558), Vector2(400, 74))
	shop_action_button.pressed.connect(activate_selected_shop_skin)
	for node in [shop_title_label, shop_info_label, shop_preview_name_label, shop_preview_meta_label, shop_preview_desc_label, shop_action_button]:
		shop_card.add_child(node)

	var skin_order: Array[String] = ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for i in range(skin_order.size()):
		var skin_id: String = skin_order[i]
		var col: int = i % 2
		var row: int = int(i / 2)
		var b: Button = make_button("", Vector2(54 + col * 274, 668 + row * 96), Vector2(250, 78))
		b.add_theme_font_size_override("font_size", 16)
		b.pressed.connect(func() -> void: select_shop_skin(skin_id))
		shop_skin_buttons[skin_id] = b
		shop_card.add_child(b)

	close_shop_button = make_button("VOLTAR", Vector2(176, 956), Vector2(300, 66))
	close_shop_button.pressed.connect(show_menu)
	shop_card.add_child(close_shop_button)

	# Câmara do Núcleo — câmara visual de cultivo
	cultivation_card = make_panel(Vector2(34, 76), Vector2(652, 1078), Color(0.02, 0.08, 0.14, 0.02), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.00))
	cultivation_layer.add_child(cultivation_card)
	cultivation_info_label = make_label("CÂMARA DO NÚCLEO", 32, Vector2(0, 28), C_PEARL)
	cultivation_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cultivation_info_label.size = Vector2(652, 58)
	cultivation_stage_label = make_label("", 24, Vector2(0, 420), C_PEARL)
	cultivation_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cultivation_stage_label.size = Vector2(652, 76)
	cultivation_next_circle_label = make_label("", 17, Vector2(72, 498), Color(0.84, 0.96, 1.0, 0.88))
	cultivation_next_circle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cultivation_next_circle_label.size = Vector2(508, 72)
	for node in [cultivation_info_label, cultivation_stage_label, cultivation_next_circle_label]:
		cultivation_card.add_child(node)

	var technique_order: Array[String] = ["dash", "jade", "flow"]
	for i in range(technique_order.size()):
		var tech_id: String = technique_order[i]
		var tx: float = 54.0 + float(i) * 183.0
		var tb: Button = make_button("", Vector2(tx, 654), Vector2(166, 128))
		tb.add_theme_font_size_override("font_size", 15)
		tb.pressed.connect(func() -> void: upgrade_technique(tech_id))
		cultivation_upgrade_buttons[tech_id] = tb
		cultivation_card.add_child(tb)

	cultivation_close_button = make_button("VOLTAR", Vector2(176, 956), Vector2(300, 66))
	cultivation_close_button.pressed.connect(show_menu)
	cultivation_card.add_child(cultivation_close_button)

	# Tutorial / Como jogar
	tutorial_card = make_panel(Vector2(48, 118), Vector2(624, 980), Color(0.03, 0.11, 0.19, 0.78), Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.30))
	tutorial_layer.add_child(tutorial_card)
	tutorial_title = make_label("COMO CULTIVAR NA TRILHA", 34, Vector2(0, 42), C_PEARL)
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_title.size = Vector2(624, 70)
	tutorial_text = make_label("", 22, Vector2(54, 135), Color(0.84, 0.96, 1.0, 0.96))
	tutorial_text.size = Vector2(516, 650)
	tutorial_text.text = "• Arraste para esquerda/direita para trocar de faixa.\n\n• Toque para usar o Passo Espiritual.\n\n• Passe perto dos obstáculos para gerar Ressonância Perfeita.\n\n• Encha a Ressonância para entrar no Estado de Fluxo.\n\n• Cristais raros valem mais e ajudam sua progressão.\n\n• Cada corrida rende cristais, XP e missões para fortalecer seu Núcleo de Cultivo."
	tutorial_close_button = make_button("ENTENDI", Vector2(162, 825), Vector2(300, 72))
	tutorial_close_button.pressed.connect(close_tutorial)
	tutorial_card.add_child(tutorial_title)
	tutorial_card.add_child(tutorial_text)
	tutorial_card.add_child(tutorial_close_button)
	tutorial_layer.visible = false

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

	# Transição de início
	transition_card = make_panel(Vector2(88, 390), Vector2(544, 330), Color(0.03, 0.11, 0.19, 0.74), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.32))
	transition_layer.add_child(transition_card)
	transition_label = make_label("", 58, Vector2(0, 82), C_PEARL)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.size = Vector2(544, 80)
	transition_subtitle = make_label("", 23, Vector2(40, 188), Color(0.82, 0.98, 1.0, 0.94))
	transition_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_subtitle.size = Vector2(464, 80)
	transition_card.add_child(transition_label)
	transition_card.add_child(transition_subtitle)
	transition_layer.visible = false

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
	style.bg_color = Color(bg.r, bg.g, bg.b, minf(bg.a, 0.52))
	style.border_color = Color(border.r, border.g, border.b, minf(maxf(border.a, 0.18), 0.42))
	style.set_border_width_all(1)
	style.set_corner_radius_all(42)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
	style.shadow_size = 8
	style.set_content_margin(SIDE_TOP, 8.0)
	style.set_content_margin(SIDE_BOTTOM, 8.0)
	style.set_content_margin(SIDE_LEFT, 20.0)
	style.set_content_margin(SIDE_RIGHT, 20.0)
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
	screen = "countdown"
	run_countdown = 2.35
	if neo_ui != null:
		neo_ui.hide_all()
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	hud_layer.visible = true
	transition_layer.visible = true
	entities.clear()
	particles.clear()
	shockwaves.clear()
	afterimages.clear()
	skin_trails.clear()
	flash_alpha = 0.0
	combo_pop_timer = 0.0
	flow_timer = 0.0
	flow_activations = 0
	run_mission_bonus = 0
	completed_run_missions.clear()
	current_biome_index = 0
	rare_crystals_run = 0
	circles_unlocked_run = 0
	crystal_rain_timer = 11.0
	crystal_rain_active = 0.0
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
	update_countdown(0.0)

func update_countdown(delta: float) -> void:
	run_countdown = maxf(0.0, run_countdown - delta)
	transition_layer.visible = true
	hud_layer.visible = true
	if run_countdown > 1.55:
		transition_label.text = "3"
		transition_subtitle.text = "Respire. O núcleo desperta."
	elif run_countdown > 0.85:
		transition_label.text = "2"
		transition_subtitle.text = "Sinta o fluxo entre os cristais."
	elif run_countdown > 0.20:
		transition_label.text = "1"
		transition_subtitle.text = "A trilha está se abrindo."
	else:
		screen = "game"
		transition_layer.visible = false
		show_status("A TRILHA SE ABRIU", C_JADE)
		flash_alpha = maxf(flash_alpha, 0.10)
		spawn_shockwave(player.position, C_JADE, 46.0, 220.0, 0.55)

func update_result_motion(delta: float) -> void:
	result_reveal_timer += delta
	result_badge_pulse += delta
	if result_card != null:
		result_card.modulate.a = minf(1.0, 0.70 + result_reveal_timer * 0.82)
	if result_summary_label != null:
		result_summary_label.scale = Vector2.ONE * (1.0 + sin(pulse_time * 1.8) * 0.014)

	var speed_count: float = maxf(1.0, delta * 5.2)
	result_count_crystals = lerpf(result_count_crystals, float(result_target_crystals), speed_count)
	result_count_xp = lerpf(result_count_xp, float(result_target_xp), speed_count)
	if absf(result_count_crystals - float(result_target_crystals)) < 0.7:
		result_count_crystals = float(result_target_crystals)
	if absf(result_count_xp - float(result_target_xp)) < 0.7:
		result_count_xp = float(result_target_xp)
	if result_summary_label != null:
		result_summary_label.text = "%d m\n+%d XP  •  +%d Cristais" % [int(distance), int(result_count_xp), int(result_count_crystals)]

func get_stage_progress_percent() -> float:
	var idx: int = get_cultivation_stage_index()
	var prev_xp: int = 0
	var next_xp: int = next_stage_xp()
	match idx:
		0:
			prev_xp = 0
		1:
			prev_xp = 500
		2:
			prev_xp = 1400
		3:
			prev_xp = 3000
		_:
			return 100.0
	if next_xp <= prev_xp:
		return 100.0
	return clampf(float(cultivation_xp - prev_xp) / float(next_xp - prev_xp) * 100.0, 0.0, 100.0)

func get_next_form_progress_percent() -> float:
	var cheapest_price: int = 999999
	for skin_id in SKINS.keys():
		if bool(owned_skins.get(skin_id, false)):
			continue
		var data: Dictionary = SKINS[skin_id]
		var price: int = int(data["price"])
		if price < cheapest_price:
			cheapest_price = price
	if cheapest_price == 999999:
		return 100.0
	return clampf(float(total_crystals) / float(cheapest_price) * 100.0, 0.0, 100.0)

func hide_legacy_meta_layers() -> void:
	menu_layer.visible = false
	shop_layer.visible = false
	cultivation_layer.visible = false
	if neo_ui != null:
		neo_ui.visible = true

func update_neo_menu() -> void:
	if neo_ui == null or neo_ui.menu == null:
		return
	var daily_available: bool = last_daily_reward != current_day_key()
	var ring_count: int = max(1, unlocked_circle_count())
	neo_ui.menu.set_data(
		get_cultivation_stage_name(),
		cultivation_xp,
		unlocked_circle_count(),
		RESONANCE_CIRCLES.size(),
		int(best_distance),
		total_crystals,
		daily_available,
		skin_color(selected_skin),
		ring_count
	)

func shop_action_text(skin_id: String) -> String:
	var data: Dictionary = SKINS[skin_id]
	var price: int = int(data["price"])
	var owned: bool = bool(owned_skins.get(skin_id, false))
	var equipped: bool = skin_id == selected_skin
	if equipped:
		return "EQUIPADO"
	if owned:
		return "EQUIPAR FORMA"
	if total_crystals >= price:
		return "DESPERTAR · %d" % price
	return "FALTAM %d CRISTAIS" % max(0, price - total_crystals)

func neo_skin_buttons_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var skin_order: Array[String] = ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for skin_id: String in skin_order:
		var data: Dictionary = SKINS[skin_id]
		var price: int = int(data["price"])
		var owned: bool = bool(owned_skins.get(skin_id, false))
		var equipped: bool = skin_id == selected_skin
		var state: String = "EQUIPADO" if equipped else ("LIBERADO" if owned else "%d cristais" % price)
		var rarity: String = skin_rarity(skin_id)
		result.append({
			"id": skin_id,
			"name": str(data["name"]),
			"state": "%s · %s" % [skin_rarity(skin_id), state],
			"color": rarity_color_text(rarity)
		})
	return result

func update_neo_pavilion() -> void:
	if neo_ui == null or neo_ui.pavilion == null:
		return
	if not SKINS.has(selected_shop_skin):
		selected_shop_skin = selected_skin
	if not SKINS.has(selected_shop_skin):
		selected_shop_skin = "nucleo_errante"
	var data: Dictionary = SKINS[selected_shop_skin]
	var rarity: String = skin_rarity(selected_shop_skin)
	neo_ui.pavilion.set_data(
		selected_shop_skin,
		str(data["name"]),
		rarity,
		str(data["desc"]),
		skin_affinity_text(selected_shop_skin),
		total_crystals,
		shop_action_text(selected_shop_skin),
		rarity_color_text(rarity),
		max(1, unlocked_circle_count()),
		neo_skin_buttons_data()
	)

func technique_ui_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var order: Array[String] = ["dash", "jade", "flow"]
	for tech_id: String in order:
		var data: Dictionary = TECHNIQUES[tech_id]
		var level: int = tech_level(tech_id)
		var max_level: int = int(data["max"])
		var action: String = "MAX" if level >= max_level else "%d cristais" % technique_price(tech_id)
		result.append({
			"id": tech_id,
			"name": str(data["name"]),
			"level": "%d/%d" % [level, max_level],
			"action": action
		})
	return result

func update_neo_core() -> void:
	if neo_ui == null or neo_ui.core == null:
		return
	var accent: Color = C_CELESTIAL
	var count: int = unlocked_circle_count()
	if count > 0:
		accent = circle_color(count)
	neo_ui.core.set_data(
		get_cultivation_stage_name(),
		cultivation_xp,
		get_stage_progress_percent(),
		next_circle_hint(),
		accent,
		max(1, count),
		technique_ui_data()
	)

func show_menu() -> void:
	screen = "menu"
	hide_legacy_meta_layers()
	result_layer.visible = false
	pause_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	hud_layer.visible = false
	if neo_ui != null:
		neo_ui.show_menu()
	update_neo_menu()
	update_daily_button()

func pause_game() -> void:
	if screen != "game":
		return
	screen = "pause"
	if neo_ui != null:
		neo_ui.hide_all()
	hud_layer.visible = false
	pause_layer.visible = true
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	cultivation_layer.visible = false
	tutorial_layer.visible = false

func resume_game() -> void:
	if screen != "pause":
		return
	screen = "game"
	hud_layer.visible = true
	pause_layer.visible = false

func activate_flow_state() -> void:
	flow_timer = 5.8 + float(tech_level("flow")) * 0.45 + (0.75 if has_resonance_circle(5) else 0.0)
	flow_activations += 1
	resonance_value = 100.0
	invulnerable_timer = maxf(invulnerable_timer, 1.2)
	flash_alpha = maxf(flash_alpha, 0.20)
	camera_shake = maxf(camera_shake, 8.0)
	combo_pop_timer = 1.0
	spawn_afterimage(player.position, C_GOLD, 0.55)
	spawn_shockwave(player.position, C_GOLD, 48.0, 260.0, 0.72)
	show_status("ESTADO DE FLUXO  •  CÍRCULOS %d/%d" % [unlocked_circle_count(), RESONANCE_CIRCLES.size()], C_GOLD)
	for _i in range(28):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-72.0, 72.0), rng.randf_range(-64.0, 64.0))
		spawn_particle(particle_pos, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.82), 7, 0.58)

func show_tutorial() -> void:
	screen = "tutorial"
	if neo_ui != null:
		neo_ui.hide_all()
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	hud_layer.visible = false
	transition_layer.visible = false
	tutorial_layer.visible = true

func close_tutorial() -> void:
	tutorial_seen = true
	save_game()
	show_menu()

func unlocked_circle_count() -> int:
	var count: int = 0
	for circle_data in RESONANCE_CIRCLES:
		var required_xp: int = int(circle_data["xp"])
		if cultivation_xp >= required_xp:
			count += 1
	return count

func has_resonance_circle(index: int) -> bool:
	return unlocked_circle_count() >= index

func circle_name(index: int) -> String:
	var safe_index: int = clampi(index - 1, 0, RESONANCE_CIRCLES.size() - 1)
	return str(RESONANCE_CIRCLES[safe_index]["name"])

func circle_color(index: int) -> Color:
	var safe_index: int = clampi(index - 1, 0, RESONANCE_CIRCLES.size() - 1)
	return RESONANCE_CIRCLES[safe_index]["color"]

func next_circle_hint() -> String:
	var count: int = unlocked_circle_count()
	if count >= RESONANCE_CIRCLES.size():
		return "Todos os Círculos de Ressonância despertaram."
	var next_circle: Dictionary = RESONANCE_CIRCLES[count]
	var required_xp: int = int(next_circle["xp"])
	var missing: int = max(0, required_xp - cultivation_xp)
	return "Próximo círculo: %s  •  faltam %d XP" % [str(next_circle["name"]), missing]

func circles_summary_text() -> String:
	var count: int = unlocked_circle_count()
	var lines: Array[String] = []
	lines.append("Círculos despertos: %d/%d" % [count, RESONANCE_CIRCLES.size()])
	if count > 0:
		for i in range(count):
			var data: Dictionary = RESONANCE_CIRCLES[i]
			lines.append("• %s — %s" % [str(data["name"]), str(data["effect"])])
	else:
		lines.append("• Nenhum círculo desperto ainda.")
	lines.append(next_circle_hint())
	return "\n".join(lines)

func circle_unlock_text(old_count: int, new_count: int) -> String:
	if new_count <= old_count:
		return ""
	var unlocked_names: Array[String] = []
	for i in range(old_count, new_count):
		if i >= 0 and i < RESONANCE_CIRCLES.size():
			unlocked_names.append(str(RESONANCE_CIRCLES[i]["name"]))
	return "Novo despertar: %s" % ", ".join(unlocked_names)

func show_cultivation() -> void:
	screen = "cultivation"
	hide_legacy_meta_layers()
	result_layer.visible = false
	pause_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	hud_layer.visible = false
	if neo_ui != null:
		neo_ui.show_core()
	update_cultivation_ui()
	update_neo_core()

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
		progress_line = "Próximo estágio em %d XP" % max(0, next_xp - cultivation_xp)
	cultivation_stage_label.text = "%s
XP %d  ·  %.0f%%" % [get_cultivation_stage_name(), cultivation_xp, get_stage_progress_percent()]
	cultivation_next_circle_label.text = "%s
%s" % [next_circle_hint(), progress_line]

	for tech_id in cultivation_upgrade_buttons.keys():
		var b: Button = cultivation_upgrade_buttons[tech_id]
		var data: Dictionary = TECHNIQUES[tech_id]
		var level: int = tech_level(tech_id)
		var max_level: int = int(data["max"])
		var price: int = technique_price(tech_id)
		var action: String = "MAX" if level >= max_level else "%d" % price
		b.text = "%s
Nv.%d/%d
%s" % [str(data["name"]), level, max_level, action]
		var border_color: Color = C_GOLD if tech_id == "flow" else (C_JADE if tech_id == "jade" else C_CELESTIAL)
		if level >= max_level:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.10, 0.23, 0.22, 0.82), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.62)))
		else:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.035, 0.12, 0.19, 0.72), Color(border_color.r, border_color.g, border_color.b, 0.40)))
	update_neo_core()

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
	hide_legacy_meta_layers()
	result_layer.visible = false
	pause_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	hud_layer.visible = false
	selected_shop_skin = selected_skin
	if neo_ui != null:
		neo_ui.show_pavilion()
	update_shop_ui()
	update_neo_pavilion()

func skin_rarity(skin_id: String) -> String:
	match skin_id:
		"nucleo_errante":
			return "Comum"
		"semente_jade":
			return "Raro"
		"orbe_celestial":
			return "Raro"
		"coracao_nebular":
			return "Épico"
		"essencia_dourada":
			return "Lendário"
		_:
			return "Comum"

func skin_effect_text(skin_id: String) -> String:
	match skin_id:
		"semente_jade":
			return "%s · Chamado do Jade" % skin_trail_name(skin_id)
		"orbe_celestial":
			return "%s · XP espiritual" % skin_trail_name(skin_id)
		"coracao_nebular":
			return "%s · Ressonância" % skin_trail_name(skin_id)
		"essencia_dourada":
			return "%s · Cristais raros" % skin_trail_name(skin_id)
		_:
			return "%s · Equilíbrio" % skin_trail_name(skin_id)

func rarity_color_text(rarity: String) -> Color:
	match rarity:
		"Raro":
			return C_JADE
		"Épico":
			return C_NEBULA
		"Lendário":
			return C_GOLD
		"Celestial":
			return C_PEARL
		_:
			return C_CELESTIAL

func skin_affinity_text(skin_id: String) -> String:
	match skin_id:
		"semente_jade":
			return "Jade · Harmonia"
		"orbe_celestial":
			return "Céu · Pureza"
		"coracao_nebular":
			return "Nebular · Ressonância"
		"essencia_dourada":
			return "Ascensão · Fortuna"
		_:
			return "Cristal · Equilíbrio"

func select_shop_skin(skin_id: String) -> void:
	if not SKINS.has(skin_id):
		return
	selected_shop_skin = skin_id
	update_shop_ui()
	flash_alpha = maxf(flash_alpha, 0.035)

func activate_selected_shop_skin() -> void:
	buy_or_select_skin(selected_shop_skin)

func update_shop_ui() -> void:
	if not SKINS.has(selected_shop_skin):
		selected_shop_skin = selected_skin
	if not SKINS.has(selected_shop_skin):
		selected_shop_skin = "nucleo_errante"
	var data: Dictionary = SKINS[selected_shop_skin]
	var skin_name: String = str(data["name"])
	var price: int = int(data["price"])
	var rarity: String = skin_rarity(selected_shop_skin)
	var owned: bool = bool(owned_skins.get(selected_shop_skin, false))
	var equipped: bool = selected_shop_skin == selected_skin
	var rarity_color: Color = rarity_color_text(rarity)

	shop_info_label.text = "Cristais %d  ·  Formas %d/%d" % [total_crystals, owned_skins.size(), SKINS.size()]
	shop_preview_name_label.text = skin_name
	shop_preview_meta_label.text = "%s  ·  %s" % [rarity, skin_affinity_text(selected_shop_skin)]
	shop_preview_meta_label.add_theme_color_override("font_color", rarity_color)
	shop_preview_desc_label.text = "%s
%s" % [str(data["desc"]), skin_effect_text(selected_shop_skin)]

	if equipped:
		shop_action_button.text = "EQUIPADO"
		shop_action_button.add_theme_stylebox_override("normal", make_button_style(Color(0.10, 0.23, 0.22, 0.80), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.54)))
	elif owned:
		shop_action_button.text = "EQUIPAR FORMA"
		shop_action_button.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.18, 0.24, 0.82), Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.52)))
	elif total_crystals >= price:
		shop_action_button.text = "DESPERTAR  ·  %d" % price
		shop_action_button.add_theme_stylebox_override("normal", make_button_style(Color(0.12, 0.11, 0.05, 0.82), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.58)))
	else:
		shop_action_button.text = "FALTAM %d CRISTAIS" % max(0, price - total_crystals)
		shop_action_button.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.10, 0.16, 0.68), Color(0.48, 0.63, 0.76, 0.22)))

	for skin_id in shop_skin_buttons.keys():
		var b: Button = shop_skin_buttons[skin_id]
		var item_data: Dictionary = SKINS[skin_id]
		var item_name: String = str(item_data["name"])
		var item_rarity: String = skin_rarity(skin_id)
		var item_owned: bool = bool(owned_skins.get(skin_id, false))
		var item_equipped: bool = skin_id == selected_skin
		var item_selected: bool = skin_id == selected_shop_skin
		var item_price: int = int(item_data["price"])
		var state: String = "EQUIPADO" if item_equipped else ("LIBERADO" if item_owned else "%d" % item_price)
		b.text = "%s
%s · %s" % [item_name, item_rarity, state]
		var item_color: Color = rarity_color_text(item_rarity)
		if item_selected:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.06, 0.15, 0.22, 0.86), Color(item_color.r, item_color.g, item_color.b, 0.72)))
		elif item_owned:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.04, 0.13, 0.19, 0.66), Color(item_color.r, item_color.g, item_color.b, 0.36)))
		else:
			b.add_theme_stylebox_override("normal", make_button_style(Color(0.025, 0.07, 0.12, 0.54), Color(item_color.r, item_color.g, item_color.b, 0.18)))
	update_neo_pavilion()

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
		update_player_skin_visuals()
		save_game()
		update_shop_ui()
		trigger_form_unlock(skin_id)
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
	update_neo_menu()

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
	update_neo_menu()
	show_status("+180 ESSÊNCIA DIÁRIA", C_GOLD)
	spawn_shockwave(player.position, C_GOLD, 40.0, 250.0, 0.65)

func get_biome_index_for_distance(value: float) -> int:
	var idx: int = 0
	for i in range(BIOMES.size()):
		var biome: Dictionary = BIOMES[i]
		if value >= float(biome["at"]):
			idx = i
	return idx

func get_current_biome() -> Dictionary:
	return BIOMES[current_biome_index]

func get_biome_accent() -> Color:
	var biome: Dictionary = get_current_biome()
	return biome["accent"]

func update_biome_state() -> void:
	var next_index: int = get_biome_index_for_distance(distance)
	if next_index != current_biome_index:
		current_biome_index = next_index
		var biome: Dictionary = get_current_biome()
		show_status(str(biome["name"]).to_upper(), biome["accent"])
		flash_alpha = maxf(flash_alpha, 0.13)
		spawn_shockwave(player.position, biome["accent"], 48.0, 260.0, 0.70)

func start_crystal_rain() -> void:
	crystal_rain_active = 4.8
	crystal_rain_timer = rng.randf_range(18.0, 28.0)
	show_status("CHUVA DE CRISTAIS", C_GOLD)
	flash_alpha = maxf(flash_alpha, 0.12)
	spawn_shockwave(player.position, C_GOLD, 52.0, 280.0, 0.74)

func get_next_unlock_hint() -> String:
	var cheapest_name: String = ""
	var cheapest_price: int = 999999
	for skin_id in SKINS.keys():
		if bool(owned_skins.get(skin_id, false)):
			continue
		var data: Dictionary = SKINS[skin_id]
		var price: int = int(data["price"])
		if price < cheapest_price:
			cheapest_price = price
			cheapest_name = str(data["name"])
	if cheapest_name == "":
		return "Todas as formas principais foram despertas."
	var missing: int = max(0, cheapest_price - total_crystals)
	return "Próxima forma: %s  •  faltam %d cristais" % [cheapest_name, missing]

func spawn_skin_trail(real_delta: float) -> void:
	var base_c: Color = skin_color(selected_skin)
	var secondary_c: Color = skin_secondary_color(selected_skin)
	var variant: int = skin_shape_variant(selected_skin)
	var chance: float = 0.70 + float(variant) * 0.055
	if flow_timer > 0.0:
		chance = 1.0
	if rng.randf() > chance:
		return

	var offset_x: float = rng.randf_range(-18.0, 18.0)
	var trail_pos: Vector2 = player.position + Vector2(offset_x, rng.randf_range(46.0, 86.0))
	var duration: float = 0.38 + float(variant) * 0.035
	var size: float = 18.0 + float(variant) * 3.5
	var trail: Dictionary = {
		"pos": trail_pos,
		"start_pos": player.position + Vector2(offset_x * 0.35, 16.0),
		"color": base_c,
		"secondary": secondary_c,
		"variant": variant,
		"duration": duration,
		"age": 0.0,
		"size": size,
		"rot": player.rotation + rng.randf_range(-0.18, 0.18)
	}
	skin_trails.append(trail)
	if skin_trails.size() > 54:
		skin_trails.remove_at(0)

	# partículas extras mais visíveis, por assinatura da forma
	match variant:
		1:
			spawn_particle(trail_pos, Color(base_c.r, base_c.g, base_c.b, 0.50), 2, 0.42)
		2:
			spawn_particle(trail_pos, Color(secondary_c.r, secondary_c.g, secondary_c.b, 0.58), 2, 0.36)
		3:
			spawn_particle(trail_pos, Color(base_c.r, base_c.g, base_c.b, 0.44), 3, 0.62)
		4:
			spawn_particle(trail_pos, Color(base_c.r, base_c.g, base_c.b, 0.62), 3, 0.42)
		_:
			spawn_particle(trail_pos, Color(base_c.r, base_c.g, base_c.b, 0.38), 1, 0.34)

func update_game(delta: float, real_delta: float) -> void:
	run_time += real_delta
	difficulty += real_delta * 0.018
	speed = minf(820.0, 390.0 + distance * 0.03 + difficulty * 42.0)
	distance += speed * delta * 0.045
	update_biome_state()
	crystal_rain_timer -= real_delta
	if crystal_rain_active > 0.0:
		crystal_rain_active = maxf(0.0, crystal_rain_active - real_delta)
	elif crystal_rain_timer <= 0.0 and distance > 350.0:
		start_crystal_rain()
	var flow_multiplier: float = 1.65 + (float(unlocked_circle_count()) * 0.03 if flow_timer > 0.0 else 0.0) if flow_timer > 0.0 else 1.0
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
	update_player_skin_visuals()
	var visual_c: Color = skin_color(selected_skin)
	var visual_s: Color = skin_secondary_color(selected_skin)
	player_glow.color = Color(visual_s.r, visual_s.g, visual_s.b, 0.22 + clampf(resonance_value / 100.0, 0.0, 0.22))
	player_ring.color = Color(visual_c.r, visual_c.g, visual_c.b, 0.10 + clampf(resonance_value / 120.0, 0.0, 0.22))
	if dash_timer > 0.0:
		spawn_particle(player.position, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.82), 9, 0.42)
		if rng.randf() < 0.55:
			spawn_afterimage(player.position, player_core.color, 0.30)
	if flow_timer > 0.0 and rng.randf() < 0.50:
		spawn_particle(player.position + Vector2(rng.randf_range(-68.0, 68.0), rng.randf_range(-24.0, 62.0)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.46), 3, 0.36)
	spawn_skin_trail(real_delta)
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
		if crystal_rain_active > 0.0:
			crystal_spawn_timer = rng.randf_range(0.12, 0.24)
		else:
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
	var biome: Dictionary = get_current_biome()
	biome_label.text = str(biome["name"])
	biome_label.add_theme_color_override("font_color", biome["accent"])
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
	var pattern: int = rng.randi_range(0, 6)
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
	elif pattern == 4:
		spawn_obstacle(rng.randi_range(0, 2), "corrente_qi")
	elif pattern == 5:
		var first: int = rng.randi_range(0, 2)
		spawn_obstacle(first, "portal_quebrado")
		spawn_obstacle((first + 1) % 3, "fragmento_caido")
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
	var lanes_to_spawn: int = 2 if crystal_rain_active > 0.0 else 1
	for line_index in range(lanes_to_spawn):
		var lane: int = rng.randi_range(0, 2)
		var count: int = rng.randi_range(4, 7) if crystal_rain_active > 0.0 else rng.randi_range(3, 6)
		for i in range(count):
			var rare_chance: float = 0.055 + float(current_biome_index) * 0.012
			if crystal_rain_active > 0.0:
				rare_chance += 0.10
			var is_rare: bool = rng.randf() < rare_chance
			var crystal: Dictionary = {
				"type": "crystal",
				"kind": "raro" if is_rare else "espiritual",
				"lane": lane,
				"pos": Vector2(screen_lane_x(lane), -80.0 - float(i) * 72.0 - float(line_index) * 36.0),
				"radius": 34.0 if is_rare else 28.0,
				"value": 6 if is_rare else 1,
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
			var magnet_range: float = 220.0 + (42.0 if has_resonance_circle(2) else 0.0)
			if magnet_timer > 0.0 and dist_to_player < magnet_range:
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
	var is_rare: bool = str(e.get("kind", "espiritual")) == "raro"
	if is_rare and has_resonance_circle(4):
		value += 2
	if is_rare:
		rare_crystals_run += 1
	crystals_run += value * multiplier
	score += (90 if is_rare else 30) * multiplier
	combo += 1
	combo_pop_timer = 1.0
	var resonance_gain: float = (3.8 if is_rare else 0.8) + (0.22 if has_resonance_circle(1) else 0.0)
	resonance_value = minf(100.0, resonance_value + resonance_gain)
	var crystal_pos: Vector2 = e["pos"]
	var particle_color: Color = C_GOLD if is_rare else get_biome_accent()
	spawn_particle(crystal_pos, Color(particle_color.r, particle_color.g, particle_color.b, 0.85), 18 if is_rare else 13, 0.58 if is_rare else 0.5)
	if is_rare:
		spawn_shockwave(crystal_pos, C_GOLD, 18.0, 92.0, 0.38)
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
	var bonus: int = 90 + combo * 5 + (35 if has_resonance_circle(3) else 0)
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
	if rare_crystals_run >= 3:
		missions.append("✓ Coletou 3 Cristais Raros")
	if current_biome_index >= 1:
		missions.append("✓ Alcançou o Vale de Jade")
	return missions

func calculate_xp_gain() -> int:
	var gain: int = int(distance * 0.06)
	gain += perfect_grazes * 9
	gain += flow_activations * 24
	gain += rare_crystals_run * 12
	gain += current_biome_index * 30
	gain += completed_run_missions.size() * 18
	gain += int(max(combo, 1) * 0.8)
	return max(gain, 8)

func game_over() -> void:
	screen = "result"
	if neo_ui != null:
		neo_ui.hide_all()
	completed_run_missions = calculate_run_missions()
	run_mission_bonus = completed_run_missions.size() * 75
	var old_circle_count: int = unlocked_circle_count()
	last_xp_gain = calculate_xp_gain()
	cultivation_xp += last_xp_gain
	circles_unlocked_run = max(0, unlocked_circle_count() - old_circle_count)
	total_crystals += crystals_run + run_mission_bonus
	var was_new_mark: bool = distance >= best_distance
	best_distance = maxf(best_distance, distance)
	save_game()
	result_reveal_timer = 0.0
	result_count_crystals = 0.0
	result_count_xp = 0.0
	result_target_crystals = crystals_run + run_mission_bonus
	result_target_xp = last_xp_gain
	result_badge_pulse = 0.0
	hud_layer.visible = false
	result_layer.visible = true
	menu_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	var new_mark: String = "Nova Marca de Ascensão!" if was_new_mark else "Progresso de cultivo registrado."
	var mission_text: String = "Nenhuma missão concluída"
	if completed_run_missions.size() > 0:
		mission_text = "\n".join(completed_run_missions)
	var circle_text: String = circle_unlock_text(unlocked_circle_count() - circles_unlocked_run, unlocked_circle_count())
	if circle_text == "":
		circle_text = next_circle_hint()
	var biome_reached: String = str(get_current_biome()["name"])
	result_summary_label.text = "%d m\n+0 XP  •  +0 Cristais" % int(distance)
	result_stats.text = "Pontuação: %d  •  Bioma: %s\nRaros: %d  •  Ressonâncias: %d  •  Fluxos: %d\nMaior Fluxo: x%d\n%s\n%s" % [score, biome_reached, rare_crystals_run, perfect_grazes, flow_activations, max(combo, 1), new_mark, circle_text]
	result_xp_label.text = "Núcleo: %s  •  XP %d  •  Círculos %d/%d" % [get_cultivation_stage_name(), cultivation_xp, unlocked_circle_count(), RESONANCE_CIRCLES.size()]
	result_xp_bar.value = get_stage_progress_percent()
	result_form_label.text = get_next_unlock_hint()
	result_form_bar.value = get_next_form_progress_percent()
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

	var remove_skin_trails: Array[int] = []
	for i: int in range(skin_trails.size()):
		var tr: Dictionary = skin_trails[i]
		var tr_age: float = float(tr["age"]) + delta
		tr["age"] = tr_age
		skin_trails[i] = tr
		if tr_age >= float(tr["duration"]):
			remove_skin_trails.append(i)
	remove_skin_trails.reverse()
	for idx: int in remove_skin_trails:
		skin_trails.remove_at(idx)

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

func skin_secondary_color(skin_id: String) -> Color:
	match skin_id:
		"semente_jade":
			return Color(0.74, 1.0, 0.83, 1.0)
		"orbe_celestial":
			return Color(0.92, 0.98, 1.0, 1.0)
		"coracao_nebular":
			return Color(0.22, 0.12, 0.42, 1.0)
		"essencia_dourada":
			return Color(1.0, 0.94, 0.70, 1.0)
		_:
			return Color(0.65, 0.96, 1.0, 1.0)

func skin_trail_name(skin_id: String) -> String:
	match skin_id:
		"semente_jade":
			return "Rastro de Jade"
		"orbe_celestial":
			return "Rastro Celestial"
		"coracao_nebular":
			return "Rastro Nebular"
		"essencia_dourada":
			return "Rastro Dourado"
		_:
			return "Rastro Cristalino"

func skin_shape_variant(skin_id: String) -> int:
	match skin_id:
		"semente_jade":
			return 1
		"orbe_celestial":
			return 2
		"coracao_nebular":
			return 3
		"essencia_dourada":
			return 4
		_:
			return 0

func skin_rarity_power(skin_id: String) -> float:
	match skin_rarity(skin_id):
		"Raro":
			return 1.15
		"Épico":
			return 1.35
		"Lendário":
			return 1.62
		"Celestial":
			return 1.85
		_:
			return 1.0

func trigger_form_unlock(skin_id: String) -> void:
	form_unlock_skin = skin_id
	form_unlock_name = str(SKINS.get(skin_id, {}).get("name", "Nova Forma"))
	form_unlock_timer = 2.8
	flash_alpha = maxf(flash_alpha, 0.20)
	camera_shake = maxf(camera_shake, 11.0)
	spawn_shockwave(player.position, skin_color(skin_id), 52.0, 330.0, 0.82)
	show_status("NOVA FORMA DESPERTA", skin_color(skin_id))
	for _i in range(34):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-96.0, 96.0), rng.randf_range(-96.0, 96.0))
		spawn_particle(particle_pos, Color(skin_color(skin_id).r, skin_color(skin_id).g, skin_color(skin_id).b, 0.86), 8, 0.72)

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
		"tutorial_seen": tutorial_seen,
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
			tutorial_seen = bool(parsed.get("tutorial_seen", false))
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
	draw_biome_overlay()
	draw_neo_cultivation_shell()
	draw_premium_menu_glow()
	draw_result_glow()
	draw_visual_reboot_showcases()
	draw_spiritual_lanes()
	draw_speed_lines()
	draw_afterimages()
	draw_entities()
	draw_skin_trails()
	draw_particles()
	draw_shockwaves()
	draw_player_aura()
	draw_resonance_circles()
	draw_dash_meter()
	draw_form_unlock_overlay()
	draw_flash_overlay()

func draw_biome_overlay() -> void:
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	var secondary: Color = biome["secondary"]
	if current_biome_index >= 1:
		draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(accent.r, accent.g, accent.b, 0.018 + float(current_biome_index) * 0.010))
	if crystal_rain_active > 0.0:
		var rain_alpha: float = 0.05 + 0.025 * sin(pulse_time * 8.0)
		draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, rain_alpha))
		for i in range(12):
			var x: float = fmod(float(i) * 71.0 + pulse_time * 95.0, VIEW_W + 90.0) - 45.0
			var y: float = fmod(float(i) * 131.0 + pulse_time * 230.0, VIEW_H + 160.0) - 80.0
			draw_line(Vector2(x, y), Vector2(x - 26.0, y + 54.0), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.15), 2.0)
	if current_biome_index == 2:
		for i in range(3):
			var p: Vector2 = Vector2(120.0 + float(i) * 210.0, 190.0 + sin(pulse_time * 0.4 + float(i)) * 18.0)
			draw_arc(p, 62.0, pulse_time * 0.2, pulse_time * 0.2 + PI * 1.35, 64, Color(secondary.r, secondary.g, secondary.b, 0.065), 3.0, true)
	elif current_biome_index == 3:
		var gate_center: Vector2 = Vector2(VIEW_W * 0.5, 210.0)
		draw_arc(gate_center, 155.0, PI * 1.05, PI * 1.95, 96, Color(accent.r, accent.g, accent.b, 0.16), 5.0, true)
		draw_circle(gate_center, 84.0, Color(secondary.r, secondary.g, secondary.b, 0.035))

func draw_capsule(center: Vector2, size: Vector2, color: Color) -> void:
	var half: Vector2 = size * 0.5
	var radius: float = size.y * 0.5
	draw_rect(Rect2(center - Vector2(half.x - radius, half.y), Vector2(size.x - size.y, size.y)), color)
	draw_circle(center - Vector2(half.x - radius, 0.0), radius, color)
	draw_circle(center + Vector2(half.x - radius, 0.0), radius, color)

func draw_holo_card(center: Vector2, size: Vector2, accent: Color, alpha: float) -> void:
	draw_capsule(center + Vector2(0.0, 10.0), size + Vector2(16.0, 16.0), Color(0.0, 0.0, 0.0, alpha * 0.24))
	draw_capsule(center, size, Color(0.025, 0.085, 0.130, alpha))
	draw_capsule(center, Vector2(size.x + 2.0, size.y + 2.0), Color(accent.r, accent.g, accent.b, alpha * 0.045))
	draw_line(center - Vector2(size.x * 0.34, size.y * 0.42), center + Vector2(size.x * 0.34, -size.y * 0.42), Color(accent.r, accent.g, accent.b, alpha * 0.18), 1.2)
	draw_line(center - Vector2(size.x * 0.38, -size.y * 0.34), center + Vector2(size.x * 0.22, size.y * 0.34), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha * 0.055), 1.0)

func draw_neo_grid(accent: Color) -> void:
	for i in range(9):
		var y: float = 230.0 + float(i) * 74.0 + sin(pulse_time * 0.32 + float(i)) * 8.0
		draw_line(Vector2(44.0, y), Vector2(VIEW_W - 44.0, y + sin(float(i)) * 18.0), Color(accent.r, accent.g, accent.b, 0.018), 1.0)
	for i in range(6):
		var x: float = 80.0 + float(i) * 112.0 + sin(pulse_time * 0.26 + float(i)) * 6.0
		draw_line(Vector2(x, 160.0), Vector2(x + sin(float(i)) * 26.0, VIEW_H - 120.0), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.012), 1.0)

func draw_neo_cultivation_shell() -> void:
	if screen != "menu" and screen != "shop" and screen != "cultivation":
		return
	var accent: Color = C_CELESTIAL
	if screen == "shop":
		accent = rarity_color_text(skin_rarity(selected_shop_skin))
	elif screen == "cultivation":
		accent = C_GOLD

	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(0.010, 0.026, 0.043, 0.62))
	draw_neo_grid(accent)

	var top_center: Vector2 = Vector2(VIEW_W * 0.5, 130.0)
	draw_circle(top_center, 310.0, Color(accent.r, accent.g, accent.b, 0.026))
	draw_circle(top_center + Vector2(0.0, 160.0), 460.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.012))

	if screen == "menu":
		draw_neo_menu_shell(accent)
	elif screen == "shop":
		draw_neo_shop_shell(accent)
	else:
		draw_neo_core_shell(accent)

func draw_neo_menu_shell(accent: Color) -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 326.0)
	draw_holo_card(Vector2(VIEW_W * 0.5, 650.0), Vector2(570.0, 330.0), accent, 0.20)
	draw_capsule(Vector2(VIEW_W * 0.5, 855.0), Vector2(585.0, 118.0), Color(0.025, 0.085, 0.130, 0.26))
	draw_line(Vector2(88.0, 855.0), Vector2(VIEW_W - 88.0, 855.0), Color(accent.r, accent.g, accent.b, 0.18), 1.2)
	for i in range(5):
		var r: float = 160.0 + float(i) * 26.0
		var a: float = pulse_time * (0.12 + float(i) * 0.025)
		draw_arc(center, r, a, a + PI * 1.24, 108, Color(accent.r, accent.g, accent.b, 0.040 - float(i) * 0.004), 1.6, true)
	draw_circle(center, 110.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_line(Vector2(160.0, 430.0), Vector2(560.0, 430.0), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.045), 1.0)

func draw_neo_shop_shell(accent: Color) -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 310.0)
	draw_holo_card(Vector2(VIEW_W * 0.5, 305.0), Vector2(610.0, 465.0), accent, 0.18)
	draw_holo_card(Vector2(VIEW_W * 0.5, 610.0), Vector2(545.0, 148.0), accent, 0.16)
	draw_capsule(Vector2(VIEW_W * 0.5, 845.0), Vector2(600.0, 265.0), Color(0.020, 0.070, 0.115, 0.28))
	for i in range(5):
		var x: float = 115.0 + float(i) * 122.0
		draw_circle(Vector2(x, 842.0), 47.0, Color(accent.r, accent.g, accent.b, 0.035))
		draw_arc(Vector2(x, 842.0), 51.0, pulse_time * 0.25 + float(i), pulse_time * 0.25 + float(i) + PI * 1.15, 48, Color(accent.r, accent.g, accent.b, 0.12), 1.5, true)
	draw_circle(center, 182.0, Color(accent.r, accent.g, accent.b, 0.023))
	draw_line(Vector2(110.0, 548.0), Vector2(610.0, 548.0), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.045), 1.0)

func draw_neo_core_shell(accent: Color) -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 318.0)
	draw_holo_card(center, Vector2(612.0, 505.0), accent, 0.17)
	draw_holo_card(Vector2(VIEW_W * 0.5, 602.0), Vector2(540.0, 140.0), C_CELESTIAL, 0.14)
	draw_capsule(Vector2(VIEW_W * 0.5, 845.0), Vector2(600.0, 280.0), Color(0.020, 0.070, 0.115, 0.26))
	var tech_positions: Array[Vector2] = [Vector2(138.0, 832.0), Vector2(360.0, 856.0), Vector2(582.0, 832.0)]
	for i in range(tech_positions.size()):
		var p: Vector2 = tech_positions[i]
		var c: Color = [C_CELESTIAL, C_JADE, C_GOLD][i]
		draw_circle(p, 72.0, Color(c.r, c.g, c.b, 0.045))
		draw_arc(p, 78.0, -pulse_time * 0.16 + float(i), -pulse_time * 0.16 + float(i) + PI * 1.40, 64, Color(c.r, c.g, c.b, 0.13), 2.0, true)
	draw_line(Vector2(160.0, 576.0), Vector2(560.0, 576.0), Color(accent.r, accent.g, accent.b, 0.10), 1.1)


func draw_visual_reboot_showcases() -> void:
	if screen == "menu":
		draw_menu_showcase()
	elif screen == "shop":
		draw_shop_showcase()
	elif screen == "cultivation":
		draw_cultivation_chamber()

func draw_orb_preview(center: Vector2, radius: float, skin_id: String, power: float) -> void:
	var c: Color = skin_color(skin_id)
	var s: Color = skin_secondary_color(skin_id)
	var variant: int = skin_shape_variant(skin_id)
	var rarity_power: float = skin_rarity_power(skin_id)
	draw_circle(center, radius * 2.70 * rarity_power, Color(c.r, c.g, c.b, 0.045 + power * 0.022))
	draw_circle(center, radius * 1.70, Color(s.r, s.g, s.b, 0.060 + power * 0.030))

	for i in range(5):
		var r: float = radius * (1.34 + float(i) * 0.19) + sin(pulse_time * (1.0 + float(i) * 0.1) + float(i)) * (4.0 + float(variant))
		var start_angle: float = pulse_time * (0.22 + float(i) * 0.052 + float(variant) * 0.012) + float(i) * 0.75
		var ring_color: Color = c if i % 2 == 0 else s
		var alpha: float = 0.12 - float(i) * 0.010 + power * 0.040
		if variant == 4:
			alpha += 0.035
		draw_arc(center, r, start_angle, start_angle + PI * (1.14 + float(i % 2) * 0.22), 96, Color(ring_color.r, ring_color.g, ring_color.b, alpha), 2.2 + float(variant) * 0.12, true)
		draw_arc(center, r * 0.82, -start_angle, -start_angle + PI * 0.62, 64, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha * 0.45), 1.2, true)

	var points: PackedVector2Array = PackedVector2Array()
	var sides: int = 8
	if variant == 1:
		sides = 10
	elif variant == 2:
		sides = 12
	elif variant == 3:
		sides = 9
	elif variant == 4:
		sides = 14

	for i in range(sides):
		var a: float = TAU * float(i) / float(sides) + pulse_time * (0.10 + float(variant) * 0.015)
		var alt: bool = i % 2 == 0
		var rr: float = radius * (0.66 if alt else 0.44)
		if variant == 1:
			rr = radius * (0.70 if alt else 0.50)
		elif variant == 2:
			rr = radius * (0.74 if alt else 0.36)
		elif variant == 3:
			rr = radius * (0.70 if alt else 0.42) + sin(float(i) + pulse_time * 1.6) * 2.0
		elif variant == 4:
			rr = radius * (0.82 if alt else 0.52)
		points.append(center + Vector2(cos(a), sin(a)) * rr)

	draw_colored_polygon(points, Color(c.r, c.g, c.b, 0.78))
	var outline: PackedVector2Array = PackedVector2Array()
	for outline_point in points:
		outline.append(outline_point)
	outline.append(points[0])
	draw_polyline(outline, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.62), 2.0)

	if variant == 1:
		for i in range(4):
			var a: float = pulse_time * 0.35 + float(i) * PI * 0.5
			draw_line(center, center + Vector2(cos(a), sin(a)) * radius * 0.86, Color(s.r, s.g, s.b, 0.20), 2.0)
	elif variant == 2:
		draw_circle(center, radius * 0.46, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.18))
	elif variant == 3:
		draw_circle(center + Vector2(sin(pulse_time * 1.3) * 4.0, cos(pulse_time * 1.1) * 4.0), radius * 0.42, Color(0.12, 0.06, 0.22, 0.34))
	elif variant == 4:
		for i in range(6):
			var a: float = pulse_time * 0.45 + float(i) * TAU / 6.0
			var p: Vector2 = center + Vector2(cos(a), sin(a)) * radius * 0.98
			draw_circle(p, 3.2, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.62))

	draw_circle(center, radius * 0.18 + sin(pulse_time * 4.0) * 2.0, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.82))

func draw_mini_form_node(center: Vector2, skin_id: String, selected: bool, locked: bool) -> void:
	var c: Color = skin_color(skin_id)
	var alpha: float = 0.42 if locked else 0.86
	var outer: float = 28.0 if selected else 22.0
	draw_circle(center, outer + 18.0, Color(c.r, c.g, c.b, 0.055))
	draw_arc(center, outer + 8.0, pulse_time * 0.32, pulse_time * 0.32 + PI * 1.42, 48, Color(c.r, c.g, c.b, 0.18 + (0.12 if selected else 0.0)), 2.0, true)
	draw_circle(center, outer, Color(c.r, c.g, c.b, alpha * 0.55))
	draw_circle(center, outer * 0.42, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha * 0.78))
	if locked:
		draw_line(center + Vector2(-18.0, -18.0), center + Vector2(18.0, 18.0), Color(0.7, 0.85, 1.0, 0.26), 2.0)

func draw_menu_showcase() -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 320.0)
	draw_circle(center, 245.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.030))
	draw_circle(center, 160.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.040))
	draw_orb_preview(center, 58.0, selected_skin, 0.5)
	var count: int = unlocked_circle_count()
	for i in range(RESONANCE_CIRCLES.size()):
		var c: Color = RESONANCE_CIRCLES[i]["color"]
		var r: float = 104.0 + float(i) * 17.0
		var a: float = pulse_time * (0.18 + float(i) * 0.025) + float(i) * 0.55
		var unlocked: bool = i < count
		var alpha: float = 0.16 if unlocked else 0.035
		draw_arc(center, r, a, a + PI * 1.22, 96, Color(c.r, c.g, c.b, alpha), 2.0, true)

func draw_shop_showcase() -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 300.0)
	var rarity: String = skin_rarity(selected_shop_skin)
	var c: Color = rarity_color_text(rarity)
	draw_circle(center, 230.0, Color(c.r, c.g, c.b, 0.030))
	draw_circle(center, 152.0, Color(c.r, c.g, c.b, 0.055))
	draw_orb_preview(center, 66.0, selected_shop_skin, 0.65)
	var skin_order: Array[String] = ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for i in range(skin_order.size()):
		var a: float = -PI * 0.86 + float(i) * (PI * 1.72 / 4.0)
		var pos: Vector2 = center + Vector2(cos(a), sin(a)) * 158.0
		var sid: String = skin_order[i]
		draw_mini_form_node(pos, sid, sid == selected_shop_skin, not bool(owned_skins.get(sid, false)))

func draw_cultivation_chamber() -> void:
	var center: Vector2 = Vector2(VIEW_W * 0.5, 312.0)
	draw_circle(center, 252.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.026))
	draw_circle(center, 178.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.038))
	draw_orb_preview(center, 62.0, selected_skin, 0.72)
	for i in range(RESONANCE_CIRCLES.size()):
		var data: Dictionary = RESONANCE_CIRCLES[i]
		var c: Color = data["color"]
		var unlocked: bool = i < unlocked_circle_count()
		var r: float = 108.0 + float(i) * 19.0
		var a: float = pulse_time * (0.22 + float(i) * 0.035) + float(i) * 0.60
		var alpha: float = 0.18 if unlocked else 0.045
		var width: float = 3.0 if unlocked else 1.5
		draw_arc(center, r, a, a + PI * 1.48, 112, Color(c.r, c.g, c.b, alpha), width, true)
		if not unlocked:
			draw_arc(center, r, a + PI * 1.65, a + PI * 1.92, 32, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.025), 1.0, true)
	var tech_centers: Array[Vector2] = [Vector2(137.0, 828.0), Vector2(360.0, 840.0), Vector2(583.0, 828.0)]
	var tech_colors: Array[Color] = [C_CELESTIAL, C_JADE, C_GOLD]
	for i in range(tech_centers.size()):
		var tc: Color = tech_colors[i]
		var p: Vector2 = tech_centers[i]
		draw_circle(p, 52.0, Color(tc.r, tc.g, tc.b, 0.045))
		draw_arc(p, 43.0, pulse_time * 0.5 + float(i), pulse_time * 0.5 + float(i) + PI * 1.24, 48, Color(tc.r, tc.g, tc.b, 0.24), 2.0, true)

func draw_result_badge(center: Vector2, label: String, value: String, color: Color, phase: float) -> void:
	var pulse: float = 1.0 + sin(result_badge_pulse * 2.2 + phase) * 0.018
	draw_circle(center, 72.0 * pulse, Color(color.r, color.g, color.b, 0.055))
	draw_arc(center, 64.0 * pulse, pulse_time * 0.22 + phase, pulse_time * 0.22 + phase + PI * 1.42, 80, Color(color.r, color.g, color.b, 0.18), 2.0, true)
	draw_arc(center, 49.0 * pulse, -pulse_time * 0.18 + phase, -pulse_time * 0.18 + phase + PI * 0.92, 64, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.065), 1.1, true)
	draw_string(ThemeDB.fallback_font, center + Vector2(-80.0, -10.0), value, HORIZONTAL_ALIGNMENT_CENTER, 160.0, 22, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.90))
	draw_string(ThemeDB.fallback_font, center + Vector2(-80.0, 20.0), label, HORIZONTAL_ALIGNMENT_CENTER, 160.0, 14, Color(0.78, 0.93, 1.0, 0.68))

func draw_mission_capsules() -> void:
	if screen != "result":
		return
	var shown: int = min(completed_run_missions.size(), 3)
	if shown <= 0:
		return
	var start_y: float = 465.0
	for i in range(shown):
		var text_value: String = completed_run_missions[i].replace("✓ ", "")
		if text_value.length() > 28:
			text_value = text_value.substr(0, 27) + "…"
		var center: Vector2 = Vector2(VIEW_W * 0.5, start_y + float(i) * 36.0)
		var color: Color = C_JADE if i % 2 == 0 else C_CELESTIAL
		draw_capsule(center, Vector2(470.0, 28.0), Color(color.r, color.g, color.b, 0.075))
		draw_string(ThemeDB.fallback_font, center + Vector2(-226.0, 6.0), "✓ " + text_value, HORIZONTAL_ALIGNMENT_LEFT, 452.0, 14, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.78))

func draw_result_glow() -> void:
	if screen != "result":
		return
	var center: Vector2 = Vector2(VIEW_W * 0.5, 260.0)
	var alpha_in: float = clampf(result_reveal_timer * 1.8, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(0.006, 0.018, 0.033, 0.28 * alpha_in))
	draw_circle(center, 310.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.040 * alpha_in))
	draw_circle(center + Vector2(0.0, 135.0), 430.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.018 * alpha_in))
	draw_arc(center, 205.0 + sin(pulse_time * 1.1) * 8.0, pulse_time * 0.16, pulse_time * 0.16 + PI * 1.55, 112, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.095 * alpha_in), 3.0, true)
	draw_arc(center, 252.0, -pulse_time * 0.11, -pulse_time * 0.11 + PI * 1.1, 112, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.038 * alpha_in), 1.6, true)
	draw_result_badge(Vector2(172.0, 392.0), "XP", "+%d" % int(result_count_xp), C_JADE, 0.0)
	draw_result_badge(Vector2(360.0, 392.0), "CRISTAIS", "+%d" % int(result_count_crystals), C_GOLD, 0.8)
	draw_result_badge(Vector2(548.0, 392.0), "BIOMA", str(get_current_biome()["name"]).split(" ")[0], C_CELESTIAL, 1.6)
	draw_mission_capsules()

func draw_premium_menu_glow() -> void:
	if screen != "menu":
		return
	var center: Vector2 = Vector2(VIEW_W * 0.5, 355.0)
	var glow_a: float = 0.030 + 0.014 * sin(pulse_time * 1.1)
	draw_circle(center, 360.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, glow_a))
	draw_circle(center + Vector2(0.0, 24.0), 220.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, glow_a * 0.66))
	for i in range(5):
		var radius: float = 145.0 + float(i) * 34.0 + sin(pulse_time * 0.9 + float(i)) * 4.0
		var alpha: float = 0.020 - float(i) * 0.002
		draw_arc(center, radius, pulse_time * 0.10 + float(i), PI * 1.45 + pulse_time * 0.10 + float(i), 92, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, alpha), 1.4, true)

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

func draw_dash_meter() -> void:
	if screen != "game" and screen != "countdown":
		return
	var center: Vector2 = Vector2(650.0, 1092.0)
	var cooldown_total: float = maxf(0.72, 1.15 - float(tech_level("dash")) * 0.08)
	var ready_ratio: float = 1.0 - clampf(dash_cooldown / cooldown_total, 0.0, 1.0)
	var accent: Color = C_JADE if ready_ratio >= 1.0 else get_biome_accent()
	draw_circle(center, 56.0, Color(0.02, 0.10, 0.16, 0.42))
	draw_arc(center, 46.0, -PI * 0.5, -PI * 0.5 + TAU * ready_ratio, 64, Color(accent.r, accent.g, accent.b, 0.88), 5.0, true)
	draw_circle(center, 24.0, Color(accent.r, accent.g, accent.b, 0.12 + ready_ratio * 0.10))
	if ready_ratio >= 1.0:
		draw_circle(center, 7.0 + sin(pulse_time * 5.0) * 1.5, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.82))
	else:
		draw_circle(center, 6.0, Color(0.70, 0.88, 1.0, 0.42))

func draw_form_unlock_overlay() -> void:
	if form_unlock_timer <= 0.0:
		return
	var t: float = clampf(form_unlock_timer / 2.8, 0.0, 1.0)
	var alpha: float = minf(1.0, t * 1.8)
	var c: Color = skin_color(form_unlock_skin)
	var center: Vector2 = Vector2(VIEW_W * 0.5, VIEW_H * 0.36)
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(0.0, 0.0, 0.0, 0.18 * alpha))
	draw_circle(center, 260.0 * (1.0 + (1.0 - t) * 0.22), Color(c.r, c.g, c.b, 0.055 * alpha))
	draw_orb_preview(center, 62.0 + sin(pulse_time * 4.0) * 2.0, form_unlock_skin, 0.85)
	draw_arc(center, 158.0, pulse_time * 0.8, pulse_time * 0.8 + PI * 1.4, 120, Color(c.r, c.g, c.b, 0.26 * alpha), 3.0, true)
	draw_arc(center, 196.0, -pulse_time * 0.6, -pulse_time * 0.6 + PI * 1.1, 120, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.13 * alpha), 2.0, true)
	draw_string(ThemeDB.fallback_font, Vector2(112.0, center.y + 230.0), "NOVA FORMA DESPERTA", HORIZONTAL_ALIGNMENT_CENTER, 496.0, 32, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha))
	draw_string(ThemeDB.fallback_font, Vector2(112.0, center.y + 278.0), form_unlock_name, HORIZONTAL_ALIGNMENT_CENTER, 496.0, 28, Color(c.r, c.g, c.b, alpha))
	draw_string(ThemeDB.fallback_font, Vector2(112.0, center.y + 322.0), skin_trail_name(form_unlock_skin), HORIZONTAL_ALIGNMENT_CENTER, 496.0, 20, Color(0.82, 0.96, 1.0, 0.82 * alpha))

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
	var biome: Dictionary = get_current_biome()
	var deep_color: Color = biome["deep"]
	var mist_color: Color = biome["mist"]
	var accent_color: Color = biome["accent"]
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), deep_color)
	for y in range(0, int(VIEW_H), 64):
		var t: float = float(y) / VIEW_H
		var alpha_layer: float = 0.10 + 0.06 * sin((float(y) + pulse_time * 34.0) * 0.01)
		var layer_color: Color = mist_color.lerp(accent_color, t * 0.20)
		layer_color.a = alpha_layer
		draw_rect(Rect2(0.0, float(y), VIEW_W, 64.0), layer_color)

	var moon_pos: Vector2 = Vector2(VIEW_W * 0.78, 155.0 + sin(pulse_time * 0.18) * 8.0)
	draw_circle(moon_pos, 92.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.045))
	draw_circle(moon_pos, 54.0, Color(0.88, 0.98, 1.0, 0.11))
	draw_circle(moon_pos + Vector2(10.0, -4.0), 40.0, Color(0.94, 1.0, 1.0, 0.13))

	for mountain in mountains:
		var mx: float = float(mountain["x"])
		var my: float = float(mountain["y"])
		var mw: float = float(mountain["w"])
		var mh: float = float(mountain["h"])
		var ma: float = float(mountain["alpha"])
		draw_floating_mountain(Vector2(mx, my), mw, mh, Color(accent_color.r, accent_color.g, accent_color.b, ma))

	for s in stars:
		var star_pos: Vector2 = s["pos"]
		var star_size: float = float(s["size"])
		var star_alpha: float = float(s["alpha"])
		draw_circle(star_pos, star_size, Color(accent_color.r, accent_color.g, accent_color.b, star_alpha))

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
	var lane_accent: Color = get_biome_accent()
	var path_color: Color = Color(lane_accent.r, lane_accent.g, lane_accent.b, 0.08)
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
		draw_line(Vector2(x, 0.0), Vector2(x, VIEW_H), Color(lane_accent.r, lane_accent.g, lane_accent.b, flow_alpha * 0.38), 1.4)
	for i in range(9):
		var y: float = fmod(pulse_time * 95.0 + float(i) * 155.0, VIEW_H + 160.0) - 80.0
		draw_arc(Vector2(VIEW_W * 0.5, y), 220.0, PI * 0.05, PI * 0.95, 42, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.055), 2.0, true)

func draw_entities() -> void:
	for e in entities:
		var entity_type: String = str(e.get("type", ""))
		var p: Vector2 = e["pos"]
		var rot: float = float(e.get("rot", 0.0))
		if entity_type == "crystal":
			var crystal_kind: String = str(e.get("kind", "espiritual"))
			if crystal_kind == "raro":
				draw_crystal(p, 28.0, C_GOLD, rot)
			else:
				draw_crystal(p, 22.0, get_biome_accent(), rot)
		elif entity_type == "power":
			draw_powerup(p, str(e.get("kind", "")), rot)
		else:
			draw_obstacle_by_kind(p, str(e.get("kind", "")), rot)

func draw_skin_trails() -> void:
	for tr in skin_trails:
		var age: float = float(tr["age"])
		var duration: float = maxf(0.001, float(tr["duration"]))
		var t: float = clampf(age / duration, 0.0, 1.0)
		var alpha: float = (1.0 - t) * 0.55
		var p: Vector2 = tr["pos"]
		var start_p: Vector2 = tr["start_pos"]
		var c: Color = tr["color"]
		var secondary_c: Color = tr["secondary"]
		var variant: int = int(tr["variant"])
		var size_v: float = float(tr["size"]) * (1.0 - t * 0.52)
		var rot_v: float = float(tr["rot"]) + t * 0.35

		draw_line(start_p, p, Color(c.r, c.g, c.b, alpha * 0.42), 6.0 * (1.0 - t) + 1.0)
		draw_line(start_p + Vector2(0.0, 10.0), p + Vector2(0.0, 26.0), Color(secondary_c.r, secondary_c.g, secondary_c.b, alpha * 0.22), 3.0 * (1.0 - t) + 1.0)

		match variant:
			1:
				draw_arc(p, size_v * 1.45, rot_v, rot_v + PI * 1.25, 48, Color(c.r, c.g, c.b, alpha * 0.58), 2.0, true)
				draw_circle(p, size_v * 0.34, Color(secondary_c.r, secondary_c.g, secondary_c.b, alpha * 0.42))
			2:
				draw_arc(p, size_v * 1.75, rot_v, rot_v + PI * 1.60, 64, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha * 0.44), 1.8, true)
				draw_circle(p, size_v * 0.28, Color(secondary_c.r, secondary_c.g, secondary_c.b, alpha * 0.62))
			3:
				draw_circle(p, size_v * 1.30, Color(c.r, c.g, c.b, alpha * 0.13))
				draw_circle(p + Vector2(sin(pulse_time + age) * 10.0, cos(pulse_time + age) * 7.0), size_v * 0.52, Color(secondary_c.r, secondary_c.g, secondary_c.b, alpha * 0.30))
			4:
				draw_arc(p, size_v * 1.60, rot_v, rot_v + TAU * 0.86, 64, Color(c.r, c.g, c.b, alpha * 0.66), 2.6, true)
				for j: int in range(3):
					var a: float = rot_v + float(j) * TAU / 3.0
					draw_circle(p + Vector2(cos(a), sin(a)) * size_v * 0.74, 2.4, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, alpha * 0.82))
			_:
				draw_circle(p, size_v * 0.46, Color(c.r, c.g, c.b, alpha * 0.50))
				draw_arc(p, size_v * 1.2, rot_v, rot_v + PI, 40, Color(c.r, c.g, c.b, alpha * 0.30), 1.5, true)

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
	var p: Vector2 = player.position
	var c: Color = skin_color(selected_skin)
	var s: Color = skin_secondary_color(selected_skin)
	var variant: int = skin_shape_variant(selected_skin)
	var rarity_power: float = skin_rarity_power(selected_skin)
	var aura_power: float = clampf(resonance_value / 100.0, 0.0, 1.0)
	if flow_timer > 0.0:
		aura_power = 1.0

	draw_circle(p, 74.0 * rarity_power, Color(c.r, c.g, c.b, 0.038 + aura_power * 0.055))
	draw_circle(p, 48.0 * rarity_power, Color(s.r, s.g, s.b, 0.030 + aura_power * 0.035))
	for i in range(3 + min(variant, 2)):
		var r: float = 50.0 + float(i) * 13.0 + sin(pulse_time * 2.0 + float(i)) * 4.0
		var a: float = pulse_time * (0.55 + float(i) * 0.08) + float(i)
		var ring_c: Color = c if i % 2 == 0 else s
		draw_arc(p, r, a, a + PI * (1.0 + float(variant) * 0.08), 72, Color(ring_c.r, ring_c.g, ring_c.b, 0.10 + aura_power * 0.10), 2.0, true)

	var sides: int = 4
	if variant == 1:
		sides = 6
	elif variant == 2:
		sides = 8
	elif variant == 3:
		sides = 5
	elif variant == 4:
		sides = 10

	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(sides):
		var a: float = TAU * float(i) / float(sides) + player.rotation + pulse_time * (0.05 + float(variant) * 0.015)
		var rr: float = 29.0 if i % 2 == 0 else 21.0
		if variant == 0:
			rr = 34.0 if i % 2 == 0 else 24.0
		elif variant == 1:
			rr = 33.0 if i % 2 == 0 else 23.0
		elif variant == 2:
			rr = 36.0 if i % 2 == 0 else 18.0
		elif variant == 3:
			rr = 38.0 if i % 2 == 0 else 22.0
		elif variant == 4:
			rr = 39.0 if i % 2 == 0 else 25.0
		pts.append(p + Vector2(cos(a), sin(a)) * rr * player.scale.x)
	draw_colored_polygon(pts, Color(c.r, c.g, c.b, 0.84))
	var outline: PackedVector2Array = PackedVector2Array()
	for point in pts:
		outline.append(point)
	outline.append(pts[0])
	draw_polyline(outline, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.70), 2.2)

	if variant == 3:
		draw_circle(p, 18.0, Color(0.12, 0.05, 0.23, 0.38))
	if variant == 4:
		for i in range(5):
			var a: float = pulse_time * 0.55 + float(i) * TAU / 5.0
			draw_circle(p + Vector2(cos(a), sin(a)) * 43.0, 3.5, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.66))

	draw_circle(p, 8.0 + sin(pulse_time * 5.0) * 1.4, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.86))
	if flow_timer > 0.0:
		draw_circle(p, 158.0 + sin(pulse_time * 6.0) * 8.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.10))
		draw_arc(p, 148.0, -pulse_time * 1.2, -pulse_time * 1.2 + PI * 1.55, 96, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.26), 3.0, true)
	if dash_timer > 0.0:
		draw_circle(p, 132.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.10))

func draw_resonance_circles() -> void:
	if player == null:
		return
	var count: int = unlocked_circle_count()
	if count <= 0:
		return
	var p: Vector2 = player.position
	for i in range(count):
		var idx: int = i + 1
		var c: Color = circle_color(idx)
		var base_radius: float = 92.0 + float(i) * 18.0
		var pulse: float = sin(pulse_time * (1.4 + float(i) * 0.16) + float(i)) * 5.0
		var radius: float = base_radius + pulse
		var start_angle: float = pulse_time * (0.42 + float(i) * 0.09) + float(i) * 0.75
		var arc_len: float = PI * (1.10 + float(i % 2) * 0.18)
		var alpha: float = 0.12 + float(i) * 0.025
		if flow_timer > 0.0:
			alpha += 0.08
		draw_arc(p, radius, start_angle, start_angle + arc_len, 96, Color(c.r, c.g, c.b, alpha), 2.2 + float(i) * 0.28, true)
		draw_arc(p, radius, start_angle + PI, start_angle + PI + arc_len * 0.48, 64, Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, alpha * 0.52), 1.2, true)
		var node_angle: float = start_angle + arc_len
		var node_pos: Vector2 = p + Vector2(cos(node_angle), sin(node_angle)) * radius
		draw_circle(node_pos, 4.0 + float(i) * 0.3, Color(c.r, c.g, c.b, alpha * 1.9))

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
	elif kind == "corrente_qi":
		draw_qi_current(p, rot)
	elif kind == "portal_quebrado":
		draw_broken_portal(p, rot)
	else:
		draw_obstacle_spike(p, 48.0, Color(0.45, 0.88, 0.95, 0.75), rot)

func draw_qi_current(p: Vector2, rot: float) -> void:
	var accent: Color = get_biome_accent()
	draw_circle(p, 58.0, Color(accent.r, accent.g, accent.b, 0.12))
	for i in range(3):
		var offset: float = -28.0 + float(i) * 28.0
		var a: Vector2 = p + Vector2(-46.0, offset).rotated(rot)
		var b: Vector2 = p + Vector2(46.0, -offset).rotated(rot)
		draw_line(a, b, Color(accent.r, accent.g, accent.b, 0.72), 5.0)
		draw_line(a + Vector2(0, 7).rotated(rot), b + Vector2(0, 7).rotated(rot), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.32), 1.8)

func draw_broken_portal(p: Vector2, rot: float) -> void:
	var accent: Color = get_biome_accent()
	draw_circle(p, 66.0, Color(C_NEBULA.r, C_NEBULA.g, C_NEBULA.b, 0.14))
	draw_arc(p, 56.0, rot, rot + PI * 0.78, 40, Color(accent.r, accent.g, accent.b, 0.82), 6.0, true)
	draw_arc(p, 56.0, rot + PI * 1.10, rot + PI * 1.88, 40, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.66), 6.0, true)
	draw_line(p + Vector2(-22.0, -22.0).rotated(rot), p + Vector2(26.0, 28.0).rotated(rot), Color(C_PEARL.r, C_PEARL.g, C_PEARL.b, 0.50), 2.2)

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
