extends Node2D

const PlayerControllerBridge = preload("res://scripts/player/PlayerController.gd")
const SpawnerSystemBridge = preload("res://scripts/core/SpawnerSystem.gd")
const EntityFactoryBridge = preload("res://scripts/core/EntityFactory.gd")
const EntitySystemBridge = preload("res://scripts/core/EntitySystem.gd")
const RunStateSystemBridge = preload("res://scripts/core/RunStateSystem.gd")
const InputSystemBridge = preload("res://scripts/core/InputSystem.gd")
const VfxSystemBridge = preload("res://scripts/core/VfxSystem.gd")
const HudSystemBridge = preload("res://scripts/core/HudSystem.gd")
const ScreenFlowSystemBridge = preload("res://scripts/core/ScreenFlowSystem.gd")

# Fragment Rush: Corrida dos Cristais
# v2.0 - Wuxia Reborn: Stickman Marcial, Bambu, Jade e Fluxo Espiritual


var game_bg_sky_png: Texture2D = null
var game_bg_mountains_png: Texture2D = null
var game_bg_mid_png: Texture2D = null
var game_bg_front_png: Texture2D = null
var game_bg_fog_png: Texture2D = null
var game_bg_key: String = ""

var player_run_frames_png: Array[Texture2D] = []
var player_dash_frames_png: Array[Texture2D] = []
var player_hit_frames_png: Array[Texture2D] = []
var player_png_loaded: bool = false

var crystal_common_png: Texture2D = null
var crystal_rare_png: Texture2D = null
var crystal_legendary_png: Texture2D = null
var crystal_glow_png: Texture2D = null

var obstacle_bamboo_png: Texture2D = null
var obstacle_blade_png: Texture2D = null
var obstacle_cursed_png: Texture2D = null
var obstacle_fragment_png: Texture2D = null
var obstacle_rock_png: Texture2D = null

var entity_png_loaded: bool = false

var vfx_pickup_png: Texture2D = null
var vfx_dash_png: Texture2D = null
var vfx_trail_png: Texture2D = null
var vfx_impact_png: Texture2D = null
var vfx_combo_png: Texture2D = null
var vfx_aura_png: Texture2D = null
var vfx_png_loaded: bool = false
var vfx_png_sprites: Array[Dictionary] = []

var hud_icon_crystal_png: Texture2D = null
var hud_icon_dash_png: Texture2D = null
var hud_icon_combo_png: Texture2D = null
var hud_icon_pause_png: Texture2D = null
var hud_png_loaded: bool = false
var hud_panel_png: Texture2D = null

# Configurações centrais movidas para GameConfig autoload.

# ── State ─────────────────────────────────────────────────────────────────────
var screen: String = "menu"
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var player: Node2D
var player_controller: Node
var spawner_system: Node
var entity_system: Node
var input_system: Node
var vfx_system: Node
var hud_system: Node
var screen_flow_system: Node
var hud_layer: CanvasLayer
var menu_layer: CanvasLayer
var result_layer: CanvasLayer
var shop_layer: CanvasLayer
var pause_layer: CanvasLayer
var cultivation_layer: CanvasLayer
var tutorial_layer: CanvasLayer
var transition_layer: CanvasLayer
var neo_ui: FragmentUiController

# HUD labels
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
var biome_label: Label

# Menu nodes
var menu_card: Panel
var title_label: Label
var subtitle_label: Label
var start_button: Button
var shop_button: Button
var cultivation_button: Button
var daily_button: Button
var help_button: Button

# Result nodes
var result_card: Panel
var result_title: Label
var result_summary_label: Label
var result_stats: Label
var result_xp_label: Label
var result_xp_bar: ProgressBar
var result_form_label: Label
var result_form_bar: ProgressBar
var restart_button: Button
var menu_button: Button

# Shop nodes (legacy layer)
var shop_card: Panel
var shop_info_label: Label
var shop_title_label: Label
var shop_preview_name_label: Label
var shop_preview_meta_label: Label
var shop_preview_desc_label: Label
var shop_action_button: Button
var close_shop_button: Button
var shop_skin_buttons: Dictionary = {}
var selected_shop_skin: String = "nucleo_errante"

# Cultivation (legacy layer)
var cultivation_card: Panel
var cultivation_stage_label: Label
var cultivation_next_circle_label: Label
var cultivation_close_button: Button
var cultivation_upgrade_buttons: Dictionary = {}

# Pause
var pause_card: Panel
var pause_title: Label
var pause_info_label: Label
var pause_button: Button
var resume_button: Button
var pause_menu_button: Button

# Tutorial
var tutorial_card: Panel
var tutorial_title: Label
var tutorial_text: Label
var tutorial_close_button: Button

# Transition
var transition_card: Panel
var transition_label: Label
var transition_subtitle: Label

# Result extra
var result_badge_pulse: float = 0.0
var result_summary_label_ref: Label  # alias
var result_xp_label_ref: Label

# ── Entities ──────────────────────────────────────────────────────────────────
var entities: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var shockwaves: Array[Dictionary] = []
var afterimages: Array[Dictionary] = []
var skin_trails: Array[Dictionary] = []
var bamboo_far: Array[Dictionary] = []
var bamboo_near: Array[Dictionary] = []
var lanterns: Array[Dictionary] = []
var mist_puffs: Array[Dictionary] = []
var falling_leaves: Array[Dictionary] = []

# ── Player state ──────────────────────────────────────────────────────────────
var player_lane: int = 1
var target_x: float = 0.0
var player_state: String = "running"   # running / moving_left / moving_right / dash / hit
var player_lean: float = 0.0
var player_lean_target: float = 0.0
var player_run_phase: float = 0.0
var player_hit_flash: float = 0.0
var dash_cooldown: float = 0.0
var dash_timer: float = 0.0
var invulnerable_timer: float = 0.0
var magnet_timer: float = 0.0
var slowmo_timer: float = 0.0
var resonance_value: float = 0.0
var crystal_rain_timer: float = 12.0
var crystal_rain_active: float = 0.0

# ── Run data ──────────────────────────────────────────────────────────────────
var distance: float = 0.0
var score: int = 0
var crystals_run: int = 0
var rare_crystals_run: int = 0
var dashes_used_run: int = 0
var perfect_grazes: int = 0
var combo: int = 0
var max_combo_run: int = 0
var best_distance: float = 0.0
var total_crystals: int = 0
var run_time: float = 0.0
var games_played_total: int = 0

# ── Save data ─────────────────────────────────────────────────────────────────
var selected_skin: String = "nucleo_errante"
var owned_skins: Dictionary = {"nucleo_errante": true}
var last_daily_reward: String = ""
var cultivation_xp: int = 0
var tutorial_seen: bool = false
var technique_levels: Dictionary = {"dash": 0, "jade": 0, "flow": 0}
var mission_progress: Dictionary = {}
var mission_completed: Dictionary = {}

# ── Timing / animation ───────────────────────────────────────────────────────
var spawn_timer: float = 0.0
var crystal_spawn_timer: float = 0.0
var power_spawn_timer: float = 6.0
var speed: float = 380.0
var difficulty: float = 0.0
var touch_start: Vector2 = Vector2.ZERO
var is_touching: bool = false
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
var current_biome_index: int = 0
var form_unlock_timer: float = 0.0
var form_unlock_name: String = ""
var form_unlock_skin: String = ""
var run_mission_bonus: int = 0
var completed_run_missions: Array[String] = []
var circles_unlocked_run: int = 0
var last_xp_gain: int = 0
var scrolled_distance: float = 0.0

# ── Ready ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	rng.randomize()
	load_save()
	_setup_environment_particles()
	build_game_nodes()
	build_ui()
	_bind_screen_flow_system()
	show_menu()
	if not tutorial_seen:
		show_tutorial()

func _setup_environment_particles() -> void:
	# Bamboo far-layer stalks (edges)
	var far_xs: Array[float] = [28.0, 70.0, 118.0, 595.0, 648.0, 692.0]
	for i in range(far_xs.size()):
		bamboo_far.append({
			"x": far_xs[i],
			"y_off": rng.randf() * 140.0,
			"seg": rng.randf_range(72.0, 108.0),
			"w": rng.randf_range(5.0, 9.0),
			"alpha": rng.randf_range(0.14, 0.28),
			"spd": rng.randf_range(0.18, 0.28)
		})
	# Bamboo near-layer stalks (edges, thicker)
	var near_xs: Array[float] = [14.0, 48.0, 666.0, 706.0]
	for i in range(near_xs.size()):
		bamboo_near.append({
			"x": near_xs[i],
			"y_off": rng.randf() * 120.0,
			"seg": rng.randf_range(60.0, 90.0),
			"w": rng.randf_range(9.0, 16.0),
			"alpha": rng.randf_range(0.30, 0.48),
			"spd": rng.randf_range(0.35, 0.50)
		})
	# Falling leaves
	for _i in range(22):
		falling_leaves.append({
			"x": rng.randf() * GameConfig.VIEW_W,
			"y": rng.randf() * GameConfig.VIEW_H,
			"vx": rng.randf_range(-18.0, 18.0),
			"vy": rng.randf_range(28.0, 65.0),
			"rot": rng.randf() * TAU,
			"rot_spd": rng.randf_range(-1.2, 1.2),
			"size": rng.randf_range(4.0, 9.0),
			"alpha": rng.randf_range(0.10, 0.28)
		})
	# Mist puffs
	for _i in range(8):
		mist_puffs.append({
			"x": rng.randf() * GameConfig.VIEW_W,
			"y": rng.randf() * GameConfig.VIEW_H,
			"w": rng.randf_range(120.0, 280.0),
			"h": rng.randf_range(30.0, 70.0),
			"vx": rng.randf_range(-6.0, 6.0),
			"vy": rng.randf_range(-8.0, -2.0),
			"alpha": rng.randf_range(0.04, 0.10),
			"phase": rng.randf() * TAU
		})

# ── Process ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	var real_delta: float = delta
	var game_delta: float = delta
	if slowmo_timer > 0.0 and screen == "game":
		game_delta *= 0.54
		slowmo_timer -= real_delta

	pulse_time += real_delta
	title_breathe = 1.0 + sin(pulse_time * 1.2) * 0.018
	flash_alpha = maxf(0.0, flash_alpha - real_delta * 2.8)
	combo_pop_timer = maxf(0.0, combo_pop_timer - real_delta * 5.0)

	_update_environment(real_delta)
	_update_impact_fx(real_delta)

	if screen == "countdown":
		_update_countdown(real_delta)
	elif screen == "game":
		_update_game(game_delta, real_delta)
	elif screen == "result":
		_update_result_motion(real_delta)
	else:
		if screen not in ["pause"]:
			_update_menu_motion(real_delta)
	_update_screen_shake(real_delta)
	queue_redraw()

# ── Input ─────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if input_system != null:
		input_system.handle_unhandled_input(event, screen)
		return

	if screen != "game":
		return

	if event is InputEventScreenTouch:
		var te: InputEventScreenTouch = event as InputEventScreenTouch
		if te.pressed:
			is_touching = true
			touch_start = te.position
		else:
			is_touching = false
			var sd: Vector2 = te.position - touch_start
			if absf(sd.x) > 65.0:
				move_lane(1 if sd.x > 0.0 else -1)
			elif absf(sd.y) < 80.0:
				do_dash()

	if event is InputEventScreenDrag:
		var de: InputEventScreenDrag = event as InputEventScreenDrag
		var dd: Vector2 = de.position - touch_start
		if absf(dd.x) > 90.0:
			move_lane(1 if dd.x > 0.0 else -1)
			touch_start = de.position

func _input(event: InputEvent) -> void:
	if input_system != null:
		input_system.handle_input(event, screen)
		return

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
	return PlayerControllerBridge.screen_lane_x(lane)

func build_game_nodes() -> void:
	player_controller = PlayerControllerBridge.new()
	player_controller.name = "PlayerController"
	add_child(player_controller)
	player_controller.setup(player_lane)
	player_controller.set_state(player_state)
	player_controller.reset_visual_motion()
	player_controller.reset_hit_flash()

	target_x = player_controller.target_x
	player = Node2D.new()
	player.name = "StickRunner"
	player.position = Vector2(target_x, GameConfig.PLAYER_Y)
	add_child(player)

	spawner_system = SpawnerSystemBridge.new()
	spawner_system.name = "SpawnerSystem"
	spawner_system.setup_rng(rng)
	add_child(spawner_system)

	entity_system = EntitySystemBridge.new()
	entity_system.name = "EntitySystem"
	entity_system.bind_entities(entities)
	add_child(entity_system)

	input_system = InputSystemBridge.new()
	input_system.name = "InputSystem"
	add_child(input_system)
	input_system.move_requested.connect(move_lane)
	input_system.dash_requested.connect(do_dash)
	input_system.pause_requested.connect(pause_game)
	input_system.resume_requested.connect(resume_game)

	vfx_system = VfxSystemBridge.new()
	vfx_system.name = "VfxSystem"
	vfx_system.setup_rng(rng)
	vfx_system.bind_effect_arrays(
		particles,
		shockwaves,
		afterimages,
		skin_trails,
		vfx_png_sprites
	)
	add_child(vfx_system)

	hud_system = HudSystemBridge.new()
	hud_system.name = "HudSystem"
	add_child(hud_system)

	screen_flow_system = ScreenFlowSystemBridge.new()
	screen_flow_system.name = "ScreenFlowSystem"
	add_child(screen_flow_system)


func set_player_state(new_state: String) -> void:
	if player_controller != null:
		player_controller.set_state(new_state)
		player_state = player_controller.get_state()
	else:
		player_state = new_state


func sync_player_state_from_controller() -> void:
	if player_controller != null:
		player_state = player_controller.get_state()


func sync_player_visual_from_controller() -> void:
	if player_controller != null:
		var visual_state: Dictionary = player_controller.get_visual_state()
		player_lean = visual_state["player_lean"]
		player_lean_target = visual_state["player_lean_target"]
		player_run_phase = visual_state["player_run_phase"]


func sync_player_hit_flash_from_controller() -> void:
	if player_controller != null:
		player_hit_flash = player_controller.get_hit_flash()


func sync_spawner_timers_from_system() -> void:
	if spawner_system != null:
		var timer_state: Dictionary = spawner_system.get_timer_state()
		spawn_timer = timer_state["spawn_timer"]
		crystal_spawn_timer = timer_state["crystal_spawn_timer"]
		power_spawn_timer = timer_state["power_spawn_timer"]


func trigger_player_hit_flash(value: float = 1.0) -> void:
	if player_controller != null:
		player_controller.trigger_hit_flash(value)
		player_hit_flash = player_controller.get_hit_flash()
	else:
		player_hit_flash = maxf(player_hit_flash, value)
func apply_run_state(state: Dictionary) -> void:
	score = int(state["score"])
	crystals_run = int(state["crystals_run"])
	rare_crystals_run = int(state["rare_crystals_run"])
	dashes_used_run = int(state["dashes_used_run"])
	combo = int(state["combo"])
	max_combo_run = int(state["max_combo_run"])

	distance = float(state["distance"])
	scrolled_distance = float(state["scrolled_distance"])
	run_time = float(state["run_time"])
	speed = float(state["speed"])
	difficulty = float(state["difficulty"])

	player_lane = int(state["player_lane"])
	player_lean = float(state["player_lean"])
	player_lean_target = float(state["player_lean_target"])
	player_run_phase = float(state["player_run_phase"])
	player_hit_flash = float(state["player_hit_flash"])

	dash_cooldown = float(state["dash_cooldown"])
	dash_timer = float(state["dash_timer"])
	invulnerable_timer = float(state["invulnerable_timer"])
	magnet_timer = float(state["magnet_timer"])
	slowmo_timer = float(state["slowmo_timer"])
	resonance_value = float(state["resonance_value"])
	flow_timer = float(state["flow_timer"])
	flow_activations = int(state["flow_activations"])

	current_biome_index = int(state["current_biome_index"])
	spawn_timer = float(state["spawn_timer"])
	crystal_spawn_timer = float(state["crystal_spawn_timer"])
	power_spawn_timer = float(state["power_spawn_timer"])
	crystal_rain_timer = float(state["crystal_rain_timer"])
	crystal_rain_active = float(state["crystal_rain_active"])

	flash_alpha = float(state["flash_alpha"])
	camera_shake = float(state["camera_shake"])
	completed_run_missions = []
	run_mission_bonus = int(state["run_mission_bonus"])
	circles_unlocked_run = int(state["circles_unlocked_run"])
	result_reveal_timer = float(state["result_reveal_timer"])
	result_badge_pulse = float(state["result_badge_pulse"])

func _bind_screen_flow_system() -> void:
	if screen_flow_system == null:
		return

	screen_flow_system.bind_screen_nodes(
		hud_layer,
		menu_layer,
		result_layer,
		shop_layer,
		pause_layer,
		cultivation_layer,
		tutorial_layer,
		transition_layer,
		neo_ui,
		transition_label,
		transition_subtitle,
		biome_label
	)

func build_ui() -> void:
	hud_layer = CanvasLayer.new();         add_child(hud_layer)
	menu_layer = CanvasLayer.new();        add_child(menu_layer)
	result_layer = CanvasLayer.new();      add_child(result_layer)
	shop_layer = CanvasLayer.new();        add_child(shop_layer)
	pause_layer = CanvasLayer.new();       add_child(pause_layer)
	cultivation_layer = CanvasLayer.new(); add_child(cultivation_layer)
	tutorial_layer = CanvasLayer.new();    add_child(tutorial_layer)
	transition_layer = CanvasLayer.new();  add_child(transition_layer)

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

	_build_hud()
	_build_menu()
	_build_result()
	_build_shop_legacy()
	_build_cultivation_legacy()
	_build_pause()
	_build_tutorial()
	_build_transition()

