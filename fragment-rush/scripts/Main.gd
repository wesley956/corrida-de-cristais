extends Node2D

# Fragment Rush: Corrida dos Cristais
# v0.2 - Cultivation Visual Update
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

var score_label: Label
var crystal_label: Label
var combo_label: Label
var distance_label: Label
var best_label: Label
var status_label: Label
var resonance_label: Label

var title_label: Label
var subtitle_label: Label
var start_button: Button
var shop_button: Button
var close_shop_button: Button
var shop_info_label: Label

var result_title: Label
var result_stats: Label
var restart_button: Button
var menu_button: Button

var entities: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var qi_particles: Array[Dictionary] = []
var mountains: Array[Dictionary] = []
var particles: Array[Dictionary] = []

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
	update_background(real_delta)
	update_particles(real_delta)
	if screen == "game":
		update_game(game_delta, real_delta)
	else:
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

	score_label = make_label("0", 34, Vector2(28, 22), C_PEARL)
	crystal_label = make_label("Cristais: 0", 24, Vector2(28, 72), C_CELESTIAL)
	distance_label = make_label("Marca: 0 m", 24, Vector2(28, 108), Color(0.74, 0.90, 1.0, 1.0))
	combo_label = make_label("", 28, Vector2(220, 72), C_GOLD)
	resonance_label = make_label("Ressonância 0%", 21, Vector2(28, 145), C_JADE)
	status_label = make_label("", 30, Vector2(0, 218), C_GOLD)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size = Vector2(VIEW_W, 70)
	var hud_nodes: Array[Control] = [score_label, crystal_label, distance_label, combo_label, resonance_label, status_label]
	for node in hud_nodes:
		hud_layer.add_child(node)

	title_label = make_label("FRAGMENT RUSH\nCorrida dos Cristais", 47, Vector2(0, 210), C_PEARL)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size = Vector2(VIEW_W, 140)
	subtitle_label = make_label("Quanto mais perto do caos, maior a ressonância.", 22, Vector2(60, 360), Color(0.78, 0.95, 1.0, 1.0))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.size = Vector2(600, 70)
	best_label = make_label("", 24, Vector2(0, 448), Color(0.68, 0.88, 1.0, 1.0))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.size = Vector2(VIEW_W, 60)
	start_button = make_button("INICIAR CORRIDA", Vector2(164, 585), Vector2(392, 78))
	shop_button = make_button("FORMAS / PAVILHÃO", Vector2(164, 688), Vector2(392, 72))
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(show_shop)
	var menu_nodes: Array[Control] = [title_label, subtitle_label, best_label, start_button, shop_button]
	for node in menu_nodes:
		menu_layer.add_child(node)

	result_title = make_label("FLUXO INTERROMPIDO", 42, Vector2(0, 235), C_PEARL)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.size = Vector2(VIEW_W, 80)
	result_stats = make_label("", 25, Vector2(82, 345), Color(0.86, 0.96, 1.0, 1.0))
	result_stats.size = Vector2(565, 300)
	restart_button = make_button("CULTIVAR NOVAMENTE", Vector2(150, 690), Vector2(420, 78))
	menu_button = make_button("VOLTAR À TRILHA", Vector2(190, 790), Vector2(340, 70))
	restart_button.pressed.connect(start_game)
	menu_button.pressed.connect(show_menu)
	var result_nodes: Array[Control] = [result_title, result_stats, restart_button, menu_button]
	for node in result_nodes:
		result_layer.add_child(node)

	shop_info_label = make_label("", 23, Vector2(55, 185), C_PEARL)
	shop_info_label.size = Vector2(610, 760)
	close_shop_button = make_button("VOLTAR", Vector2(210, 1035), Vector2(300, 70))
	close_shop_button.pressed.connect(show_menu)
	shop_layer.add_child(shop_info_label)
	shop_layer.add_child(close_shop_button)

func make_label(text: String, size_font: int, pos: Vector2, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", size_font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

func make_button(text: String, pos: Vector2, size_btn: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.position = pos
	button.size = size_btn
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", C_PEARL)
	button.add_theme_stylebox_override("normal", make_button_style(C_PANEL, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.50)))
	button.add_theme_stylebox_override("hover", make_button_style(Color(0.06, 0.22, 0.34, 0.90), C_JADE))
	button.add_theme_stylebox_override("pressed", make_button_style(Color(0.03, 0.16, 0.24, 0.95), C_GOLD))
	return button

func make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(24)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 12
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
	hud_layer.visible = true
	entities.clear()
	particles.clear()
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
	hud_layer.visible = false
	best_label.text = "Marca de Ascensão: %d m  •  Cristais: %d" % [int(best_distance), total_crystals]

func show_shop() -> void:
	screen = "shop"
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = true
	hud_layer.visible = false
	var lines: Array[String] = []
	lines.append("PAVILHÃO DAS FORMAS")
	lines.append("")
	lines.append("Cristais Espirituais: %d" % total_crystals)
	lines.append("")
	lines.append("✓ Núcleo Errante — liberado")
	lines.append("• Semente de Jade — 1000 cristais")
	lines.append("• Orbe Celestial — 2500 cristais")
	lines.append("• Coração Nebular — 4000 cristais")
	lines.append("• Essência Dourada — evento raro")
	lines.append("")
	lines.append("Técnicas em preparo:")
	lines.append("• seleção visual de formas")
	lines.append("• rastros espirituais")
	lines.append("• baús de essência")
	lines.append("• eventos da Trilha do Céu Fragmentado")
	lines.append("")
	lines.append("Regra do jogo:")
	lines.append("Quanto mais perto do caos, maior a ressonância.")
	shop_info_label.text = "\n".join(lines)

func update_game(delta: float, real_delta: float) -> void:
	run_time += real_delta
	difficulty += real_delta * 0.018
	speed = minf(820.0, 390.0 + distance * 0.03 + difficulty * 42.0)
	distance += speed * delta * 0.045
	score += int(14.0 * delta * (1.0 + float(combo) * 0.08))
	resonance_value = maxf(0.0, resonance_value - real_delta * 2.5)
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
	player.scale = Vector2.ONE * (1.0 + sin(run_time * 9.0) * 0.025 + dash_scale)
	player_core.color = skin_color(selected_skin)
	player_glow.color = Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.22 + clampf(resonance_value / 100.0, 0.0, 0.18))
	player_ring.color = Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.10 + clampf(resonance_value / 120.0, 0.0, 0.20))
	if dash_timer > 0.0:
		spawn_particle(player.position, Color(C_JADE.r, C_JADE.g, C_JADE.b, 0.82), 9, 0.42)

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
	score_label.text = str(score)
	crystal_label.text = "Cristais: %d" % crystals_run
	distance_label.text = "Marca: %d m" % int(distance)
	combo_label.text = "Fluxo x%d" % combo if combo > 1 else ""
	resonance_label.text = "Ressonância %d%%" % int(clampf(resonance_value, 0.0, 100.0))