func _build_hud() -> void:
	var left  = make_panel(Vector2(18, 20), Vector2(196, 84), GameConfig.C_PANEL, Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.28))
	var mid   = make_panel(Vector2(224, 20), Vector2(272, 84), GameConfig.C_PANEL, Color(GameConfig.C_PEARL.r, GameConfig.C_PEARL.g, GameConfig.C_PEARL.b, 0.22))
	var right = make_panel(Vector2(506, 20), Vector2(196, 84), GameConfig.C_PANEL, Color(GameConfig.C_GOLD.r, GameConfig.C_GOLD.g, GameConfig.C_GOLD.b, 0.28))
	var rp    = make_panel(Vector2(80, 118), Vector2(560, 46), Color(0.015, 0.060, 0.025, 0.72), Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.24))
	for p in [left, mid, right, rp]:
		hud_layer.add_child(p)

	var lt = make_label("Cristais", 15, Vector2(12, 8), Color(0.70, 0.96, 0.78, 0.90))
	crystal_label = make_label("0", 32, Vector2(12, 22), GameConfig.C_JADE_SOFT)
	score_label   = make_label("Pontos 0", 13, Vector2(12, 57), Color(0.80, 0.95, 0.85, 0.84))
	left.add_child(lt); left.add_child(crystal_label); left.add_child(score_label)

	var ct = make_label("Distância", 15, Vector2(0, 8), Color(0.78, 0.95, 0.84, 0.84))
	ct.size = Vector2(272, 20); ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label = make_label("0 m", 30, Vector2(0, 22), GameConfig.C_PEARL)
	distance_label.size = Vector2(272, 36); distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_best_label = make_label("Marca 0 m", 13, Vector2(0, 58), Color(0.70, 0.92, 0.80, 0.80))
	hud_best_label.size = Vector2(272, 20); hud_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mid.add_child(ct); mid.add_child(distance_label); mid.add_child(hud_best_label)

	var rt = make_label("Fluxo", 15, Vector2(12, 8), Color(0.76, 0.96, 0.82, 0.88))
	combo_label = make_label("x1", 32, Vector2(12, 20), GameConfig.C_GOLD)
	dash_label  = make_label("Dash pronto", 13, Vector2(12, 57), Color(0.76, 0.96, 0.82, 0.84))
	right.add_child(rt); right.add_child(combo_label); right.add_child(dash_label)

	resonance_label = make_label("Ressonância", 15, Vector2(14, 7), Color(0.84, 0.98, 0.88, 0.90))
	resonance_bar   = make_progress_bar(Vector2(14, 26), Vector2(532, 13))
	rp.add_child(resonance_label); rp.add_child(resonance_bar)

	status_label = make_label("", 27, Vector2(0, 220), GameConfig.C_GOLD)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size = Vector2(GameConfig.VIEW_W, 68)
	hud_layer.add_child(status_label)

	pause_button = make_button("Ⅱ", Vector2(645, 178), Vector2(52, 50))
	pause_button.add_theme_font_size_override("font_size", 22)
	pause_button.pressed.connect(pause_game)
	hud_layer.add_child(pause_button)

	biome_label = make_label("", 15, Vector2(0, 206), Color(0.80, 0.96, 0.86, 0.88))
	biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	biome_label.size = Vector2(GameConfig.VIEW_W, 30)
	hud_layer.add_child(biome_label)

func _build_menu() -> void:
	menu_card = make_panel(Vector2(44, 128), Vector2(632, 804), Color(0.012, 0.046, 0.020, 0.02), Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.00))
	menu_layer.add_child(menu_card)

	title_label = make_label("FRAGMENT RUSH\nCorrida dos Cristais", 40, Vector2(0, 16), GameConfig.C_PEARL)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; title_label.size = Vector2(632, 120)
	subtitle_label = make_label("Arte marcial cristalina em alta velocidade.", 18, Vector2(60, 142), Color(0.76, 0.96, 0.82, 0.92))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; subtitle_label.size = Vector2(512, 58)
	best_label = make_label("", 17, Vector2(48, 288), Color(0.74, 0.94, 0.80, 0.92))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; best_label.size = Vector2(536, 72)
	start_button       = make_button("INICIAR CORRIDA",     Vector2(92, 432),  Vector2(448, 84))
	shop_button        = make_button("PAVILHÃO",            Vector2(70, 550),  Vector2(228, 66))
	cultivation_button = make_button("NÚCLEO",              Vector2(334, 550), Vector2(228, 66))
	daily_button       = make_button("ESSÊNCIA DIÁRIA",     Vector2(114, 638), Vector2(404, 60))
	help_button        = make_button("COMO JOGAR",          Vector2(166, 716), Vector2(300, 54))
	daily_button.add_theme_font_size_override("font_size", 18)
	help_button.add_theme_font_size_override("font_size", 17)
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(show_shop)
	cultivation_button.pressed.connect(show_cultivation)
	daily_button.pressed.connect(claim_daily_reward)
	help_button.pressed.connect(show_tutorial)
	for n in [title_label, subtitle_label, best_label, start_button, shop_button, cultivation_button, daily_button, help_button]:
		menu_card.add_child(n)

func _build_result() -> void:
	result_card = make_panel(Vector2(44, 112), Vector2(632, 1040), Color(0.015, 0.055, 0.022, 0.74), Color(GameConfig.C_GOLD.r, GameConfig.C_GOLD.g, GameConfig.C_GOLD.b, 0.30))
	result_layer.add_child(result_card)
	result_title          = make_label("CAMINHO INTERROMPIDO",  36, Vector2(0, 32),  GameConfig.C_PEARL)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; result_title.size = Vector2(632, 62)
	result_summary_label  = make_label("",                      27, Vector2(36, 108), GameConfig.C_GOLD)
	result_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; result_summary_label.size = Vector2(560, 86)
	result_stats          = make_label("",                      14, Vector2(46, 222), Color(0.85, 0.97, 0.90, 1.0))
	result_stats.size     = Vector2(540, 300)
	result_xp_label       = make_label("",                      16, Vector2(46, 530), Color(0.86, 1.0, 0.90, 0.95))
	result_xp_label.size  = Vector2(540, 32)
	result_xp_bar         = make_progress_bar(Vector2(46, 564), Vector2(540, 18))
	result_form_label     = make_label("",                      16, Vector2(46, 596), Color(1.0, 0.90, 0.62, 0.96))
	result_form_label.size = Vector2(540, 32)
	result_form_bar       = make_progress_bar(Vector2(46, 630), Vector2(540, 18))
	restart_button        = make_button("CULTIVAR NOVAMENTE",   Vector2(90, 730),  Vector2(452, 76))
	menu_button           = make_button("VOLTAR AO MENU",       Vector2(170, 826), Vector2(292, 58))
	for n in [result_title, result_summary_label, result_stats, result_xp_label, result_xp_bar, result_form_label, result_form_bar, restart_button, menu_button]:
		result_card.add_child(n)
	restart_button.pressed.connect(start_game)
	menu_button.pressed.connect(show_menu)

func _build_shop_legacy() -> void:
	shop_card = make_panel(Vector2(40, 60), Vector2(640, 1120), GameConfig.C_PANEL, Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.24))
	shop_layer.add_child(shop_card)
	shop_title_label       = make_label("PAVILHÃO MARCIAL",   30, Vector2(0, 20), GameConfig.C_PEARL)
	shop_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; shop_title_label.size = Vector2(640, 52)
	shop_info_label        = make_label("",                    16, Vector2(20, 78),  Color(0.74, 0.94, 0.80, 0.90))
	shop_preview_name_label= make_label("",                    24, Vector2(20, 112), GameConfig.C_PEARL)
	shop_preview_meta_label= make_label("",                    16, Vector2(20, 146), GameConfig.C_JADE)
	shop_preview_desc_label= make_label("",                    14, Vector2(20, 174), Color(0.76, 0.94, 0.82, 0.88))
	shop_preview_desc_label.size = Vector2(600, 56)
	shop_action_button     = make_button("",                   Vector2(100, 242), Vector2(440, 64))
	shop_action_button.pressed.connect(activate_selected_shop_skin)
	var y: float = 326.0
	var skin_order: Array[String] = ["nucleo_errante","semente_jade","corredor_rubi","coracao_nebular","essencia_dourada","corredor_sombrio","corredor_celestial","corredor_fragmentado"]
	for sid in skin_order:
		var sb: Button = make_button("", Vector2(20, y), Vector2(600, 56))
		sb.pressed.connect(select_shop_skin.bind(sid))
		shop_skin_buttons[sid] = sb
		shop_card.add_child(sb)
		y += 62.0
	close_shop_button = make_button("VOLTAR", Vector2(160, y + 8), Vector2(320, 56))
	close_shop_button.pressed.connect(show_menu)
	for n in [shop_title_label, shop_info_label, shop_preview_name_label, shop_preview_meta_label, shop_preview_desc_label, shop_action_button, close_shop_button]:
		shop_card.add_child(n)

func _build_cultivation_legacy() -> void:
	cultivation_card = make_panel(Vector2(40, 60), Vector2(640, 1060), GameConfig.C_PANEL, Color(GameConfig.C_GOLD.r, GameConfig.C_GOLD.g, GameConfig.C_GOLD.b, 0.24))
	cultivation_layer.add_child(cultivation_card)
	var ct = make_label("CÂMARA DO NÚCLEO", 28, Vector2(0, 18), GameConfig.C_PEARL)
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; ct.size = Vector2(640, 52)
	cultivation_stage_label       = make_label("", 20, Vector2(20, 78), GameConfig.C_JADE)
	cultivation_stage_label.size  = Vector2(600, 70)
	cultivation_next_circle_label = make_label("", 15, Vector2(20, 158), Color(0.76, 0.94, 0.82, 0.88))
	cultivation_next_circle_label.size = Vector2(600, 80)
	cultivation_card.add_child(ct)
	cultivation_card.add_child(cultivation_stage_label)
	cultivation_card.add_child(cultivation_next_circle_label)
	var y: float = 258.0
	for tech_id in ["dash", "jade", "flow"]:
		var tb: Button = make_button("", Vector2(20, y), Vector2(600, 80))
		tb.pressed.connect(upgrade_technique.bind(tech_id))
		cultivation_upgrade_buttons[tech_id] = tb
		cultivation_card.add_child(tb)
		y += 92.0
	cultivation_close_button = make_button("VOLTAR", Vector2(160, y + 8), Vector2(320, 56))
	cultivation_close_button.pressed.connect(show_menu)
	cultivation_card.add_child(cultivation_close_button)

func _build_pause() -> void:
	pause_card = make_panel(Vector2(80, 380), Vector2(560, 420), GameConfig.C_PANEL, Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.28))
	pause_layer.add_child(pause_card)
	pause_title    = make_label("PAUSA", 38, Vector2(0, 28), GameConfig.C_PEARL)
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; pause_title.size = Vector2(560, 68)
	pause_info_label = make_label("O caminho aguarda.", 18, Vector2(0, 106), Color(0.76, 0.96, 0.82, 0.86))
	pause_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; pause_info_label.size = Vector2(560, 40)
	resume_button     = make_button("CONTINUAR",      Vector2(80, 168), Vector2(400, 72))
	pause_menu_button = make_button("VOLTAR AO MENU", Vector2(110, 258), Vector2(340, 58))
	resume_button.pressed.connect(resume_game)
	pause_menu_button.pressed.connect(show_menu)
	for n in [pause_title, pause_info_label, resume_button, pause_menu_button]:
		pause_card.add_child(n)
	pause_button = make_button("Ⅱ", Vector2(645, 178), Vector2(52, 50))

func _build_tutorial() -> void:
	tutorial_card = make_panel(Vector2(40, 100), Vector2(640, 1000), GameConfig.C_PANEL, Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.28))
	tutorial_layer.add_child(tutorial_card)
	tutorial_title = make_label("COMO JOGAR", 30, Vector2(0, 22), GameConfig.C_PEARL)
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; tutorial_title.size = Vector2(640, 60)
	tutorial_text = make_label(
		"O caminho marcial é simples, mas a maestria é rara.\n\n" +
		"▶  Arraste para mover entre as faixas\n" +
		"▶  Desvie dos fragmentos de obsidiana\n" +
		"▶  Colete cristais para ganhar pontos\n" +
		"▶  Cristais em sequência criam COMBO\n" +
		"▶  Pressione ESPAÇO ou toque rápido para DASH\n" +
		"▶  No computador: ← → para mover, ESPAÇO para dash\n\n" +
		"Tipos de cristais:\n" +
		"◆ Cristal (ciano) — comum, vale 1\n" +
		"◆ Jade (verde) — raro, vale 3\n" +
		"◆ Nebular (roxo) — épico, vale 8\n" +
		"◆ Lendário (dourado) — mítico, vale 20\n\n" +
		"A velocidade aumenta com a distância.\n" +
		"Sobreviva o máximo possível!\n" +
		"Coleta de ímã: passe perto de cristais em fluxo.",
		15, Vector2(30, 96), Color(0.82, 0.97, 0.86, 0.95)
	)
	tutorial_text.size = Vector2(580, 740)
	tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_close_button = make_button("ENTENDIDO!", Vector2(160, 878), Vector2(320, 64))
	tutorial_close_button.pressed.connect(close_tutorial)
	for n in [tutorial_title, tutorial_text, tutorial_close_button]:
		tutorial_card.add_child(n)

func _build_transition() -> void:
	transition_card = make_panel(Vector2(0, 0), Vector2(GameConfig.VIEW_W, GameConfig.VIEW_H), Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.0))
	transition_layer.add_child(transition_card)
	transition_label    = make_label("", 40, Vector2(0, 540), GameConfig.C_JADE)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; transition_label.size = Vector2(GameConfig.VIEW_W, 80)
	transition_subtitle = make_label("", 22, Vector2(0, 630), Color(0.76, 0.96, 0.82, 0.90))
	transition_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; transition_subtitle.size = Vector2(GameConfig.VIEW_W, 48)
	for n in [transition_label, transition_subtitle]:
		transition_card.add_child(n)

# ── Screen management ─────────────────────────────────────────────────────────

func show_menu() -> void:
	if screen_flow_system != null:
		screen_flow_system.show_menu()
		screen = screen_flow_system.get_screen()
	else:
		screen = "menu"
		_hide_all_layers()
		menu_layer.visible = true
		hud_layer.visible = false
		if neo_ui != null:
			neo_ui.show_menu()

	update_neo_menu()
	update_daily_button()

func show_shop() -> void:
	selected_shop_skin = selected_skin

	if screen_flow_system != null:
		screen_flow_system.show_shop()
		screen = screen_flow_system.get_screen()
	else:
		screen = "shop"
		_hide_all_layers()
		if neo_ui != null:
			neo_ui.show_pavilion()

	update_shop_ui()
	update_neo_pavilion()

func show_cultivation() -> void:
	if screen_flow_system != null:
		screen_flow_system.show_cultivation()
		screen = screen_flow_system.get_screen()
	else:
		screen = "cultivation"
		_hide_all_layers()
		if neo_ui != null:
			neo_ui.show_core()

	update_cultivation_ui()
	update_neo_core()

func show_tutorial() -> void:
	if screen_flow_system != null:
		screen_flow_system.show_tutorial()
		screen = screen_flow_system.get_screen()
	else:
		screen = "tutorial"
		_hide_all_layers()
		tutorial_layer.visible = true
func close_tutorial() -> void:
	tutorial_seen = true
	save_game()
	show_menu()


func pause_game() -> void:
	if screen_flow_system != null:
		if screen_flow_system.pause_game(screen):
			screen = screen_flow_system.get_screen()
		return

	if screen != "game":
		return
	screen = "pause"
	if neo_ui != null:
		neo_ui.hide_all()
	hud_layer.visible = false
	pause_layer.visible = true

func resume_game() -> void:
	if screen_flow_system != null:
		if screen_flow_system.resume_game(screen):
			screen = screen_flow_system.get_screen()
		return

	if screen != "pause":
		return
	screen = "game"
	hud_layer.visible = true
	pause_layer.visible = false

func _hide_all_layers() -> void:
	if screen_flow_system != null:
		screen_flow_system.hide_all_layers()
		return

	hud_layer.visible = false
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	cultivation_layer.visible = false
	tutorial_layer.visible = false
	transition_layer.visible = false
	if neo_ui != null:
		neo_ui.hide_all()
func start_game() -> void:
	_reset_run()

	var biome: Dictionary = get_current_biome()
	var biome_name: String = str(biome["name"])

	if screen_flow_system != null:
		var countdown_state: Dictionary = screen_flow_system.start_countdown(biome_name, 2.2)
		screen = str(countdown_state["screen"])
		run_countdown = float(countdown_state["run_countdown"])
	else:
		screen = "countdown"
		_hide_all_layers()
		transition_layer.visible = true
		run_countdown = 2.2
		transition_label.text = biome_name.to_upper()
		transition_subtitle.text = "O caminho se abre…"
func _reset_run() -> void:
	clear_entities()
	if vfx_system != null:
		vfx_system.clear_all()
	else:
		particles.clear()
		shockwaves.clear()
		afterimages.clear()
		skin_trails.clear()
		vfx_png_sprites.clear()

	if input_system != null:
		input_system.reset_touch()

	var run_state: Dictionary = RunStateSystemBridge.build_default_run_state(rng)
	apply_run_state(run_state)

	if player_controller != null:
		player_controller.reset_to_center()
		player_lane = player_controller.player_lane
		target_x = player_controller.target_x
	else:
		target_x = screen_lane_x(player_lane)

	player.position = Vector2(target_x, GameConfig.PLAYER_Y)
	set_player_state("running")

	if player_controller != null:
		player_controller.reset_visual_motion()
		sync_player_visual_from_controller()
		player_controller.reset_hit_flash()
		player_controller.reset_dash()

	if spawner_system != null:
		spawner_system.reset()
		sync_spawner_timers_from_system()

	hud_layer.visible = false

func _update_countdown(delta: float) -> void:
	if screen_flow_system != null:
		var countdown_state: Dictionary = screen_flow_system.update_countdown(
			delta,
			str(get_current_biome()["name"])
		)

		screen = str(countdown_state["screen"])
		run_countdown = float(countdown_state["run_countdown"])

		if bool(countdown_state["started_game"]):
			update_hud()
		return

	run_countdown -= delta
	var n: int = ceili(run_countdown)
	if n > 0:
		transition_label.text = str(n)
		transition_subtitle.text = "Prepare-se…"
	else:
		transition_layer.visible = false
		screen = "game"
		hud_layer.visible = true
		biome_label.text = str(get_current_biome()["name"]).to_upper()
		update_hud()
func game_over() -> void:
	invulnerable_timer = 99.0
	set_player_state("hit")
	player_hit_flash = 0.8
	camera_shake = maxf(camera_shake, 18.0)
	flash_alpha = 0.35
	spawn_shockwave(player.position, GameConfig.C_RUBY, 30.0, 220.0, 0.55)
	for _i in range(24):
		spawn_particle(player.position + Vector2(rng.randf_range(-60.0, 60.0), rng.randf_range(-60.0, 60.0)), Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.82), 7, 0.50)
	await get_tree().create_timer(0.9).timeout
	if score > 0 or distance > best_distance:
		games_played_total += 1
		_check_missions_end()
	_show_result()

func _show_result() -> void:
	var new_record: bool = distance > best_distance
	if new_record:
		best_distance = distance
	var xp_gain: int = _calc_xp_gain()
	var old_circles: int = unlocked_circle_count()
	cultivation_xp += xp_gain
	last_xp_gain = xp_gain
	var new_circles: int = unlocked_circle_count()
	circles_unlocked_run = max(0, new_circles - old_circles)
	total_crystals += crystals_run + run_mission_bonus
	save_game()

	screen = "result"
	_hide_all_layers()
	result_layer.visible = true
	result_reveal_timer = 0.0
	result_count_crystals = 0.0
	result_target_crystals = crystals_run + run_mission_bonus
	result_count_xp = 0.0
	result_target_xp = xp_gain

	var dist_m: int = int(distance)
	var title_txt: String = "NOVO RECORDE!" if new_record else "CAMINHO INTERROMPIDO"
	result_title.text = title_txt
	result_summary_label.text = "%d m — Cristais %d — Combo x%d" % [dist_m, crystals_run, max_combo_run]

	var stats_lines: Array[String] = []
	stats_lines.append("Distância:       %d m" % dist_m)
	stats_lines.append("Pontuação:       %d" % score)
	stats_lines.append("Cristais:        %d  (+%d missões)" % [crystals_run, run_mission_bonus])
	stats_lines.append("Combo máximo:    x%d" % max_combo_run)
	stats_lines.append("Cristais raros:  %d" % rare_crystals_run)
	stats_lines.append("Dashes usados:   %d" % dashes_used_run)
	stats_lines.append("Tempo:           %.1f s" % run_time)
	stats_lines.append("Recorde:         %d m" % int(best_distance))
	if completed_run_missions.size() > 0:
		stats_lines.append("")
		stats_lines.append("Missões concluídas:")
		for m in completed_run_missions:
			stats_lines.append("  ✦ %s" % m)
	result_stats.text = "\n".join(stats_lines)

	result_xp_label.text  = "XP de Cultivo: +%d  (Total %d)" % [xp_gain, cultivation_xp]
	result_form_label.text = "Próxima forma: %s" % get_next_unlock_hint()
	result_xp_bar.value   = clampf(get_stage_progress_percent(), 0.0, 100.0)
	result_form_bar.value  = clampf(float(total_crystals + crystals_run) / float(max(1, _cheapest_skin_price())) * 100.0, 0.0, 100.0)

func _calc_xp_gain() -> int:
	var base: int = int(distance * 0.18) + score / 20 + rare_crystals_run * 6 + max_combo_run * 2
	return max(base, 8)

func _update_result_motion(delta: float) -> void:
	result_reveal_timer += delta
	result_badge_pulse += delta
	result_count_crystals = minf(result_count_crystals + delta * 28.0, float(result_target_crystals))
	result_count_xp = minf(result_count_xp + delta * 40.0, float(result_target_xp))

# ── Main game update ──────────────────────────────────────────────────────────
func _update_game(delta: float, real_delta: float) -> void:
	run_time += real_delta
	_update_player_movement(delta)
	_update_speed(delta)
	_update_distance(delta)
	_update_biome()
	_update_spawning(delta)
	_update_entities(delta)
	_update_dash(delta)
	_update_powerups(delta)
	_update_resonance(delta)
	_update_status(delta)
	spawn_skin_trail(real_delta)
	_update_env_particles(real_delta)
	_update_crystal_rain(delta)
	update_hud()

func _update_player_movement(delta: float) -> void:
	if player_controller != null:
		target_x = player_controller.target_x

	var px: float = player.position.x
	var move_speed: float = 1350.0 * delta
	player.position.x = move_toward(px, target_x, move_speed)

	var target_reached: bool = absf(player.position.x - target_x) < 6.0

	if player_controller != null:
		player_controller.update_visual_motion(delta, target_reached)
		sync_player_visual_from_controller()
	else:
		player_lean = move_toward(player_lean, player_lean_target, 4.2 * delta)
		if target_reached:
			player_lean_target = 0.0
		if player_state == "running":
			player_run_phase += delta

	if player_controller != null:
		if player_controller.is_state(["moving_left", "moving_right"]):
			set_player_state("running")
	else:
		if player_state in ["moving_left", "moving_right"]:
			player_state = "running"

	if player_controller != null:
		player_controller.update_hit_flash(delta)
		sync_player_hit_flash_from_controller()
	else:
		player_hit_flash = maxf(0.0, player_hit_flash - delta * 2.5)

	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
func _update_speed(delta: float) -> void:
	difficulty += delta * 0.018
	var target_speed: float = 380.0 + difficulty * 82.0
	speed = minf(speed + delta * 28.0, target_speed)
	speed = clampf(speed, 380.0, 900.0)

func _update_distance(delta: float) -> void:
	var ds: float = speed * delta * 0.09
	distance += ds
	scrolled_distance += speed * delta

func _update_biome() -> void:
	var next_idx: int = 0
	for i in range(GameConfig.BIOMES.size()):
		if distance >= float(GameConfig.BIOMES[i]["at"]):
			next_idx = i
	if next_idx != current_biome_index:
		current_biome_index = next_idx
		var b: Dictionary = get_current_biome()
		show_status(str(b["name"]).to_upper(), b["accent"])
		flash_alpha = maxf(flash_alpha, 0.14)
		spawn_shockwave(player.position, b["accent"], 48.0, 260.0, 0.70)
		biome_label.text = str(b["name"]).to_upper()

func _update_spawning(delta: float) -> void:
	if spawner_system == null:
		return

	var requests: Dictionary = spawner_system.update_spawners(delta, difficulty, crystal_rain_active)
	sync_spawner_timers_from_system()

	if requests["obstacle"]:
		_spawn_obstacle_pattern()

	if requests["crystal"]:
		_spawn_crystal_group()

	if requests["powerup"]:
		_spawn_powerup()
func _update_crystal_rain(delta: float) -> void:
	crystal_rain_timer -= delta
	if crystal_rain_active > 0.0:
		crystal_rain_active -= delta
	elif crystal_rain_timer <= 0.0:
		crystal_rain_active = 4.5
		crystal_rain_timer = rng.randf_range(18.0, 28.0)
		show_status("CHUVA DE JADE", GameConfig.C_GOLD)
		flash_alpha = maxf(flash_alpha, 0.12)
		spawn_shockwave(player.position, GameConfig.C_GOLD, 48.0, 280.0, 0.72)

func _update_entities(delta: float) -> void:
	var to_remove: Array[int] = []

	for i in range(entities.size()):
		var e: Dictionary = entities[i]

		if entity_system != null:
			e = entity_system.update_entity_motion(e, delta, speed)
		else:
			e["y"] = float(e["y"]) + speed * delta
			e["age"] = float(e.get("age", 0.0)) + delta

		entities[i] = e

		var out_of_bounds: bool = false
		if entity_system != null:
			out_of_bounds = entity_system.is_entity_out_of_bounds(e, GameConfig.VIEW_H)
		else:
			out_of_bounds = float(e["y"]) > GameConfig.VIEW_H + 120.0

		if out_of_bounds:
			to_remove.append(i)
			continue

		# Magnet
		if entity_system != null:
			e = entity_system.apply_crystal_magnet(
				e,
				delta,
				player.position,
				magnet_timer,
				tech_level("jade")
			)
			entities[i] = e
		else:
			if e["type"] == "crystal" and magnet_timer > 0.0:
				var diff: Vector2 = player.position - Vector2(float(e["x"]), float(e["y"]))
				var magnet_range: float = 160.0 + float(tech_level("jade")) * 28.0
				if diff.length() < magnet_range:
					e["x"] = float(e["x"]) + diff.x * delta * 5.5
					e["y"] = float(e["y"]) + diff.y * delta * 5.5
					entities[i] = e

		# Collision
		var entity_type: String = str(e["type"])

		if entity_type == "crystal":
			var crystal_hit: bool = false
			if entity_system != null:
				crystal_hit = entity_system.is_crystal_colliding(e, player.position)
			else:
				var cr: float = float(e.get("size", 18.0)) + 12.0
				crystal_hit = absf(player.position.x - float(e["x"])) < cr and absf(player.position.y - float(e["y"])) < cr

			if crystal_hit:
				_collect_crystal(e)
				to_remove.append(i)

		elif entity_type == "obstacle":
			if invulnerable_timer > 0.0:
				continue

			var obstacle_hit: bool = false
			if entity_system != null:
				obstacle_hit = entity_system.is_obstacle_colliding(e, player.position)
			else:
				var hw: float = float(e.get("hw", 26.0)) - 8.0
				var hh: float = float(e.get("hh", 30.0)) - 8.0
				obstacle_hit = absf(player.position.x - float(e["x"])) < hw and absf(player.position.y - float(e["y"])) < hh

			if obstacle_hit:
				_hit_obstacle()

		elif entity_type == "powerup":
			var powerup_hit: bool = false
			if entity_system != null:
				powerup_hit = entity_system.is_powerup_colliding(e, player.position)
			else:
				var pwr: float = 30.0
				powerup_hit = absf(player.position.x - float(e["x"])) < pwr and absf(player.position.y - float(e["y"])) < pwr

			if powerup_hit:
				_collect_powerup(e)
				to_remove.append(i)

	if entity_system != null:
		entity_system.remove_entities_by_indices(to_remove)
	else:
		to_remove.reverse()
		for idx in to_remove:
			if idx < entities.size():
				entities.remove_at(idx)

func _collect_crystal(e: Dictionary) -> void:
	var ctype: Dictionary = _get_crystal_type(str(e.get("crystal_type", "common")))

	var val: int = int(ctype["value"])
	var score_gain: int = val * 10
	var should_combo_vfx: bool = false
	var is_rare: bool = str(e.get("crystal_type", "common")) != "common"
	var should_activate_flow: bool = false

	if entity_system != null:
		var collection_state: Dictionary = entity_system.build_crystal_collection_state(
			e,
			int(ctype["value"]),
			flow_timer > 0.0,
			combo,
			max_combo_run,
			resonance_value
		)

		val = int(collection_state["value"])
		score_gain = int(collection_state["score_gain"])
		combo = int(collection_state["combo"])
		max_combo_run = int(collection_state["max_combo"])
		if bool(collection_state["combo_pop"]):
			combo_pop_timer = 1.0
		should_combo_vfx = bool(collection_state["combo_vfx"])
		resonance_value = float(collection_state["resonance_value"])
		should_activate_flow = bool(collection_state["activate_flow"])
		is_rare = bool(collection_state["is_rare"])
	else:
		if flow_timer > 0.0:
			val = int(ceil(float(val) * 1.5))
		if combo > 0:
			val = int(ceil(float(val) * (1.0 + float(combo) * 0.05)))
		score_gain = val * 10
		combo += 1
		max_combo_run = maxi(max_combo_run, combo)
		if combo > 1:
			combo_pop_timer = 1.0
		should_combo_vfx = combo >= 5 and combo % 5 == 0
		resonance_value = minf(resonance_value + 8.0 + float(combo) * 0.6, 100.0)
		should_activate_flow = resonance_value >= 100.0 and flow_timer <= 0.0

	crystals_run += val
	score += score_gain

	if should_combo_vfx:
		_spawn_vfx_png(Vector2(float(e["x"]), float(e["y"])), "combo", ctype["glow"], 150.0, 0.38, rng.randf() * TAU)

	if should_activate_flow:
		activate_flow_state()

	var cpos: Vector2 = Vector2(float(e["x"]), float(e["y"]))
	var cclr: Color = ctype["color"]
	var cglow: Color = ctype["glow"]

	for _i in range(6):
		spawn_particle(cpos + Vector2(rng.randf_range(-14.0, 14.0), rng.randf_range(-14.0, 14.0)), cclr, 5, 0.30)

	spawn_shockwave(cpos, cglow, 8.0, 52.0, 0.22)
	_spawn_vfx_png(cpos, "pickup", cglow, 92.0, 0.25, rng.randf() * TAU)
	flash_alpha = maxf(flash_alpha, 0.03)

	if is_rare:
		rare_crystals_run += 1
		spawn_shockwave(cpos, cglow, 14.0, 80.0, 0.35)

	_update_mission_progress("collect_50", crystals_run)
	if combo >= 10:
		_update_mission_progress("combo_10", combo)

func _hit_obstacle() -> void:
	if invulnerable_timer > 0.0:
		return

	if entity_system != null:
		var hit_state: Dictionary = entity_system.build_obstacle_hit_state(resonance_value, 1.8)
		combo = int(hit_state["combo"])
		resonance_value = float(hit_state["resonance_value"])
		invulnerable_timer = float(hit_state["invulnerable_timer"])
	else:
		combo = 0
		resonance_value = maxf(resonance_value - 35.0, 0.0)
		invulnerable_timer = 1.8

	set_player_state("hit")
	trigger_player_hit_flash(1.0)
	camera_shake = maxf(camera_shake, 14.0)
	flash_alpha = maxf(flash_alpha, 0.28)

	spawn_shockwave(player.position, GameConfig.C_RUBY, 22.0, 160.0, 0.42)
	_spawn_vfx_png(player.position, "impact", GameConfig.C_RUBY, 190.0, 0.40, rng.randf() * TAU)

	for _i in range(14):
		spawn_particle(
			player.position + Vector2(rng.randf_range(-50.0, 50.0), rng.randf_range(-50.0, 50.0)),
			Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.76),
			6,
			0.38
		)

	show_status("FRAGMENTADO", GameConfig.C_RUBY)

	await get_tree().create_timer(0.8).timeout
	if invulnerable_timer > 0.5:
		game_over()
func _collect_powerup(e: Dictionary) -> void:
	var ptype: String = str(e.get("ptype", "magnet"))

	if entity_system != null:
		ptype = entity_system.get_powerup_type(e)
		var effect_state: Dictionary = entity_system.build_powerup_effect_state(
			ptype,
			magnet_timer,
			invulnerable_timer,
			slowmo_timer,
			dash_cooldown,
			tech_level("jade")
		)

		magnet_timer = float(effect_state["magnet_timer"])
		invulnerable_timer = float(effect_state["invulnerable_timer"])
		slowmo_timer = float(effect_state["slowmo_timer"])
		dash_cooldown = float(effect_state["dash_cooldown"])

		if bool(effect_state.get("reset_dash_cooldown", false)) and player_controller != null:
			player_controller.dash_cooldown = 0.0
	else:
		match ptype:
			"magnet":
				magnet_timer = 5.0 + float(tech_level("jade")) * 0.6
			"shield":
				invulnerable_timer = maxf(invulnerable_timer, 4.5)
			"slowmo":
				slowmo_timer = maxf(slowmo_timer, 3.0)
			"dash_boost":
				dash_cooldown = 0.0

	if entity_system != null:
		var status_data: Dictionary = entity_system.get_powerup_status(ptype)
		if str(status_data.get("text", "")) != "":
			show_status(str(status_data["text"]), status_data["color"])
	else:
		match ptype:
			"magnet":
				show_status("TOQUE DE JADE — ÍMÃS", GameConfig.C_JADE)
			"shield":
				show_status("ESCUDO ESPIRITUAL", GameConfig.C_PEARL)
			"slowmo":
				show_status("FLUXO LENTO", GameConfig.C_VIOLET)
			"dash_boost":
				show_status("PASSO CARREGADO", GameConfig.C_ENERGY)

	spawn_shockwave(Vector2(float(e["x"]), float(e["y"])), GameConfig.C_GOLD, 20.0, 110.0, 0.40)
	flash_alpha = maxf(flash_alpha, 0.06)