func move_lane(dir: int) -> void:
	player_lane = clampi(player_lane + dir, 0, LANES.size() - 1)
	target_x = screen_lane_x(player_lane)
	camera_shake = maxf(camera_shake, 2.0)

func do_dash() -> void:
	if dash_cooldown <= 0.0:
		dash_timer = 0.18
		dash_cooldown = 1.15
		invulnerable_timer = maxf(invulnerable_timer, 0.2)
		resonance_value = minf(100.0, resonance_value + 4.0)
		show_status("PASSO ESPIRITUAL", C_JADE)
		for _i in range(12):
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
	var value: int = int(e.get("value", 1))
	crystals_run += value * multiplier
	score += 30 * multiplier
	combo += 1
	resonance_value = minf(100.0, resonance_value + 0.8)
	var crystal_pos: Vector2 = e["pos"]
	spawn_particle(crystal_pos, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.85), 10, 0.5)
	if combo % 10 == 0:
		show_status("Fluxo x%d" % combo, C_GOLD)

func collect_power(kind: String) -> void:
	match kind:
		"magnet":
			magnet_timer = 6.0
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
	spawn_particle(player.position, Color(1.0, 1.0, 1.0, 0.75), 18, 0.7)

func perfect_graze() -> void:
	perfect_grazes += 1
	combo += 2
	var bonus: int = 90 + combo * 5
	score += bonus
	resonance_value = minf(100.0, resonance_value + 13.0)
	camera_shake = 8.0
	show_status("RESSONÂNCIA PERFEITA +%d" % bonus, C_GOLD)
	for _i in range(18):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-46.0, 46.0), rng.randf_range(-46.0, 46.0))
		spawn_particle(particle_pos, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.86), 8, 0.45)

func game_over() -> void:
	screen = "result"
	total_crystals += crystals_run
	best_distance = maxf(best_distance, distance)
	save_game()
	hud_layer.visible = false
	result_layer.visible = true
	menu_layer.visible = false
	shop_layer.visible = false
	var new_mark: String = "\nNova Marca de Ascensão!" if int(distance) >= int(best_distance) else ""
	result_stats.text = "Distância: %d m\nPontuação: %d\nCristais Espirituais: %d\nRessonâncias Perfeitas: %d\nMaior Fluxo: x%d\n%s\n\nTotal de Cristais: %d\nMarca de Ascensão: %d m" % [int(distance), score, crystals_run, perfect_grazes, combo, new_mark, total_crystals, int(best_distance)]
	camera_shake = 17.0

func show_status(text: String, color: Color) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
	var tween: Tween = create_tween()
	status_label.modulate.a = 1.0
	status_label.scale = Vector2.ONE * 1.08
	tween.tween_property(status_label, "scale", Vector2.ONE, 0.18)
	tween.tween_property(status_label, "modulate:a", 0.0, 0.86).set_delay(0.30)

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
		"owned_skins": owned_skins
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
			var loaded_skins: Variant = parsed.get("owned_skins", {"nucleo_errante": true})
			if typeof(loaded_skins) == TYPE_DICTIONARY:
				owned_skins = loaded_skins

func _draw() -> void:
	draw_cultivation_background()
	draw_spiritual_lanes()
	draw_entities()
	draw_particles()
	draw_player_aura()

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
	var p: Vector2 = player.position
	var aura_strength: float = 0.12 + clampf(resonance_value / 100.0, 0.0, 1.0) * 0.16
	draw_circle(p, 92.0 + sin(pulse_time * 3.0) * 5.0, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, aura_strength * 0.26))
	draw_circle(p, 62.0 + sin(pulse_time * 2.2) * 4.0, Color(C_JADE.r, C_JADE.g, C_JADE.b, aura_strength * 0.38))
	draw_arc(p, 77.0, pulse_time * 1.4, pulse_time * 1.4 + PI * 1.35, 48, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.16 + aura_strength * 0.26), 2.0, true)
	draw_arc(p, 54.0, -pulse_time * 1.8, -pulse_time * 1.8 + PI * 1.2, 42, Color(C_CELESTIAL.r, C_CELESTIAL.g, C_CELESTIAL.b, 0.18 + aura_strength * 0.25), 2.0, true)

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