func _update_dash(delta: float) -> void:
	if player_controller != null:
		player_controller.update_dash_timers(delta)
		dash_timer = player_controller.dash_timer
		dash_cooldown = player_controller.dash_cooldown
	else:
		if dash_timer > 0.0:
			dash_timer = maxf(0.0, dash_timer - delta)
		if dash_cooldown > 0.0:
			dash_cooldown = maxf(0.0, dash_cooldown - delta)

	if dash_timer <= 0.0 and player_state == "dash":
		set_player_state("running")
func _update_powerups(delta: float) -> void:
	if magnet_timer > 0.0:
		magnet_timer -= delta
	if flow_timer > 0.0:
		flow_timer -= delta
		if flow_timer <= 0.0:
			resonance_value = 0.0
			show_status("FLUXO EXPIRADO", GameConfig.C_JADE_SOFT)

func _update_resonance(_delta: float) -> void:
	pass


func _update_status(delta: float) -> void:
	if hud_system != null:
		status_label.modulate.a = hud_system.update_status_alpha(
			status_label.text,
			status_label.modulate.a,
			delta
		)
		return

	if status_label.text != "" and status_label.modulate.a > 0.0:
		status_label.modulate.a = maxf(0.0, status_label.modulate.a - delta * 0.55)
func _update_env_particles(delta: float) -> void:
	for i in range(falling_leaves.size()):
		var lf := falling_leaves[i]
		lf["x"] = float(lf["x"]) + float(lf["vx"]) * delta + sin(pulse_time * 0.9 + float(i)) * 2.0 * delta
		lf["y"] = float(lf["y"]) + float(lf["vy"]) * delta
		lf["rot"] = float(lf["rot"]) + float(lf["rot_spd"]) * delta
		if float(lf["y"]) > GameConfig.VIEW_H + 20.0:
			lf["y"] = -20.0
			lf["x"] = rng.randf() * GameConfig.VIEW_W
		falling_leaves[i] = lf
	for i in range(mist_puffs.size()):
		var mp := mist_puffs[i]
		mp["x"] = float(mp["x"]) + float(mp["vx"]) * delta
		mp["y"] = float(mp["y"]) + float(mp["vy"]) * delta
		if float(mp["y"]) < -80.0:
			mp["y"] = GameConfig.VIEW_H + 40.0
			mp["x"] = rng.randf() * GameConfig.VIEW_W
		mist_puffs[i] = mp


func move_lane(direction: int) -> void:
	if player_controller == null:
		return

	var changed: bool = player_controller.move_lane(direction)
	if not changed:
		return

	player_lane = player_controller.player_lane
	target_x = player_controller.target_x
	if player_controller != null:
		player_controller.set_lean_target(-0.24 if direction < 0 else 0.24)
		player_lean_target = player_controller.player_lean_target
	else:
		player_lean_target = -0.24 if direction < 0 else 0.24
	set_player_state("moving_left" if direction < 0 else "moving_right")

func do_dash() -> void:
	if player_controller == null:
		return

	if not player_controller.request_dash(tech_level("dash")):
		return

	dash_cooldown = player_controller.dash_cooldown
	dash_timer = player_controller.dash_timer
	set_player_state("dash")
	invulnerable_timer = maxf(invulnerable_timer, 0.38)
	dashes_used_run += 1
	spawn_afterimage(player.position, skin_glow_color(selected_skin), 0.26)
	_spawn_vfx_png(player.position + Vector2(0, 34), "dash", skin_glow_color(selected_skin), 160.0, 0.24, -PI * 0.5)
	_spawn_vfx_png(player.position + Vector2(0, 64), "trail", skin_glow_color(selected_skin), 128.0, 0.32, -PI * 0.5)
	spawn_shockwave(player.position, skin_glow_color(selected_skin), 12.0, 80.0, 0.28)
	for _i in range(8):
		spawn_particle(player.position + Vector2(rng.randf_range(-30.0, 30.0), rng.randf_range(0.0, 48.0)), skin_glow_color(selected_skin), 5, 0.22)
	EventBus.emit_player_dash_used()
	_update_mission_progress("use_dash_5", dashes_used_run)
func activate_flow_state() -> void:
	flow_timer = 5.8 + float(tech_level("flow")) * 0.45 + (0.75 if has_resonance_circle(5) else 0.0)
	flow_activations += 1
	resonance_value = 100.0
	invulnerable_timer = maxf(invulnerable_timer, 1.2)
	flash_alpha = maxf(flash_alpha, 0.20)
	camera_shake = maxf(camera_shake, 8.0)
	combo_pop_timer = 1.0
	spawn_afterimage(player.position, GameConfig.C_GOLD, 0.55)
	_spawn_vfx_png(player.position, "aura", GameConfig.C_GOLD, 240.0, 0.70, 0.0)
	spawn_shockwave(player.position, GameConfig.C_GOLD, 48.0, 260.0, 0.72)
	show_status("ESTADO DE FLUXO  •  CÍRCULOS %d/%d" % [unlocked_circle_count(), GameConfig.RESONANCE_CIRCLES.size()], GameConfig.C_GOLD)
	for _i in range(28):
		spawn_particle(player.position + Vector2(rng.randf_range(-72.0, 72.0), rng.randf_range(-64.0, 64.0)), Color(GameConfig.C_GOLD.r, GameConfig.C_GOLD.g, GameConfig.C_GOLD.b, 0.82), 7, 0.58)

# ── Spawners ──────────────────────────────────────────────────────────────────

func add_entity(entity: Dictionary) -> void:
	if entity_system != null:
		entity_system.add_entity(entity)
	else:
		entities.append(entity)


func clear_entities() -> void:
	if entity_system != null:
		entity_system.clear_entities()
	else:
		entities.clear()
func _spawn_obstacle_pattern() -> void:
	var chosen: String = "single"

	if spawner_system != null:
		chosen = spawner_system.pick_obstacle_pattern(difficulty)
	else:
		var pattern_weights: Array[float] = [40.0, 25.0, 18.0, 12.0, 5.0]
		if difficulty < 1.0:
			pattern_weights = [70.0, 20.0, 10.0, 0.0, 0.0]
		elif difficulty < 2.5:
			pattern_weights = [50.0, 28.0, 15.0, 7.0, 0.0]
		var patterns: Array[String] = ["single", "wall_gap", "alternate", "narrow", "barrage"]
		chosen = _weighted_choice(patterns, pattern_weights)

	var y_start: float = -80.0

	match chosen:
		"single":
			_spawn_obstacle(rng.randi_range(0, 2), y_start)
		"wall_gap":
			var gap: int = rng.randi_range(0, 2)
			for lane in range(3):
				if lane != gap:
					_spawn_obstacle(lane, y_start)
		"alternate":
			_spawn_obstacle(0 if rng.randf() < 0.5 else 2, y_start)
			_spawn_obstacle(1, y_start - 160.0)
		"narrow":
			_spawn_obstacle(0, y_start)
			_spawn_obstacle(2, y_start)
		"barrage":
			for lane in range(3):
				_spawn_obstacle(lane, y_start - float(lane) * 90.0)

func _spawn_obstacle(lane: int, y: float) -> void:
	var otype: String = "bamboo_wall"

	if spawner_system != null:
		otype = spawner_system.pick_obstacle_type(current_biome_index)
	else:
		var obs_types: Array[String] = ["bamboo_wall", "stone_pillar", "energy_barrier", "spirit_trap"]
		var obs_weights: Array[float] = [40.0, 30.0, 20.0, 10.0]
		var biome_idx: int = current_biome_index
		if biome_idx >= 3:
			obs_types = ["stone_pillar", "energy_barrier", "spirit_trap", "spinning_blade"]
			obs_weights = [28.0, 32.0, 22.0, 18.0]
		otype = _weighted_choice(obs_types, obs_weights)

	add_entity(EntityFactoryBridge.create_obstacle(
		screen_lane_x(lane),
		y,
		otype
	))
func _spawn_crystal_group() -> void:
	var biome: Dictionary = get_current_biome()
	var rare_boost: float = 1.0 + float(tech_level("jade")) * 0.08
	if has_resonance_circle(4):
		rare_boost += 0.15
	var adjusted_types: Array = GameConfig.CRYSTAL_TYPES.duplicate(true)
	for ct in adjusted_types:
		if ct["id"] != "common":
			ct["weight"] = int(float(ct["weight"]) * rare_boost)
	var ctype: Dictionary = _weighted_choice_dict(adjusted_types, "weight")

	var pattern: int = rng.randi_range(0, 3)
	if spawner_system != null:
		pattern = spawner_system.pick_crystal_pattern()
	match pattern:
		0: # Single
			_spawn_crystal(rng.randi_range(0, 2), rng.randf_range(-180.0, -60.0), ctype)
		1: # Line across
			for lane in range(3):
				_spawn_crystal(lane, rng.randf_range(-200.0, -80.0), ctype)
		2: # Diagonal
			for i in range(3):
				var lane2: int = clampi(i, 0, 2)
				_spawn_crystal(lane2, rng.randf_range(-240.0, -100.0) - float(i) * 70.0, ctype)
		3: # Double in one lane
			var pl: int = rng.randi_range(0, 2)
			_spawn_crystal(pl, rng.randf_range(-180.0, -60.0), ctype)
			_spawn_crystal(pl, rng.randf_range(-320.0, -200.0), ctype)


func _spawn_crystal(lane: int, y: float, ctype: Dictionary) -> void:
	add_entity(EntityFactoryBridge.create_crystal(
		screen_lane_x(lane),
		y,
		ctype
	))

func _spawn_powerup() -> void:
	var chosen: String = "magnet"

	if spawner_system != null:
		chosen = spawner_system.pick_powerup_type()
	else:
		var ptypes: Array[String] = ["magnet", "shield", "slowmo", "dash_boost"]
		var pw: Array[float] = [45.0, 30.0, 15.0, 10.0]
		chosen = _weighted_choice(ptypes, pw)

	add_entity(EntityFactoryBridge.create_powerup(
		screen_lane_x(rng.randi_range(0, 2)),
		-80.0,
		chosen
	))
func _weighted_choice(options: Array, weights: Array) -> String:
	var total: float = 0.0
	for w in weights:
		total += float(w)
	var r: float = rng.randf() * total
	var acc: float = 0.0
	for i in range(options.size()):
		acc += float(weights[i])
		if r <= acc:
			return str(options[i])
	return str(options[0])

func _weighted_choice_dict(options: Array, weight_key: String) -> Dictionary:
	var total: float = 0.0
	for o in options:
		total += float(o.get(weight_key, 1.0))
	var r: float = rng.randf() * total
	var acc: float = 0.0
	for o in options:
		acc += float(o.get(weight_key, 1.0))
		if r <= acc:
			return o
	return options[0]

func _get_crystal_type(id: String) -> Dictionary:
	for ct in GameConfig.CRYSTAL_TYPES:
		if ct["id"] == id:
			return ct
	return GameConfig.CRYSTAL_TYPES[0]

# ── Missions ──────────────────────────────────────────────────────────────────
func _update_mission_progress(mission_id: String, value: int) -> void:
	for m in GameConfig.MISSIONS:
		if str(m["id"]) == mission_id:
			if bool(mission_completed.get(mission_id, false)):
				return
			mission_progress[mission_id] = value
			if value >= int(m["goal"]):
				mission_completed[mission_id] = true
				run_mission_bonus += int(m["reward"])
				completed_run_missions.append(str(m["text"]))
				show_status("MISSÃO: %s  +%d" % [str(m["text"]).to_upper(), int(m["reward"])], GameConfig.C_GOLD)

func _check_missions_end() -> void:
	_update_mission_progress("survive_60", int(run_time))
	_update_mission_progress("rare_3", rare_crystals_run)
	_update_mission_progress("play_3", games_played_total)
	if distance > best_distance:
		_update_mission_progress("beat_record", 1)
	save_game()

# ── Cultivation ───────────────────────────────────────────────────────────────
func unlocked_circle_count() -> int:
	var cnt: int = 0
	for c in GameConfig.RESONANCE_CIRCLES:
		if cultivation_xp >= int(c["xp"]):
			cnt += 1
	return cnt

func has_resonance_circle(idx: int) -> bool:
	return unlocked_circle_count() >= idx

func circle_color(idx: int) -> Color:
	return GameConfig.RESONANCE_CIRCLES[clampi(idx - 1, 0, GameConfig.RESONANCE_CIRCLES.size() - 1)]["color"]

func next_circle_hint() -> String:
	var cnt: int = unlocked_circle_count()
	if cnt >= GameConfig.RESONANCE_CIRCLES.size():
		return "Todos os Círculos despertaram."
	var nc: Dictionary = GameConfig.RESONANCE_CIRCLES[cnt]
	return "Próximo: %s  •  faltam %d XP" % [str(nc["name"]), max(0, int(nc["xp"]) - cultivation_xp)]

func get_cultivation_stage_index() -> int:
	if cultivation_xp >= 6000: return 4
	if cultivation_xp >= 3000: return 3
	if cultivation_xp >= 1400: return 2
	if cultivation_xp >= 500:  return 1
	return 0

func get_cultivation_stage_name() -> String:
	return GameConfig.CULTIVATION_STAGES[get_cultivation_stage_index()]

func next_stage_xp() -> int:
	match get_cultivation_stage_index():
		0: return 500
		1: return 1400
		2: return 3000
		3: return 6000
		_: return cultivation_xp

func get_stage_progress_percent() -> float:
	var idx: int = get_cultivation_stage_index()
	if idx >= GameConfig.CULTIVATION_STAGES.size() - 1:
		return 100.0
	var thresholds: Array[int] = [0, 500, 1400, 3000, 6000]
	var lo: int = thresholds[idx]
	var hi: int = thresholds[mini(idx + 1, thresholds.size() - 1)]
	return clampf(float(cultivation_xp - lo) / float(max(1, hi - lo)) * 100.0, 0.0, 100.0)

func tech_level(tech_id: String) -> int:
	return int(technique_levels.get(tech_id, 0))

func technique_price(tech_id: String) -> int:
	return int(GameConfig.TECHNIQUES[tech_id]["base_price"]) + tech_level(tech_id) * 550

func upgrade_technique(tech_id: String) -> void:
	if not GameConfig.TECHNIQUES.has(tech_id):
		return
	var level: int = tech_level(tech_id)
	if level >= int(GameConfig.TECHNIQUES[tech_id]["max"]):
		show_status("TÉCNICA NO MÁXIMO", GameConfig.C_GOLD); return
	var price: int = technique_price(tech_id)
	if total_crystals < price:
		show_status("CRISTAIS INSUFICIENTES", GameConfig.C_RUBY); flash_alpha = maxf(flash_alpha, 0.07); return
	total_crystals -= price
	technique_levels[tech_id] = level + 1
	save_game()
	update_cultivation_ui()
	show_status("TÉCNICA APRIMORADA", GameConfig.C_JADE)
	update_neo_core()

# ── Shop ──────────────────────────────────────────────────────────────────────
func select_shop_skin(skin_id: String) -> void:
	if not GameConfig.SKINS.has(skin_id):
		return
	selected_shop_skin = skin_id
	update_shop_ui()
	flash_alpha = maxf(flash_alpha, 0.035)

func activate_selected_shop_skin() -> void:
	buy_or_select_skin(selected_shop_skin)

func buy_or_select_skin(skin_id: String) -> void:
	if not GameConfig.SKINS.has(skin_id):
		return
	var owned: bool = bool(owned_skins.get(skin_id, false))
	if owned:
		selected_skin = skin_id
		save_game()
		update_shop_ui()
		show_status("FORMA SINTONIZADA", GameConfig.C_JADE)
		return
	var price: int = int(GameConfig.SKINS[skin_id]["price"])
	if total_crystals >= price:
		total_crystals -= price
		owned_skins[skin_id] = true
		selected_skin = skin_id
		save_game()
		update_shop_ui()
		_trigger_form_unlock(skin_id)
	else:
		show_status("CRISTAIS INSUFICIENTES", GameConfig.C_RUBY)
		flash_alpha = maxf(flash_alpha, 0.07)

func _trigger_form_unlock(skin_id: String) -> void:
	form_unlock_skin = skin_id
	form_unlock_name = str(GameConfig.SKINS.get(skin_id, {}).get("name", "Nova Forma"))
	form_unlock_timer = 2.8
	flash_alpha = maxf(flash_alpha, 0.20)
	camera_shake = maxf(camera_shake, 11.0)
	spawn_shockwave(player.position, skin_color(skin_id), 52.0, 330.0, 0.82)
	show_status("NOVA FORMA DESPERTA", skin_color(skin_id))

func shop_action_text(skin_id: String) -> String:
	if skin_id == selected_skin:
		return "EQUIPADO"
	if bool(owned_skins.get(skin_id, false)):
		return "EQUIPAR"
	var price: int = int(GameConfig.SKINS.get(skin_id, {}).get("price", 9999))
	if total_crystals >= price:
		return "DESPERTAR  ·  %d" % price
	return "FALTAM %d CRISTAIS" % max(0, price - total_crystals)

func _cheapest_skin_price() -> int:
	var cheapest: int = 999999
	for sid in GameConfig.SKINS.keys():
		if not bool(owned_skins.get(sid, false)):
			cheapest = mini(cheapest, int(GameConfig.SKINS[sid]["price"]))
	return cheapest if cheapest < 999999 else 1

func get_next_unlock_hint() -> String:
	var cheapest_name: String = ""
	var cheapest_price: int = 999999
	for sid in GameConfig.SKINS.keys():
		if bool(owned_skins.get(sid, false)):
			continue
		var price: int = int(GameConfig.SKINS[sid]["price"])
		if price < cheapest_price:
			cheapest_price = price
			cheapest_name = str(GameConfig.SKINS[sid]["name"])
	if cheapest_name == "":
		return "Todas as formas despertas."
	return "%s  •  faltam %d cristais" % [cheapest_name, max(0, cheapest_price - total_crystals)]

# ── Daily ─────────────────────────────────────────────────────────────────────
func current_day_key() -> String:
	var d: Dictionary = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d["year"]), int(d["month"]), int(d["day"])]

func claim_daily_reward() -> void:
	var today: String = current_day_key()
	if last_daily_reward == today:
		update_daily_button(); return
	last_daily_reward = today
	total_crystals += 180
	save_game()
	update_daily_button()
	show_status("+180 ESSÊNCIA DIÁRIA", GameConfig.C_GOLD)
	spawn_shockwave(player.position, GameConfig.C_GOLD, 40.0, 250.0, 0.65)

func update_daily_button() -> void:
	if daily_button == null:
		return
	var today: String = current_day_key()
	if last_daily_reward == today:
		daily_button.text = "ESSÊNCIA RECEBIDA"
		daily_button.disabled = true
	else:
		daily_button.text = "ESSÊNCIA DIÁRIA +180"
		daily_button.disabled = false
	update_neo_menu()

# ── Neo-UI updaters ───────────────────────────────────────────────────────────
func update_neo_menu() -> void:
	if neo_ui == null or neo_ui.menu == null:
		return
	var cnt: int = unlocked_circle_count()
	var accent: Color = GameConfig.C_JADE
	if cnt > 0:
		accent = circle_color(cnt)
	var today: String = current_day_key()
	neo_ui.menu.set_data(
		get_cultivation_stage_name(), cultivation_xp,
		cnt, GameConfig.RESONANCE_CIRCLES.size(),
		int(best_distance), total_crystals,
		last_daily_reward != today, accent, max(1, cnt)
	)
	best_label.text = "Recorde: %d m  •  Cristais: %d" % [int(best_distance), total_crystals]

func update_neo_pavilion() -> void:
	if neo_ui == null or neo_ui.pavilion == null:
		return
	if not GameConfig.SKINS.has(selected_shop_skin):
		selected_shop_skin = selected_skin
	var data: Dictionary = GameConfig.SKINS[selected_shop_skin]
	var rarity: String = skin_rarity(selected_shop_skin)
	neo_ui.pavilion.set_data(
		selected_shop_skin,
		str(data["name"]), rarity,
		str(data["desc"]), skin_affinity_text(selected_shop_skin),
		total_crystals,
		shop_action_text(selected_shop_skin),
		rarity_color_for(rarity),
		max(1, unlocked_circle_count()),
		_neo_skin_buttons_data()
	)

func _neo_skin_buttons_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var order: Array[String] = ["nucleo_errante","semente_jade","corredor_rubi","coracao_nebular","essencia_dourada","corredor_sombrio","corredor_celestial","corredor_fragmentado"]
	for sid in order:
		if not GameConfig.SKINS.has(sid):
			result.append({"name": sid, "state": "?", "color": GameConfig.C_JADE})
			continue
		var owned: bool = bool(owned_skins.get(sid, false))
		var equipped: bool = sid == selected_skin
		var price: int = int(GameConfig.SKINS[sid]["price"])
		var state: String = "EQUIPADO" if equipped else ("LIBERADO" if owned else "%d" % price)
		result.append({"name": str(GameConfig.SKINS[sid]["name"]), "state": state, "color": rarity_color_for(skin_rarity(sid))})
	return result

func update_neo_core() -> void:
	if neo_ui == null or neo_ui.core == null:
		return
	var cnt: int = unlocked_circle_count()
	var accent: Color = GameConfig.C_JADE if cnt <= 0 else circle_color(cnt)
	neo_ui.core.set_data(
		get_cultivation_stage_name(), cultivation_xp,
		get_stage_progress_percent(), next_circle_hint(),
		accent, max(1, cnt), _technique_ui_data()
	)

func _technique_ui_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for tid in ["dash", "jade", "flow"]:
		var data: Dictionary = GameConfig.TECHNIQUES[tid]
		var level: int = tech_level(tid)
		var max_lv: int = int(data["max"])
		var action: String = "MAX" if level >= max_lv else "%d cristais" % technique_price(tid)
		result.append({"id": tid, "name": str(data["name"]), "level": "%d/%d" % [level, max_lv], "action": action})
	return result

# ── Legacy UI updates ─────────────────────────────────────────────────────────

func update_hud() -> void:
	if hud_system != null:
		var hud_state: Dictionary = hud_system.build_hud_state(
			crystals_run,
			score,
			distance,
			best_distance,
			combo,
			dash_cooldown,
			resonance_value,
			flow_timer,
			magnet_timer,
			_combo_color()
		)

		crystal_label.text = str(hud_state["crystal_text"])
		score_label.text = str(hud_state["score_text"])
		distance_label.text = str(hud_state["distance_text"])
		hud_best_label.text = str(hud_state["best_text"])

		combo_label.text = str(hud_state["combo_text"])
		combo_label.add_theme_color_override("font_color", hud_state["combo_color"])

		dash_label.text = str(hud_state["dash_text"])
		dash_label.add_theme_color_override("font_color", hud_state["dash_color"])

		resonance_bar.value = float(hud_state["resonance_value"])
		resonance_label.text = str(hud_state["resonance_text"])
		return

	crystal_label.text = str(crystals_run)
	score_label.text   = "Pts %d" % score
	distance_label.text = "%d m" % int(distance)
	hud_best_label.text = "Recorde %d m" % int(best_distance)
	combo_label.text = "x%d" % max(1, combo)
	combo_label.add_theme_color_override("font_color", _combo_color())

	var dc: float = maxf(0.0, dash_cooldown)
	if dc > 0.0:
		dash_label.text = "Dash %.1fs" % dc
		dash_label.add_theme_color_override("font_color", Color(0.7, 0.5, 0.3, 0.9))
	else:
		dash_label.text = "Dash pronto"
		dash_label.add_theme_color_override("font_color", Color(0.76, 0.98, 0.82, 0.90))

	resonance_bar.value = resonance_value
	if flow_timer > 0.0:
		resonance_label.text = "FLUXO ATIVO  %.1fs" % flow_timer
	elif magnet_timer > 0.0:
		resonance_label.text = "TOQUE DE JADE  %.1fs" % magnet_timer
	else:
		resonance_label.text = "Ressonância"
func _combo_color() -> Color:
	if combo >= 20: return GameConfig.C_GOLD
	if combo >= 10: return Color(1.0, 0.78, 0.30, 1.0)
	if combo >= 5:  return GameConfig.C_JADE_SOFT
	return GameConfig.C_GOLD

func update_shop_ui() -> void:
	if not GameConfig.SKINS.has(selected_shop_skin):
		selected_shop_skin = selected_skin
	var data: Dictionary = GameConfig.SKINS[selected_shop_skin]
	var owned: bool = bool(owned_skins.get(selected_shop_skin, false))
	var equipped: bool = selected_shop_skin == selected_skin
	var price: int = int(data["price"])
	var rarity: String = skin_rarity(selected_shop_skin)
	shop_info_label.text    = "Cristais %d  •  Formas %d/%d" % [total_crystals, owned_skins.size(), GameConfig.SKINS.size()]
	shop_preview_name_label.text = str(data["name"])
	shop_preview_meta_label.text = "%s  •  %s" % [rarity, skin_affinity_text(selected_shop_skin)]
	shop_preview_meta_label.add_theme_color_override("font_color", rarity_color_for(rarity))
	shop_preview_desc_label.text = str(data["desc"])
	if equipped:
		shop_action_button.text = "EQUIPADO"
	elif owned:
		shop_action_button.text = "EQUIPAR FORMA"
	elif total_crystals >= price:
		shop_action_button.text = "DESPERTAR  ·  %d" % price
	else:
		shop_action_button.text = "FALTAM %d CRISTAIS" % max(0, price - total_crystals)

	var skin_order: Array[String] = ["nucleo_errante","semente_jade","corredor_rubi","coracao_nebular","essencia_dourada","corredor_sombrio","corredor_celestial","corredor_fragmentado"]
	for sid in skin_order:
		if not shop_skin_buttons.has(sid):
			continue
		var b: Button = shop_skin_buttons[sid]
		var item_data: Dictionary = GameConfig.SKINS.get(sid, {})
		var item_owned: bool = bool(owned_skins.get(sid, false))
		var item_eq: bool = sid == selected_skin
		var item_sel: bool = sid == selected_shop_skin
		var item_price: int = int(item_data.get("price", 0))
		var state: String = "EQUIPADO" if item_eq else ("LIBERADO" if item_owned else "%d" % item_price)
		b.text = "%s\n%s" % [str(item_data.get("name", sid)), state]
		var c: Color = rarity_color_for(skin_rarity(sid))
		var bg_alpha: float = 0.22 if item_sel else (0.12 if item_owned else 0.06)
		b.add_theme_stylebox_override("normal", make_button_style(Color(c.r * 0.2, c.g * 0.2, c.b * 0.2, bg_alpha + 0.30), Color(c.r, c.g, c.b, 0.24 + (0.28 if item_sel else 0.0))))
	update_neo_pavilion()

func update_cultivation_ui() -> void:
	var nxt_xp: int = next_stage_xp()
	cultivation_stage_label.text = "%s\nXP %d  •  %.0f%%" % [get_cultivation_stage_name(), cultivation_xp, get_stage_progress_percent()]
	cultivation_next_circle_label.text = "%s\nPróximo estágio em %d XP" % [next_circle_hint(), max(0, nxt_xp - cultivation_xp)]
	for tech_id in cultivation_upgrade_buttons.keys():
		var b: Button = cultivation_upgrade_buttons[tech_id]
		var td: Dictionary = GameConfig.TECHNIQUES[tech_id]
		var level: int = tech_level(tech_id)
		var max_lv: int = int(td["max"])
		var action: String = "MAX" if level >= max_lv else "%d cristais" % technique_price(tech_id)
		b.text = "%s\nNv.%d/%d  •  %s" % [str(td["name"]), level, max_lv, action]


func show_status(text: String, color: Color) -> void:
	if status_label == null:
		return

	if hud_system != null:
		var status_state: Dictionary = hud_system.build_status_state(text, color)
		status_label.text = str(status_state["text"])
		status_label.add_theme_color_override("font_color", status_state["color"])
		status_label.modulate.a = float(status_state["alpha"])
		return

	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
	status_label.modulate.a = 1.0
func skin_color(skin_id: String) -> Color:
	match skin_id:
		"nucleo_errante":       return Color(0.220, 0.920, 0.560, 1.0)
		"semente_jade":         return Color(0.200, 0.840, 0.400, 1.0)
		"corredor_rubi":        return Color(0.950, 0.250, 0.180, 1.0)
		"coracao_nebular":      return Color(0.541, 0.361, 1.000, 1.0)
		"essencia_dourada":     return Color(1.000, 0.851, 0.502, 1.0)
		"corredor_sombrio":     return Color(0.300, 0.120, 0.600, 1.0)
		"corredor_celestial":   return Color(0.880, 0.980, 0.940, 1.0)
		"corredor_fragmentado": return Color(0.900, 0.400, 1.000, 1.0)
		_: return Color(0.220, 0.920, 0.560, 1.0)

func skin_glow_color(skin_id: String) -> Color:
	match skin_id:
		"nucleo_errante":       return Color(0.160, 0.780, 0.480, 1.0)
		"semente_jade":         return Color(0.300, 0.970, 0.540, 1.0)
		"corredor_rubi":        return Color(1.000, 0.500, 0.380, 1.0)
		"coracao_nebular":      return Color(0.700, 0.500, 1.000, 1.0)
		"essencia_dourada":     return Color(1.000, 0.950, 0.600, 1.0)
		"corredor_sombrio":     return Color(0.480, 0.240, 0.900, 1.0)
		"corredor_celestial":   return Color(0.800, 0.960, 1.000, 1.0)
		"corredor_fragmentado": return Color(1.000, 0.600, 1.000, 1.0)
		_: return Color(0.160, 0.780, 0.480, 1.0)

func skin_rarity(skin_id: String) -> String:
	match skin_id:
		"corredor_sombrio":     return "Épico"
		"corredor_celestial":   return "Épico"
		"corredor_fragmentado": return "Lendário"
		"essencia_dourada":     return "Lendário"
		"coracao_nebular":      return "Épico"
		"corredor_rubi":        return "Raro"
		"semente_jade":         return "Raro"
		_: return "Comum"

func skin_affinity_text(skin_id: String) -> String:
	match skin_id:
		"semente_jade":         return "Jade · Harmonia"
		"corredor_rubi":        return "Fogo · Intensidade"
		"coracao_nebular":      return "Nebular · Ressonância"
		"essencia_dourada":     return "Ascensão · Fortuna"
		"corredor_sombrio":     return "Sombra · Mistério"
		"corredor_celestial":   return "Céu · Pureza"
		"corredor_fragmentado": return "Caos · Transcendência"
		_: return "Cristal · Equilíbrio"

func rarity_color_for(rarity: String) -> Color:
	match rarity:
		"Raro":    return GameConfig.C_JADE
		"Épico":   return GameConfig.C_VIOLET
		"Lendário":return GameConfig.C_GOLD
		"Celestial":return GameConfig.C_PEARL
		_: return GameConfig.C_ENERGY

# ── Save / load ───────────────────────────────────────────────────────────────
func save_game() -> void:
	var data: Dictionary = {
		"selected_skin": selected_skin,
		"owned_skins": owned_skins,
		"total_crystals": total_crystals,
		"best_distance": best_distance,
		"cultivation_xp": cultivation_xp,
		"technique_levels": technique_levels,
		"mission_progress": mission_progress,
		"mission_completed": mission_completed,
		"last_daily_reward": last_daily_reward,
		"tutorial_seen": tutorial_seen,
		"games_played_total": games_played_total
	}

	SaveManager.save_game(data)

func load_save() -> void:
	var data: Dictionary = SaveManager.load_game()

	selected_skin = data["selected_skin"]
	owned_skins = data["owned_skins"]
	total_crystals = data["total_crystals"]
	best_distance = data["best_distance"]
	cultivation_xp = data["cultivation_xp"]
	technique_levels = data["technique_levels"]
	mission_progress = data["mission_progress"]
	mission_completed = data["mission_completed"]
	last_daily_reward = data["last_daily_reward"]
	tutorial_seen = data["tutorial_seen"]
	games_played_total = data["games_played_total"]

func _update_screen_shake(delta: float) -> void:
	camera_shake = maxf(0.0, camera_shake - delta * 22.0)
	if camera_shake > 0.0:
		var offset: Vector2 = Vector2(rng.randf_range(-camera_shake, camera_shake), rng.randf_range(-camera_shake, camera_shake))
		position = offset
	else:
		position = Vector2.ZERO

# ── Background / menu motion ──────────────────────────────────────────────────
func _update_environment(delta: float) -> void:
	pass

func _update_menu_motion(_delta: float) -> void:
	pass


func _update_impact_fx(delta: float) -> void:
	if vfx_system != null:
		vfx_system.update_effects(delta)
	else:
		_update_vfx_png(delta)

		var remove_sw: Array[int] = []
		for i in range(shockwaves.size()):
			var sw := shockwaves[i]
			sw["age"] = float(sw["age"]) + delta
			shockwaves[i] = sw
			if float(sw["age"]) >= float(sw["duration"]):
				remove_sw.append(i)
		remove_sw.reverse()
		for idx in remove_sw:
			shockwaves.remove_at(idx)

		var remove_ai: Array[int] = []
		for i in range(afterimages.size()):
			var ai := afterimages[i]
			ai["age"] = float(ai["age"]) + delta
			afterimages[i] = ai
			if float(ai["age"]) >= float(ai["duration"]):
				remove_ai.append(i)
		remove_ai.reverse()
		for idx in remove_ai:
			afterimages.remove_at(idx)

		var remove_p: Array[int] = []
		for i in range(particles.size()):
			var p := particles[i]
			p["age"] = float(p["age"]) + delta
			p["x"] = float(p["x"]) + float(p["vx"]) * delta
			p["y"] = float(p["y"]) + float(p["vy"]) * delta
			p["vy"] = float(p["vy"]) + 120.0 * delta
			particles[i] = p
			if float(p["age"]) >= float(p["duration"]):
				remove_p.append(i)
		remove_p.reverse()
		for idx in remove_p:
			particles.remove_at(idx)

		var remove_st: Array[int] = []
		for i in range(skin_trails.size()):
			var st := skin_trails[i]
			st["age"] = float(st["age"]) + delta
			skin_trails[i] = st
			if float(st["age"]) >= float(st["duration"]):
				remove_st.append(i)
		remove_st.reverse()
		for idx in remove_st:
			skin_trails.remove_at(idx)

	if form_unlock_timer > 0.0:
		form_unlock_timer -= delta
func spawn_particle(pos: Vector2, color: Color, size: int, duration: float) -> void:
	if vfx_system != null:
		vfx_system.spawn_particle(pos, color, size, duration)
		return

	particles.append({
		"x": pos.x, "y": pos.y,
		"vx": rng.randf_range(-80.0, 80.0),
		"vy": rng.randf_range(-120.0, -20.0),
		"color": color, "size": size,
		"age": 0.0, "duration": duration
	})

func spawn_shockwave(pos: Vector2, color: Color, start_radius: float, end_radius: float, duration: float) -> void:
	if vfx_system != null:
		vfx_system.spawn_shockwave(pos, color, start_radius, end_radius, duration)
		return

	shockwaves.append({
		"pos": pos,
		"color": color,
		"start": start_radius,
		"end": end_radius,
		"duration": duration,
		"age": 0.0
	})

func spawn_afterimage(pos: Vector2, color: Color, duration: float) -> void:
	if vfx_system != null:
		vfx_system.spawn_afterimage(pos, color, duration, player_lean, player_state)
		return

	afterimages.append({
		"pos": pos,
		"color": color,
		"duration": duration,
		"age": 0.0,
		"lean": player_lean,
		"state": player_state
	})
func spawn_skin_trail(real_delta: float) -> void:
	if screen != "game":
		return
	var chance: float = 0.72
	if flow_timer > 0.0:
		chance = 1.0
	if player_state == "dash":
		chance = 1.0
	if rng.randf() > chance:
		return
	var off_x: float = rng.randf_range(-14.0, 14.0)
	var trail_pos: Vector2 = player.position + Vector2(off_x, rng.randf_range(40.0, 72.0))
	skin_trails.append({
		"pos": trail_pos,
		"color": skin_glow_color(selected_skin),
		"duration": 0.32 + (0.18 if flow_timer > 0.0 else 0.0),
		"age": 0.0,
		"size": 5.0 + (3.0 if flow_timer > 0.0 else 0.0)
	})
	if skin_trails.size() > 48:
		skin_trails.remove_at(0)

func get_current_biome() -> Dictionary:
	return GameConfig.BIOMES[clampi(current_biome_index, 0, GameConfig.BIOMES.size() - 1)]

func get_biome_accent() -> Color:
	return get_current_biome()["accent"]

# ── UI builder helpers ────────────────────────────────────────────────────────
func make_panel(pos: Vector2, size: Vector2, bg: Color, border_color: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = pos
	panel.size = size
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(32)
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 12
	style.set_content_margin_all(12.0)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func make_label(text: String, font_size: int, pos: Vector2, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func make_button(text: String, pos: Vector2, sz: Vector2) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = sz
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.022, 0.082, 0.038, 0.55)
	style.border_color = Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.42)
	style.set_border_width_all(1)
	style.set_corner_radius_all(40)
	style.shadow_color = Color(0, 0, 0, 0.20)
	style.shadow_size = 8
	style.set_content_margin_all(10.0)
	btn.add_theme_stylebox_override("normal", style)
	var hover: StyleBoxFlat = style.duplicate()
	hover.bg_color = Color(0.040, 0.145, 0.065, 0.72)
	hover.border_color = Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, 0.60)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed: StyleBoxFlat = style.duplicate()
	pressed.bg_color = Color(0.060, 0.200, 0.090, 0.82)
	pressed.border_color = Color(GameConfig.C_GOLD.r, GameConfig.C_GOLD.g, GameConfig.C_GOLD.b, 0.60)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", GameConfig.C_PEARL)
	return btn

func make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(38)
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 8
	style.set_content_margin_all(10.0)
	return style

func make_progress_bar(pos: Vector2, sz: Vector2) -> ProgressBar:
	var pb: ProgressBar = ProgressBar.new()
	pb.position = pos
	pb.size = sz
	pb.min_value = 0.0
	pb.max_value = 100.0
	pb.value = 0.0
	pb.show_percentage = false
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color(0.015, 0.055, 0.025, 0.60)
	bg.set_corner_radius_all(12)
	pb.add_theme_stylebox_override("background", bg)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = GameConfig.C_JADE
	fill.set_corner_radius_all(12)
	pb.add_theme_stylebox_override("fill", fill)
	return pb

func hide_legacy_meta_layers() -> void:
	if shop_layer != null:
		shop_layer.visible = false
	if cultivation_layer != null:
		cultivation_layer.visible = false
	if menu_layer != null:
		menu_layer.visible = false

# ── Draw ──────────────────────────────────────────────────────────────────────
func _draw() -> void:
	_draw_wuxia_background()
	_draw_png_game_background()
	if screen in ["game", "countdown", "pause"]:
		_draw_game_bamboo()
		_draw_game_mist()
		_draw_speed_lines()
	_draw_spiritual_lanes()
	_draw_afterimages()
	_draw_entities()
	_draw_entity_png_overlays()
	_draw_skin_trails()
	_draw_particles()
	_draw_shockwaves()
	_draw_vfx_png_overlays()
	_draw_player()
	_draw_player_aura()
	_draw_resonance_circles()
	_draw_dash_meter()
	_draw_hud_png_overlays()
	_draw_form_unlock_overlay()
	_draw_flash_overlay()
	if screen in ["menu", "shop", "cultivation"]:
		_draw_neo_shell()
	if screen == "result":
		_draw_result_badges()
func _load_game_bg_texture_direct(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("Gameplay background PNG nao carregou: " + path)

	return tex

func _current_game_bg_key() -> String:
	if current_biome_index >= 4:
		return "jade"
	if current_biome_index >= 2:
		return "bridge"
	return "bamboo"

func _ensure_game_bg_loaded() -> void:
	var key: String = _current_game_bg_key()

	if key == game_bg_key:
		return

	game_bg_key = key

	var base_path: String = "res://assets/backgrounds/%s/" % key

	game_bg_sky_png = _load_game_bg_texture_direct(base_path + "sky.png")
	game_bg_mountains_png = _load_game_bg_texture_direct(base_path + "mountains.png")
	game_bg_mid_png = _load_game_bg_texture_direct(base_path + "mid.png")
	game_bg_front_png = _load_game_bg_texture_direct(base_path + "front.png")
	game_bg_fog_png = _load_game_bg_texture_direct(base_path + "fog.png")

func _draw_game_bg_layer_png(tex: Texture2D, speed_factor: float, alpha: float) -> void:
	if tex == null:
		return

	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())

	if tw <= 0.0 or th <= 0.0:
		return

	var scale_factor: float = maxf(GameConfig.VIEW_W / tw, GameConfig.VIEW_H / th)
	var draw_size: Vector2 = Vector2(tw, th) * scale_factor
	var base_x: float = (GameConfig.VIEW_W - draw_size.x) * 0.5

	var scroll_y: float = fmod(scrolled_distance * speed_factor, draw_size.y)
	var y: float = -scroll_y

	while y < GameConfig.VIEW_H:
		draw_texture_rect(
			tex,
			Rect2(base_x, y, draw_size.x, draw_size.y),
			false,
			Color(1, 1, 1, alpha)
		)
		y += draw_size.y

func _draw_png_game_background() -> void:
	if screen not in ["game", "countdown", "pause"]:
		return

	_ensure_game_bg_loaded()

	_draw_game_bg_layer_png(game_bg_sky_png, 0.006, 1.0)
	_draw_game_bg_layer_png(game_bg_mountains_png, 0.012, 1.0)
	_draw_game_bg_layer_png(game_bg_mid_png, 0.030, 1.0)
	_draw_game_bg_layer_png(game_bg_fog_png, 0.018, 0.48)
	_draw_game_bg_layer_png(game_bg_front_png, 0.055, 1.0)


func _draw_wuxia_background() -> void:
	var biome: Dictionary = get_current_biome()
	var deep: Color = biome["deep"]
	draw_rect(Rect2(Vector2.ZERO, Vector2(GameConfig.VIEW_W, GameConfig.VIEW_H)), deep)
	var mist_c: Color = biome["mist"]
	for y in range(0, int(GameConfig.VIEW_H), 64):
		var f: float = float(y) / GameConfig.VIEW_H
		var c: Color = deep.lerp(mist_c, 0.14 + f * 0.10)
		c.a = 0.18
		draw_rect(Rect2(0, y, GameConfig.VIEW_W, 64), c)
	var accent: Color = biome["accent"]
	for mp in mist_puffs:
		var mx: float = float(mp["x"])
		var my: float = float(mp["y"])
		var mw: float = float(mp["w"])
		var mh: float = float(mp["h"])
		var ma: float = float(mp["alpha"]) * (0.65 + sin(pulse_time * 0.6 + float(mp["phase"])) * 0.30)
		draw_rect(Rect2(mx - mw * 0.5, my - mh * 0.5, mw, mh), Color(accent.r, accent.g, accent.b, ma))

func _draw_game_bamboo() -> void:
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]

	# Far layer
	for stalk in bamboo_far:
		var x: float = float(stalk["x"])
		var seg_h: float = float(stalk["seg"])
		var sw: float = float(stalk["w"])
		var alpha: float = float(stalk["alpha"])
		var y_scroll: float = fmod(float(stalk["y_off"]) + scrolled_distance * float(stalk["spd"]), seg_h)
		var bc := Color(0.040, 0.165, 0.060, alpha)
		var nc := Color(0.065, 0.240, 0.088, alpha * 0.85)
		var sy: float = -seg_h + fmod(y_scroll, seg_h)
		while sy < GameConfig.VIEW_H + seg_h:
			draw_line(Vector2(x, sy), Vector2(x, sy + seg_h - 3.0), bc, sw)
			draw_line(Vector2(x - sw * 1.6, sy), Vector2(x + sw * 1.6, sy), nc, sw * 0.7)
			# Leaves
			var la: float = alpha * 0.45
			draw_line(Vector2(x, sy + seg_h * 0.28), Vector2(x + sw * 4.2, sy + seg_h * 0.28 - sw * 2.0), Color(0.055, 0.210, 0.075, la), 1.5)
			draw_line(Vector2(x, sy + seg_h * 0.58), Vector2(x - sw * 4.2, sy + seg_h * 0.58 - sw * 2.0), Color(0.055, 0.210, 0.075, la), 1.5)
			sy += seg_h

	# Near layer (thicker, faster)
	for stalk in bamboo_near:
		var x: float = float(stalk["x"])
		var seg_h: float = float(stalk["seg"])
		var sw: float = float(stalk["w"])
		var alpha: float = float(stalk["alpha"])
		var y_scroll: float = fmod(float(stalk["y_off"]) + scrolled_distance * float(stalk["spd"]), seg_h)
		var bc := Color(0.028, 0.115, 0.042, alpha)
		var nc := Color(0.048, 0.180, 0.065, alpha * 0.88)
		var sy: float = -seg_h + fmod(y_scroll, seg_h)
		while sy < GameConfig.VIEW_H + seg_h:
			draw_line(Vector2(x, sy), Vector2(x, sy + seg_h - 4.0), bc, sw)
			draw_line(Vector2(x - sw * 1.8, sy), Vector2(x + sw * 1.8, sy), nc, sw * 0.75)
			sy += seg_h

	# Lanterns in later biomes
	if current_biome_index >= 3:
		for i in range(4):
			var lx: float = [55.0, 145.0, 575.0, 665.0][i]
			var lt_y: float = fmod(float(i) * 180.0 + scrolled_distance * 0.04, GameConfig.VIEW_H + 80.0)
			var la_alpha: float = 0.35 + sin(pulse_time * 1.8 + float(i)) * 0.15
			draw_circle(Vector2(lx, lt_y), 8.0, Color(GameConfig.C_LANTERN.r, GameConfig.C_LANTERN.g, GameConfig.C_LANTERN.b, la_alpha * 0.60))
			draw_circle(Vector2(lx, lt_y), 14.0, Color(GameConfig.C_LANTERN.r, GameConfig.C_LANTERN.g, GameConfig.C_LANTERN.b, la_alpha * 0.18))
			draw_rect(Rect2(lx - 5, lt_y - 14, 10, 12), Color(GameConfig.C_LANTERN.r * 0.8, GameConfig.C_LANTERN.g * 0.3, GameConfig.C_LANTERN.b * 0.1, la_alpha * 0.70))

	# Falling leaves
	for lf in falling_leaves:
		var lr: float = float(lf["rot"])
		var ls: float = float(lf["size"])
		var la: float = float(lf["alpha"]) * 0.7
		var lpos: Vector2 = Vector2(float(lf["x"]), float(lf["y"]))
		var pts: PackedVector2Array = PackedVector2Array([
			lpos + Vector2(cos(lr), sin(lr)) * ls,
			lpos + Vector2(cos(lr + 2.1), sin(lr + 2.1)) * ls * 0.5,
			lpos + Vector2(cos(lr + PI), sin(lr + PI)) * ls * 0.8
		])
		draw_colored_polygon(pts, Color(0.060, 0.240, 0.080, la))

func _draw_game_mist() -> void:
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	for i in range(3):
		var mist_y: float = fmod(float(i) * 420.0 + scrolled_distance * 0.025, GameConfig.VIEW_H + 80.0)
		draw_rect(Rect2(0, mist_y, GameConfig.VIEW_W, 55.0), Color(accent.r, accent.g, accent.b, 0.028 + sin(pulse_time * 0.4 + float(i)) * 0.012))

func _draw_spiritual_lanes() -> void:
	if screen not in ["game", "countdown"]:
		return
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	var lane_alpha: float = 0.040 + (0.030 if flow_timer > 0.0 else 0.0)
	for lane_x_off in GameConfig.LANES:
		var lx: float = GameConfig.VIEW_W * 0.5 + lane_x_off
		var dash_period: float = 80.0
		var dash_len: float = 44.0
		var offset: float = fmod(scrolled_distance * 0.22, dash_period)
		var y: float = -dash_period + offset
		while y < GameConfig.VIEW_H + dash_period:
			draw_line(Vector2(lx, y), Vector2(lx, y + dash_len), Color(accent.r, accent.g, accent.b, lane_alpha), 2.0)
			y += dash_period
	# Lane dividers
	for i in range(1, GameConfig.LANES.size()):
		var div_x: float = GameConfig.VIEW_W * 0.5 + (GameConfig.LANES[i - 1] + GameConfig.LANES[i]) * 0.5
		draw_line(Vector2(div_x, 0), Vector2(div_x, GameConfig.VIEW_H), Color(accent.r, accent.g, accent.b, 0.016), 1.0)

func _draw_speed_lines() -> void:
	if screen != "game":
		return
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	var intensity: float = clampf((speed - 380.0) / 520.0, 0.0, 1.0)
	if intensity < 0.05:
		return
	for i in range(12):
		var sx: float = 80.0 + float(i) * 48.0
		var sy: float = fmod(float(i) * 137.0 + scrolled_distance * 0.55, GameConfig.VIEW_H + 60.0)
		var slen: float = 28.0 + intensity * 55.0
		draw_line(Vector2(sx, sy), Vector2(sx + rng.randf_range(-6.0, 6.0), sy + slen), Color(accent.r, accent.g, accent.b, 0.055 * intensity), 1.2)

func _draw_afterimages() -> void:
	for ai in afterimages:
		var age: float = float(ai["age"])
		var dur: float = float(ai["duration"])
		var t_frac: float = age / maxf(dur, 0.001)
		var alpha: float = (1.0 - t_frac) * 0.38
		var c: Color = ai["color"]
		_draw_stickman_at(ai["pos"], selected_skin, float(ai.get("lean", 0.0)), 0.0, str(ai.get("state", "running")), 0.0, Color(c.r, c.g, c.b, alpha))

func _draw_entities() -> void:
	for e in entities:
		var ex: float = float(e["x"])
		var ey: float = float(e["y"])
		var age: float = float(e.get("age", 0.0))
		if e["type"] == "crystal":
			_draw_crystal(Vector2(ex, ey), str(e.get("crystal_type", "common")), age)
		elif e["type"] == "obstacle":
			_draw_obstacle(Vector2(ex, ey), str(e.get("otype", "bamboo_wall")), age)
		elif e["type"] == "powerup":
			_draw_powerup(Vector2(ex, ey), str(e.get("ptype", "magnet")), age)

func _draw_crystal(pos: Vector2, ctype_id: String, age: float) -> void:
	var ct: Dictionary = _get_crystal_type(ctype_id)
	var c: Color = ct["color"]
	var gc: Color = ct["glow"]
	var sz: float = float(ct["size"])
	var pulse_s: float = sz + sin(pulse_time * 3.5 + pos.x * 0.01) * 2.5

	# Outer glow
	draw_circle(pos, pulse_s + 10.0, Color(gc.r, gc.g, gc.b, 0.12))
	draw_circle(pos, pulse_s + 5.0, Color(gc.r, gc.g, gc.b, 0.22))

	# Crystal shape (diamond)
	var pts: PackedVector2Array = PackedVector2Array([
		pos + Vector2(0, -pulse_s),
		pos + Vector2(pulse_s * 0.68, 0),
		pos + Vector2(0, pulse_s),
		pos + Vector2(-pulse_s * 0.68, 0)
	])
	draw_colored_polygon(pts, Color(c.r, c.g, c.b, 0.90))
	var outline: PackedVector2Array = PackedVector2Array(pts)
	outline.append(pts[0])
	draw_polyline(outline, Color(1.0, 1.0, 1.0, 0.55), 1.8)

	# Inner shine
	draw_circle(pos + Vector2(-sz * 0.22, -sz * 0.22), sz * 0.22, Color(1.0, 1.0, 1.0, 0.45))

	# Rarity indicator
	if ctype_id != "common":
		draw_circle(pos, pulse_s + 14.0, Color(gc.r, gc.g, gc.b, 0.08))
		var start: float = pulse_time * 0.80
		draw_arc(pos, pulse_s + 10.0, start, start + PI * 1.20, 48, Color(gc.r, gc.g, gc.b, 0.25), 1.8, true)

func _draw_obstacle(pos: Vector2, otype: String, age: float) -> void:
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	match otype:
		"bamboo_wall":
			# Dark bamboo barrier
			var hw: float = 28.0
			var hh: float = 52.0
			draw_rect(Rect2(pos - Vector2(hw, hh), Vector2(hw * 2, hh * 2)), Color(0.030, 0.110, 0.040, 0.88))
			for seg in range(3):
				var sy: float = pos.y - hh + float(seg) * (hh * 2.0 / 3.0)
				draw_line(Vector2(pos.x - hw, sy), Vector2(pos.x + hw, sy), Color(0.048, 0.180, 0.065, 0.60), 2.0)
			draw_rect(Rect2(pos - Vector2(hw + 1, hh + 1), Vector2(hw * 2 + 2, hh * 2 + 2)), Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.22))
			draw_circle(pos, 6.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.50))
		"stone_pillar":
			var hw: float = 24.0
			var hh: float = 46.0
			draw_rect(Rect2(pos - Vector2(hw, hh), Vector2(hw * 2, hh * 2)), Color(0.120, 0.110, 0.090, 0.82))
			draw_rect(Rect2(pos - Vector2(hw, hh), Vector2(hw * 2, 8)), Color(0.180, 0.170, 0.140, 0.88))
			draw_rect(Rect2(pos + Vector2(-hw, hh - 8), Vector2(hw * 2, 8)), Color(0.180, 0.170, 0.140, 0.88))
			var pulse_glow: float = 0.12 + sin(pulse_time * 2.2 + pos.x) * 0.06
			draw_rect(Rect2(pos - Vector2(hw + 2, hh + 2), Vector2(hw * 2 + 4, hh * 2 + 4)), Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, pulse_glow))
		"energy_barrier":
			var hw: float = 30.0
			var hh: float = 8.0
			var eb_pulse: float = 0.55 + sin(pulse_time * 5.0 + pos.x * 0.02) * 0.35
			draw_rect(Rect2(pos - Vector2(hw, hh * 3.0), Vector2(hw * 2, hh * 6.0)), Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.14))
			for yi in range(-2, 3):
				var lc: Color = Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, eb_pulse * (0.55 - absf(float(yi)) * 0.14))
				draw_line(Vector2(pos.x - hw, pos.y + float(yi) * hh), Vector2(pos.x + hw, pos.y + float(yi) * hh), lc, 3.0)
			draw_circle(pos, 10.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, eb_pulse * 0.72))
		"spirit_trap":
			var radius: float = 26.0
			var sp_pulse: float = 0.45 + sin(pulse_time * 3.5 + pos.y * 0.02) * 0.30
			draw_circle(pos, radius + 8.0, Color(GameConfig.C_VIOLET.r, GameConfig.C_VIOLET.g, GameConfig.C_VIOLET.b, 0.10))
			draw_circle(pos, radius, Color(0.080, 0.030, 0.160, 0.72))
			var start: float = pulse_time * 1.2
			draw_arc(pos, radius, start, start + PI * 1.40, 64, Color(GameConfig.C_VIOLET.r, GameConfig.C_VIOLET.g, GameConfig.C_VIOLET.b, sp_pulse), 3.0, true)
			draw_arc(pos, radius * 0.60, -start * 0.7, -start * 0.7 + PI * 0.80, 32, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, sp_pulse * 0.70), 2.0, true)
			draw_circle(pos, 8.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, sp_pulse))
		"spinning_blade":
			var radius: float = 22.0
			var rot: float = pulse_time * 2.8
			for i in range(4):
				var a: float = rot + float(i) * PI * 0.5
				var p1: Vector2 = pos + Vector2(cos(a), sin(a)) * radius
				var p2: Vector2 = pos + Vector2(cos(a + PI), sin(a + PI)) * radius
				draw_line(p1, p2, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.88), 3.5)
			draw_circle(pos, 8.0, Color(0.120, 0.050, 0.020, 0.90))
			draw_circle(pos, 5.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.80))
			draw_circle(pos, radius + 6.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.08))
		_:
			draw_circle(pos, 28.0, Color(GameConfig.C_RUBY.r, GameConfig.C_RUBY.g, GameConfig.C_RUBY.b, 0.60))

func _draw_powerup(pos: Vector2, ptype: String, age: float) -> void:
	var c: Color = GameConfig.C_JADE
	var label_text: String = "?"
	match ptype:
		"magnet":   c = GameConfig.C_JADE;   label_text = "↗"
		"shield":   c = GameConfig.C_PEARL;  label_text = "⬡"
		"slowmo":   c = GameConfig.C_VIOLET; label_text = "∞"
		"dash_boost": c = GameConfig.C_ENERGY; label_text = "»"
	var pulse_r: float = 22.0 + sin(pulse_time * 3.0 + age) * 3.0
	draw_circle(pos, pulse_r + 10.0, Color(c.r, c.g, c.b, 0.12))
	draw_circle(pos, pulse_r, Color(c.r * 0.18, c.g * 0.18, c.b * 0.18, 0.78))
	var start: float = pulse_time * 0.80
	draw_arc(pos, pulse_r, start, start + PI * 1.50, 64, Color(c.r, c.g, c.b, 0.72), 3.0, true)
	draw_circle(pos, 10.0, Color(c.r, c.g, c.b, 0.90))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-9.0, 8.0), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1, 0.90))

func _draw_skin_trails() -> void:
	for st in skin_trails:
		var age: float = float(st["age"])
		var dur: float = float(st["duration"])
		var t_frac: float = 1.0 - age / maxf(dur, 0.001)
		var c: Color = st["color"]
		var sz: float = float(st["size"]) * t_frac
		draw_circle(st["pos"], sz, Color(c.r, c.g, c.b, t_frac * 0.55))

func _draw_particles() -> void:
	for p in particles:
		var age: float = float(p["age"])
		var dur: float = float(p["duration"])
		var t_frac: float = 1.0 - age / maxf(dur, 0.001)
		var c: Color = p["color"]
		var sz: float = float(p.get("size", 4.0)) * t_frac
		draw_circle(Vector2(float(p["x"]), float(p["y"])), sz, Color(c.r, c.g, c.b, c.a * t_frac))

func _draw_shockwaves() -> void:
	for sw in shockwaves:
		var age: float = float(sw["age"])
		var dur: float = float(sw["duration"])
		var t_frac: float = age / maxf(dur, 0.001)
		var radius: float = lerp(float(sw["start"]), float(sw["end"]), t_frac)
		var alpha: float = (1.0 - t_frac) * 0.55
		var c: Color = sw["color"]
		draw_arc(sw["pos"], radius, 0.0, TAU, 64, Color(c.r, c.g, c.b, alpha), 2.2)


func _load_player_png_direct(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("Player PNG nao carregou: " + path)

	return tex

func _load_player_png_frames(folder: String, prefix: String, count: int, target: Array[Texture2D]) -> void:
	target.clear()

	for i: int in range(1, count + 1):
		var frame_path: String = "%s/%s_%02d.png" % [folder, prefix, i]
		var tex: Texture2D = _load_player_png_direct(frame_path)

		if tex != null:
			target.append(tex)

func _ensure_player_png_loaded() -> void:
	if player_png_loaded:
		return

	player_png_loaded = true

	_load_player_png_frames("res://assets/characters/stick_runner/frames/run", "run", 8, player_run_frames_png)
	_load_player_png_frames("res://assets/characters/stick_runner/frames/dash", "dash", 6, player_dash_frames_png)
	_load_player_png_frames("res://assets/characters/stick_runner/frames/hit", "hit", 8, player_hit_frames_png)

func _draw_player_png_frame(tex: Texture2D, pos: Vector2, target_h: float) -> void:
	if tex == null:
		return

	var aspect: float = float(tex.get_width()) / maxf(float(tex.get_height()), 1.0)
	var size_px: Vector2 = Vector2(target_h * aspect, target_h)

	draw_set_transform(pos, 0.0, Vector2.ONE)
	draw_texture_rect(
		tex,
		Rect2(-size_px.x * 0.5, -size_px.y * 0.5, size_px.x, size_px.y),
		false,
		Color(1, 1, 1, 1)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _load_entity_png_direct(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("Entity PNG nao carregou: " + path)

	return tex

func _ensure_entity_png_loaded() -> void:
	if entity_png_loaded:
		return

	entity_png_loaded = true

	crystal_common_png = _load_entity_png_direct("res://assets/crystals/crystal_common.png")
	crystal_rare_png = _load_entity_png_direct("res://assets/crystals/crystal_rare.png")
	crystal_legendary_png = _load_entity_png_direct("res://assets/crystals/crystal_legendary.png")
	crystal_glow_png = _load_entity_png_direct("res://assets/crystals/crystal_glow.png")

	obstacle_bamboo_png = _load_entity_png_direct("res://assets/obstacles/obs_bamboo_spike.png")
	obstacle_blade_png = _load_entity_png_direct("res://assets/obstacles/obs_broken_blade.png")
	obstacle_cursed_png = _load_entity_png_direct("res://assets/obstacles/obs_cursed_shard.png")
	obstacle_fragment_png = _load_entity_png_direct("res://assets/obstacles/obs_fragment_spike.png")
	obstacle_rock_png = _load_entity_png_direct("res://assets/obstacles/obs_spiritual_rock.png")

func _draw_entity_png_center(tex: Texture2D, center: Vector2, size_px: Vector2, tint: Color = Color(1, 1, 1, 1), rotation: float = 0.0) -> void:
	if tex == null:
		return

	draw_set_transform(center, rotation, Vector2.ONE)
	draw_texture_rect(
		tex,
		Rect2(-size_px.x * 0.5, -size_px.y * 0.5, size_px.x, size_px.y),
		false,
		tint
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_crystal_png_overlay(pos: Vector2, crystal_type: String) -> void:
	var tex: Texture2D = crystal_common_png
	var glow_color: Color = Color(0.25, 1.0, 0.70, 1.0)
	var size_px: float = 58.0

	match crystal_type:
		"rare":
			tex = crystal_rare_png
			size_px = 64.0
			glow_color = Color(0.40, 1.0, 0.95, 1.0)
		"epic":
			tex = crystal_rare_png
			size_px = 68.0
			glow_color = Color(0.82, 0.55, 1.0, 1.0)
		"legendary":
			tex = crystal_legendary_png
			size_px = 74.0
			glow_color = Color(1.0, 0.82, 0.34, 1.0)
		_:
			tex = crystal_common_png

	var pulse: float = 1.0 + sin(pulse_time * 3.6 + pos.x * 0.01) * 0.05

	if crystal_glow_png != null:
		_draw_entity_png_center(
			crystal_glow_png,
			pos,
			Vector2(size_px * 1.9, size_px * 1.9) * pulse,
			Color(glow_color.r, glow_color.g, glow_color.b, 0.55)
		)
	else:
		draw_circle(pos, size_px * 0.62, Color(glow_color.r, glow_color.g, glow_color.b, 0.18))

	_draw_entity_png_center(tex, pos, Vector2(size_px, size_px) * pulse)

func _draw_obstacle_png_overlay(pos: Vector2, otype: String) -> void:
	var tex: Texture2D = obstacle_bamboo_png
	var size_px: Vector2 = Vector2(98.0, 112.0)
	var danger: Color = Color(1.0, 0.18, 0.18, 1.0)
	var rot: float = 0.0

	match otype:
		"bamboo_wall":
			tex = obstacle_bamboo_png
			size_px = Vector2(98.0, 118.0)
		"stone_pillar":
			tex = obstacle_rock_png
			size_px = Vector2(100.0, 112.0)
		"energy_barrier":
			tex = obstacle_cursed_png
			size_px = Vector2(112.0, 96.0)
			danger = Color(0.90, 0.32, 1.0, 1.0)
		"spirit_trap":
			tex = obstacle_fragment_png
			size_px = Vector2(108.0, 108.0)
			danger = Color(0.90, 0.32, 1.0, 1.0)
			rot = sin(pulse_time * 1.4) * 0.08
		"spinning_blade":
			tex = obstacle_blade_png
			size_px = Vector2(112.0, 112.0)
			rot = pulse_time * 1.8
		_:
			tex = obstacle_fragment_png

	draw_circle(pos, maxf(size_px.x, size_px.y) * 0.46, Color(danger.r, danger.g, danger.b, 0.14))
	_draw_entity_png_center(tex, pos, size_px, Color(1, 1, 1, 1), rot)


func _load_vfx_png_direct(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("VFX PNG nao carregou: " + path)

	return tex

func _ensure_vfx_png_loaded() -> void:
	if vfx_png_loaded:
		return

	vfx_png_loaded = true

	vfx_pickup_png = _load_vfx_png_direct("res://assets/vfx/vfx_pickup_burst.png")
	vfx_dash_png = _load_vfx_png_direct("res://assets/vfx/vfx_dash_smear.png")
	vfx_trail_png = _load_vfx_png_direct("res://assets/vfx/vfx_trail_streak.png")
	vfx_impact_png = _load_vfx_png_direct("res://assets/vfx/vfx_impact_flash.png")
	vfx_combo_png = _load_vfx_png_direct("res://assets/vfx/vfx_combo_burst.png")
	vfx_aura_png = _load_vfx_png_direct("res://assets/vfx/vfx_aura_ring.png")


func _spawn_vfx_png(pos: Vector2, kind: String, color: Color, size_px: float, duration: float, rotation: float = 0.0) -> void:
	if vfx_system != null:
		vfx_system.spawn_vfx_png(pos, kind, color, size_px, duration, rotation)
		return

	vfx_png_sprites.append({
		"pos": pos,
		"kind": kind,
		"color": color,
		"size": size_px,
		"duration": duration,
		"age": 0.0,
		"rotation": rotation
	})

	if vfx_png_sprites.size() > 64:
		vfx_png_sprites.remove_at(0)
func _update_vfx_png(delta: float) -> void:
	var remove_list: Array[int] = []

	for i: int in range(vfx_png_sprites.size()):
		var vf: Dictionary = vfx_png_sprites[i]
		vf["age"] = float(vf["age"]) + delta
		vfx_png_sprites[i] = vf

		if float(vf["age"]) >= float(vf["duration"]):
			remove_list.append(i)

	remove_list.reverse()

	for idx: int in remove_list:
		vfx_png_sprites.remove_at(idx)

func _draw_vfx_png_center(tex: Texture2D, center: Vector2, size_px: Vector2, tint: Color, rotation: float) -> void:
	if tex == null:
		return

	draw_set_transform(center, rotation, Vector2.ONE)
	draw_texture_rect(
		tex,
		Rect2(-size_px.x * 0.5, -size_px.y * 0.5, size_px.x, size_px.y),
		false,
		tint
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _load_hud_png_direct(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("HUD PNG nao carregou: " + path)

	return tex

func _ensure_hud_png_loaded() -> void:
	if hud_png_loaded:
		return

	hud_png_loaded = true

	hud_icon_crystal_png = _load_hud_png_direct("res://assets/ui/ui_icon_crystal.png")
	hud_icon_dash_png = _load_hud_png_direct("res://assets/ui/ui_icon_dash.png")
	hud_icon_combo_png = _load_hud_png_direct("res://assets/ui/ui_icon_combo.png")
	hud_icon_pause_png = _load_hud_png_direct("res://assets/ui/ui_icon_pause.png")
	hud_panel_png = _load_hud_png_direct("res://assets/ui/ui_panel_hud.png")


func _draw_hud_panel_png_rect(rect: Rect2, tint: Color = Color(1, 1, 1, 1)) -> void:
	if hud_panel_png == null:
		var flat_color := Color(0.002, 0.030, 0.020, 0.72)
		draw_rect(rect, flat_color)
		draw_arc(rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.5), minf(rect.size.x, rect.size.y) * 0.42, 0.0, TAU, 48, Color(0.14, 1.0, 0.65, 0.28), 1.4, true)
		return

	draw_texture_rect(
		hud_panel_png,
		rect,
		false,
		tint
	)

func _draw_hud_png_center(tex: Texture2D, center: Vector2, size_px: float, tint: Color) -> void:
	draw_circle(center, size_px * 0.58, Color(0.003, 0.025, 0.014, 0.74))
	draw_circle(center, size_px * 0.50, Color(tint.r, tint.g, tint.b, 0.16))
	draw_arc(center, size_px * 0.52, pulse_time * 0.7, pulse_time * 0.7 + PI * 1.28, 48, Color(tint.r, tint.g, tint.b, 0.42), 2.0, true)

	if tex == null:
		draw_circle(center, size_px * 0.18, Color(tint.r, tint.g, tint.b, 0.92))
		return

	draw_set_transform(center, 0.0, Vector2.ONE)
	draw_texture_rect(
		tex,
		Rect2(-size_px * 0.5, -size_px * 0.5, size_px, size_px),
		false,
		Color(1, 1, 1, 0.96)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hud_png_overlays() -> void:
	if screen not in ["game", "countdown", "pause"]:
		return

	_ensure_hud_png_loaded()

	# Painéis premium por trás dos cards do HUD
	_draw_hud_panel_png_rect(Rect2(8, 8, 134, 76), Color(1, 1, 1, 0.74))
	_draw_hud_panel_png_rect(Rect2(156, 8, 214, 76), Color(1, 1, 1, 0.66))
	_draw_hud_panel_png_rect(Rect2(GameConfig.VIEW_W - 188.0, 8, 142, 116), Color(1, 1, 1, 0.70))

	# Esquerda: cristal / pontuação
	_draw_hud_png_center(hud_icon_crystal_png, Vector2(34, 34), 42.0, GameConfig.C_ENERGY)

	# Direita: combo e dash
	_draw_hud_png_center(hud_icon_combo_png, Vector2(GameConfig.VIEW_W - 168.0, 34.0), 40.0, GameConfig.C_GOLD)
	_draw_hud_png_center(hud_icon_dash_png, Vector2(GameConfig.VIEW_W - 168.0, 76.0), 40.0, GameConfig.C_JADE)

	# Pause no canto superior direito
	_draw_hud_png_center(hud_icon_pause_png, Vector2(GameConfig.VIEW_W - 36.0, 34.0), 38.0, GameConfig.C_PEARL)


func _draw_vfx_png_overlays() -> void:
	if screen not in ["game", "countdown", "pause"]:
		return

	_ensure_vfx_png_loaded()

	for item: Variant in vfx_png_sprites:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var vf: Dictionary = item

		var pos: Vector2 = vf["pos"]
		var kind: String = str(vf.get("kind", "pickup"))
		var color: Color = vf["color"]
		var size_px: float = float(vf.get("size", 96.0))
		var duration: float = maxf(float(vf.get("duration", 0.25)), 0.001)
		var age: float = float(vf.get("age", 0.0))
		var rotation: float = float(vf.get("rotation", 0.0))

		var tex: Texture2D = vfx_pickup_png

		match kind:
			"dash":
				tex = vfx_dash_png
			"trail":
				tex = vfx_trail_png
			"impact":
				tex = vfx_impact_png
			"combo":
				tex = vfx_combo_png
			"aura":
				tex = vfx_aura_png
			_:
				tex = vfx_pickup_png

		var progress: float = clampf(age / duration, 0.0, 1.0)
		var alpha: float = 1.0 - progress
		var scale_boost: float = 1.0 + progress * 0.38
		var final_size: Vector2 = Vector2(size_px, size_px) * scale_boost

		if tex != null:
			_draw_vfx_png_center(tex, pos, final_size, Color(color.r, color.g, color.b, alpha), rotation)
		else:
			draw_circle(pos, size_px * 0.18 * scale_boost, Color(color.r, color.g, color.b, alpha * 0.70))


func _draw_entity_png_overlays() -> void:
	if screen not in ["game", "countdown", "pause"]:
		return

	_ensure_entity_png_loaded()

	for item: Variant in entities:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var e: Dictionary = item
		var pos: Vector2 = Vector2(float(e.get("x", 0.0)), float(e.get("y", 0.0)))
		var etype: String = str(e.get("type", ""))

		if etype == "crystal":
			_draw_crystal_png_overlay(pos, str(e.get("crystal_type", "common")))
		elif etype == "obstacle":
			_draw_obstacle_png_overlay(pos, str(e.get("otype", "bamboo_wall")))

func _try_draw_player_png() -> bool:
	_ensure_player_png_loaded()

	var frames: Array[Texture2D] = player_run_frames_png
	var fps: float = 14.0
	var target_h: float = 150.0

	if player_state == "dash" and player_dash_frames_png.size() > 0:
		frames = player_dash_frames_png
		fps = 18.0
		target_h = 168.0
	elif player_state == "hit" and player_hit_frames_png.size() > 0:
		frames = player_hit_frames_png
		fps = 12.0
		target_h = 154.0

	if frames.size() <= 0:
		return false

	var idx: int = int(pulse_time * fps) % frames.size()
	var tex: Texture2D = frames[idx]

	# Ajuste fino de posição do sprite na corrida
	var draw_pos: Vector2 = player.position + Vector2(0, -38)

	_draw_player_png_frame(tex, draw_pos, target_h)

	return true


func _draw_player() -> void:
	if _try_draw_player_png():
		return

	if screen not in ["game", "countdown", "pause"]:
		return
	_draw_stickman_at(player.position, selected_skin, player_lean, player_run_phase, player_state, player_hit_flash, Color(1, 1, 1, 1))
func _draw_stickman_at(pos: Vector2, skin_id: String, lean: float, phase: float, state: String, hit_flash: float, tint: Color) -> void:
	var c: Color   = skin_color(skin_id)
	var gc: Color  = skin_glow_color(skin_id)
	c   = Color(c.r * tint.r, c.g * tint.g, c.b * tint.b, c.a * tint.a)
	gc  = Color(gc.r * tint.r, gc.g * tint.g, gc.b * tint.b, gc.a * tint.a)

	# Dimensions
	var head_r: float = 16.0
	var body_h: float = 38.0
	var arm_l: float  = 25.0
	var leg_l: float  = 30.0
	var stroke: float = 3.4

	# Lean physics
	var lx: float = lean * 13.0
	var ly: float = -absf(lean) * 4.0
	var bob: float = sin(phase * 14.0) * 2.0 if state in ["running", "moving_left", "moving_right"] else 0.0

	var head: Vector2 = pos + Vector2(lx, -body_h - head_r + ly + bob)
	var neck: Vector2 = pos + Vector2(lx * 0.80, -body_h + ly + bob)
	var hip:  Vector2 = pos + Vector2(lx * 0.30, 0.0 + bob)
	var chest: Vector2 = neck.lerp(hip, 0.36)

	# Hit flash overlay
	if hit_flash > 0.0:
		c  = c.lerp(Color(1.0, 0.30, 0.30, c.a), hit_flash * 0.80)
		gc = gc.lerp(Color(1.0, 0.50, 0.50, gc.a), hit_flash * 0.70)

	# Outer glow halo
	draw_circle(head, head_r + 16.0, Color(gc.r, gc.g, gc.b, 0.08 * tint.a))
	draw_circle(chest, 22.0, Color(gc.r, gc.g, gc.b, 0.06 * tint.a))
	# Body glow line
	draw_line(neck + Vector2(-1, 0), hip + Vector2(-1, 0), Color(gc.r, gc.g, gc.b, 0.22 * tint.a), stroke + 5.0)
	# Head glow
	draw_circle(head, head_r + 6.0, Color(gc.r, gc.g, gc.b, 0.26 * tint.a))

	if state == "dash":
		_draw_stickman_dash(pos, c, gc, head_r, body_h, arm_l, leg_l, stroke, lx, ly, tint)
	elif state == "hit":
		_draw_stickman_hit(pos, c, gc, head_r, body_h, arm_l, leg_l, stroke, tint)
	else:
		# Running animation
		var sp: float = phase * 7.0
		var arm_swing: float = sin(sp) * 20.0
		var leg_swing: float = sin(sp) * 24.0

		draw_line(neck, hip, Color(c.r, c.g, c.b, 0.92), stroke)
		draw_circle(head, head_r, Color(c.r, c.g, c.b, 0.88))
		draw_circle(head, head_r * 0.50, Color(1.0, 1.0, 1.0, 0.22 * tint.a))

		var shoulder: Vector2 = neck + Vector2(0, 11)
		draw_line(shoulder, shoulder + Vector2(-arm_l * 0.45 + arm_swing * 0.58, arm_l * 0.72), Color(c.r, c.g, c.b, 0.84), stroke - 0.7)
		draw_line(shoulder, shoulder + Vector2(arm_l * 0.45 - arm_swing * 0.58, arm_l * 0.72), Color(c.r, c.g, c.b, 0.84), stroke - 0.7)

		draw_line(hip + Vector2(-5, 0), hip + Vector2(-5 - leg_swing * 0.45, leg_l), Color(c.r, c.g, c.b, 0.84), stroke - 0.7)
		draw_line(hip + Vector2(5, 0), hip + Vector2(5 + leg_swing * 0.45, leg_l), Color(c.r, c.g, c.b, 0.84), stroke - 0.7)

	# Crystal on chest
	var cs: float = 8.5
	var cpts: PackedVector2Array = PackedVector2Array([
		chest + Vector2(0, -cs),
		chest + Vector2(cs * 0.72, 0),
		chest + Vector2(0, cs),
		chest + Vector2(-cs * 0.72, 0)
	])
	draw_colored_polygon(cpts, Color(gc.r, gc.g, gc.b, 0.92 * tint.a))
	draw_circle(chest, cs * 0.30, Color(1.0, 1.0, 1.0, 0.82 * tint.a))

func _draw_stickman_dash(pos: Vector2, c: Color, gc: Color, head_r: float, body_h: float, arm_l: float, leg_l: float, stroke: float, lx: float, ly: float, tint: Color) -> void:
	var speed_tilt: float = -0.28
	var dn: Vector2 = pos + Vector2(-6.0, -body_h * 0.85)
	var dh: Vector2 = pos + Vector2(10.0, -body_h * 0.06)
	draw_line(dn, dh, Color(c.r, c.g, c.b, 0.92), stroke)
	draw_circle(dn + Vector2(0, -head_r), head_r, Color(c.r, c.g, c.b, 0.88))
	draw_circle(dn + Vector2(0, -head_r), head_r * 0.45, Color(1.0, 1.0, 1.0, 0.22 * tint.a))
	# Arms swept back
	draw_line(dn + Vector2(0, 10), dn + Vector2(-arm_l - 5.0, 6.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	draw_line(dn + Vector2(0, 10), dn + Vector2(arm_l + 2.0, 16.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	# Legs trailing
	draw_line(dh, dh + Vector2(-10.0, leg_l * 0.55), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	draw_line(dh, dh + Vector2(6.0, leg_l * 0.65), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	# Dash energy trail
	for i in range(5):
		var t_off: float = float(i) * 10.0
		draw_circle(pos + Vector2(-t_off * 0.8, t_off * 0.3), 6.0 - float(i) * 0.9, Color(gc.r, gc.g, gc.b, (0.55 - float(i) * 0.10) * tint.a))

func _draw_stickman_hit(pos: Vector2, c: Color, gc: Color, head_r: float, body_h: float, arm_l: float, leg_l: float, stroke: float, tint: Color) -> void:
	var neck: Vector2 = pos + Vector2(0, -body_h)
	var hip: Vector2 = pos
	draw_line(neck, hip, Color(c.r, c.g, c.b, 0.90), stroke)
	draw_circle(neck + Vector2(0, -head_r), head_r, Color(c.r, c.g, c.b, 0.88))
	draw_circle(neck + Vector2(0, -head_r), head_r * 0.45, Color(1.0, 1.0, 1.0, 0.22 * tint.a))
	# Arms flung wide
	draw_line(neck + Vector2(0, 12), neck + Vector2(-arm_l - 4.0, -8.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	draw_line(neck + Vector2(0, 12), neck + Vector2(arm_l + 4.0, -8.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	# Legs bent outward
	draw_line(hip, hip + Vector2(-leg_l * 0.75, 14.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)
	draw_line(hip, hip + Vector2(leg_l * 0.75, 14.0), Color(c.r, c.g, c.b, 0.85), stroke - 0.8)

func _draw_player_aura() -> void:
	if screen not in ["game", "countdown"]:
		return
	var c: Color = skin_glow_color(selected_skin)
	var base_alpha: float = 0.06
	if flow_timer > 0.0:
		base_alpha = 0.18 + sin(pulse_time * 4.0) * 0.06
		c = GameConfig.C_GOLD
	if invulnerable_timer > 0.0 and int(pulse_time * 8.0) % 2 == 0:
		draw_circle(player.position, 36.0, Color(c.r, c.g, c.b, base_alpha + 0.08))
	else:
		draw_circle(player.position, 28.0, Color(c.r, c.g, c.b, base_alpha))
	if magnet_timer > 0.0:
		var mr: float = 155.0 + float(tech_level("jade")) * 25.0
		var ma: float = 0.04 + sin(pulse_time * 3.5) * 0.02
		draw_arc(player.position, mr, pulse_time * 0.6, pulse_time * 0.6 + PI * 1.10, 48, Color(GameConfig.C_JADE.r, GameConfig.C_JADE.g, GameConfig.C_JADE.b, ma), 1.5, true)

func _draw_resonance_circles() -> void:
	if screen != "game":
		return
	var cnt: int = unlocked_circle_count()
	if cnt <= 0:
		return
	for i in range(cnt):
		var circle_data: Dictionary = GameConfig.RESONANCE_CIRCLES[i]
		var cc: Color = circle_data["color"]
		var r: float = 68.0 + float(i) * 14.0 + sin(pulse_time * (0.8 + float(i) * 0.12) + float(i)) * 4.0
		var start_angle: float = pulse_time * (0.20 + float(i) * 0.04) + float(i) * 0.55
		var arc_alpha: float = (0.10 if flow_timer <= 0.0 else 0.22) + (resonance_value / 100.0) * 0.10
		draw_arc(player.position, r, start_angle, start_angle + PI * 1.15, 72, Color(cc.r, cc.g, cc.b, arc_alpha), 1.8, true)

func _draw_dash_meter() -> void:
	if screen != "game":
		return
	var max_cd: float = maxf(1.4, 2.8 - float(tech_level("dash")) * 0.28)
	var fill_frac: float = clampf(1.0 - dash_cooldown / max_cd, 0.0, 1.0)
	var cx: float = GameConfig.VIEW_W - 52.0
	var cy: float = GameConfig.VIEW_H - 92.0
	var radius: float = 22.0
	draw_circle(Vector2(cx, cy), radius + 4.0, Color(0.010, 0.038, 0.016, 0.72))
	draw_arc(Vector2(cx, cy), radius, -PI * 0.5, -PI * 0.5 + TAU * fill_frac, 48, Color(GameConfig.C_ENERGY.r, GameConfig.C_ENERGY.g, GameConfig.C_ENERGY.b, 0.85), 4.0, true)
	if fill_frac >= 1.0:
		draw_circle(Vector2(cx, cy), 12.0, Color(GameConfig.C_ENERGY.r, GameConfig.C_ENERGY.g, GameConfig.C_ENERGY.b, 0.82))

func _draw_form_unlock_overlay() -> void:
	if form_unlock_timer <= 0.0:
		return
	var alpha: float = minf(form_unlock_timer * 1.4, 1.0) * 0.75
	var c: Color = skin_color(form_unlock_skin)
	draw_rect(Rect2(Vector2.ZERO, Vector2(GameConfig.VIEW_W, GameConfig.VIEW_H)), Color(c.r * 0.12, c.g * 0.12, c.b * 0.12, alpha * 0.24))
	var cx: float = GameConfig.VIEW_W * 0.5
	var cy: float = GameConfig.VIEW_H * 0.45
	draw_circle(Vector2(cx, cy), 220.0 * (1.0 + (2.8 - form_unlock_timer) * 0.12), Color(c.r, c.g, c.b, alpha * 0.08))
	draw_string(ThemeDB.fallback_font, Vector2(cx - 180.0, cy), "NOVA FORMA DESPERTA", HORIZONTAL_ALIGNMENT_CENTER, 360.0, 28, Color(c.r, c.g, c.b, alpha))
	draw_string(ThemeDB.fallback_font, Vector2(cx - 180.0, cy + 40), form_unlock_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 360.0, 36, Color(1, 1, 1, alpha))

func _draw_flash_overlay() -> void:
	if flash_alpha <= 0.01:
		return
	var biome: Dictionary = get_current_biome()
	var accent: Color = biome["accent"]
	draw_rect(Rect2(Vector2.ZERO, Vector2(GameConfig.VIEW_W, GameConfig.VIEW_H)), Color(accent.r, accent.g, accent.b, flash_alpha * 0.40))

func _draw_neo_shell() -> void:
	var accent: Color = GameConfig.C_JADE
	if screen == "shop":
		accent = rarity_color_for(skin_rarity(selected_shop_skin))
	elif screen == "cultivation":
		accent = GameConfig.C_GOLD

	draw_rect(Rect2(Vector2.ZERO, Vector2(GameConfig.VIEW_W, GameConfig.VIEW_H)), Color(0.008, 0.022, 0.012, 0.65))
	# Subtle grid
	for i in range(9):
		var ly: float = 220.0 + float(i) * 76.0 + sin(pulse_time * 0.32 + float(i)) * 8.0
		draw_line(Vector2(44.0, ly), Vector2(GameConfig.VIEW_W - 44.0, ly + sin(float(i)) * 18.0), Color(accent.r, accent.g, accent.b, 0.018), 1.0)
	# Ambient orb
	var top: Vector2 = Vector2(GameConfig.VIEW_W * 0.5, 128.0)
	draw_circle(top, 320.0, Color(accent.r, accent.g, accent.b, 0.024))
	for i in range(4):
		var r: float = 108.0 + float(i) * 26.0 + sin(pulse_time * 0.45 + float(i)) * 4.0
		var a: float = pulse_time * 0.12 + float(i) * 0.70
		draw_arc(top, r, a, a + PI * 1.22, 96, Color(accent.r, accent.g, accent.b, 0.038), 1.5, true)

func _draw_result_badges() -> void:
	if result_reveal_timer < 0.5:
		return
	var badges: Array = [
		{"label": "Distância", "value": "%d m" % int(distance),    "color": GameConfig.C_JADE,   "x": 130.0},
		{"label": "Cristais",  "value": str(crystals_run),           "color": GameConfig.C_ENERGY, "x": 360.0},
		{"label": "Combo",     "value": "x%d" % max_combo_run,       "color": GameConfig.C_GOLD,   "x": 590.0},
	]
	var base_y: float = 196.0
	for bd in badges:
		var bpos: Vector2 = Vector2(float(bd["x"]), base_y)
		var bc: Color = bd["color"]
		var pulse_sc: float = 1.0 + sin(result_badge_pulse * 2.0) * 0.014
		draw_circle(bpos, 52.0 * pulse_sc, Color(bc.r, bc.g, bc.b, 0.055))
		var start: float = pulse_time * 0.22
		draw_arc(bpos, 46.0 * pulse_sc, start, start + PI * 1.40, 72, Color(bc.r, bc.g, bc.b, 0.22), 2.0, true)
		draw_string(ThemeDB.fallback_font, bpos + Vector2(-60.0, -10.0), str(bd["value"]), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 20, Color(GameConfig.C_PEARL.r, GameConfig.C_PEARL.g, GameConfig.C_PEARL.b, 0.92))
		draw_string(ThemeDB.fallback_font, bpos + Vector2(-60.0, 18.0), str(bd["label"]), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 13, Color(0.76, 0.94, 0.82, 0.72))
