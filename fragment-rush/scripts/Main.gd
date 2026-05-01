extends Node2D

# Fragment Rush: Corrida dos Cristais
# Base jogável procedural para Godot 4.
# Foco: menu bonito, movimento fluido, coleta, obstáculos, rasante perfeito,
# pontuação, cristais, recorde local, loja simples e sensação cósmica.

const SAVE_PATH: String = "user://fragment_rush_save.json"
const LANES: Array[float] = [-230.0, 0.0, 230.0]
const PLAYER_Y: float = 980.0
const VIEW_W: float = 720.0
const VIEW_H: float = 1280.0

var screen: String = "menu"
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var player: Node2D
var player_glow: Polygon2D
var player_core: Polygon2D
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

var title_label: Label
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
var particles: Array[Dictionary] = []

var player_lane: int = 1
var target_x: float = 0.0
var dash_cooldown: float = 0.0
var dash_timer: float = 0.0
var invulnerable_timer: float = 0.0
var magnet_timer: float = 0.0
var slowmo_timer: float = 0.0

var distance: float = 0.0
var score: int = 0
var crystals_run: int = 0
var perfect_grazes: int = 0
var combo: int = 0
var best_distance: float = 0.0
var total_crystals: int = 0
var selected_skin: String = "orbe_inicial"
var owned_skins: Dictionary = {"orbe_inicial": true}

var spawn_timer: float = 0.0
var crystal_spawn_timer: float = 0.0
var power_spawn_timer: float = 5.0
var speed: float = 390.0
var difficulty: float = 0.0

var touch_start: Vector2 = Vector2.ZERO
var is_touching: bool = false
var run_time: float = 0.0
var camera_shake: float = 0.0

func _ready() -> void:
	rng.randomize()
	load_save()
	create_starfield()
	build_game_nodes()
	build_ui()
	show_menu()

func _process(delta: float) -> void:
	var real_delta: float = delta
	var game_delta: float = delta
	if slowmo_timer > 0.0 and screen == "game":
		game_delta *= 0.56
		slowmo_timer -= real_delta
	update_background(real_delta)
	update_particles(real_delta)
	if screen == "game":
		update_game(game_delta, real_delta)
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
	player.name = "Player"
	player.position = Vector2(target_x, PLAYER_Y)
	add_child(player)

	player_glow = Polygon2D.new()
	player_glow.polygon = PackedVector2Array([Vector2(0, -62), Vector2(54, 0), Vector2(0, 70), Vector2(-54, 0)])
	player_glow.color = Color(0.3, 0.9, 1.0, 0.22)
	player.add_child(player_glow)

	player_core = Polygon2D.new()
	player_core.polygon = PackedVector2Array([Vector2(0, -42), Vector2(35, 0), Vector2(0, 50), Vector2(-35, 0)])
	player_core.color = skin_color(selected_skin)
	player.add_child(player_core)

func build_ui() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	menu_layer = CanvasLayer.new()
	add_child(menu_layer)
	result_layer = CanvasLayer.new()
	add_child(result_layer)
	shop_layer = CanvasLayer.new()
	add_child(shop_layer)

	score_label = make_label("0", 34, Vector2(28, 24), Color.WHITE)
	crystal_label = make_label("Cristais: 0", 24, Vector2(28, 74), Color(0.55, 0.95, 1.0))
	distance_label = make_label("0 m", 24, Vector2(28, 110), Color(0.85, 0.84, 1.0))
	combo_label = make_label("", 28, Vector2(230, 76), Color(1.0, 0.8, 0.25))
	status_label = make_label("", 30, Vector2(0, 220), Color(1.0, 0.9, 0.35))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size = Vector2(VIEW_W, 60)
	var hud_nodes: Array[Control] = [score_label, crystal_label, distance_label, combo_label, status_label]
	for label in hud_nodes:
		hud_layer.add_child(label)

	title_label = make_label("FRAGMENT RUSH\nCorrida dos Cristais", 48, Vector2(0, 240), Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size = Vector2(VIEW_W, 130)
	best_label = make_label("", 25, Vector2(0, 430), Color(0.74, 0.9, 1.0))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.size = Vector2(VIEW_W, 60)
	start_button = make_button("JOGAR", Vector2(190, 560), Vector2(340, 78))
	shop_button = make_button("FORMAS / LOJA", Vector2(190, 660), Vector2(340, 72))
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(show_shop)
	var menu_nodes: Array[Control] = [title_label, best_label, start_button, shop_button]
	for node in menu_nodes:
		menu_layer.add_child(node)

	result_title = make_label("FIM DA CORRIDA", 44, Vector2(0, 250), Color.WHITE)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.size = Vector2(VIEW_W, 70)
	result_stats = make_label("", 26, Vector2(90, 355), Color(0.86, 0.92, 1.0))
	result_stats.size = Vector2(540, 250)
	restart_button = make_button("JOGAR DE NOVO", Vector2(170, 650), Vector2(380, 78))
	menu_button = make_button("MENU", Vector2(210, 750), Vector2(300, 70))
	restart_button.pressed.connect(start_game)
	menu_button.pressed.connect(show_menu)
	var result_nodes: Array[Control] = [result_title, result_stats, restart_button, menu_button]
	for node in result_nodes:
		result_layer.add_child(node)

	shop_info_label = make_label("", 24, Vector2(60, 210), Color.WHITE)
	shop_info_label.size = Vector2(600, 650)
	close_shop_button = make_button("VOLTAR", Vector2(210, 1030), Vector2(300, 70))
	close_shop_button.pressed.connect(show_menu)
	shop_layer.add_child(shop_info_label)
	shop_layer.add_child(close_shop_button)

func make_label(text: String, size_font: int, pos: Vector2, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", size_font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

func make_button(text: String, pos: Vector2, size_btn: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.position = pos
	button.size = size_btn
	button.add_theme_font_size_override("font_size", 24)
	return button

func create_starfield() -> void:
	stars.clear()
	for i in range(95):
		var star: Dictionary = {
			"pos": Vector2(rng.randf_range(0, VIEW_W), rng.randf_range(0, VIEW_H)),
			"speed": rng.randf_range(18, 95),
			"size": rng.randf_range(1.0, 3.5),
			"alpha": rng.randf_range(0.18, 0.8)
		}
		stars.append(star)

func update_background(delta: float) -> void:
	var speed_factor: float = 1.0 if screen == "game" else 0.28
	for i in range(stars.size()):
		var star: Dictionary = stars[i]
		var pos: Vector2 = star["pos"]
		pos.y += float(star["speed"]) * delta * speed_factor
		if pos.y > VIEW_H + 10.0:
			pos = Vector2(rng.randf_range(0, VIEW_W), -10.0)
		star["pos"] = pos
		stars[i] = star

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

func show_menu() -> void:
	screen = "menu"
	menu_layer.visible = true
	result_layer.visible = false
	shop_layer.visible = false
	hud_layer.visible = false
	best_label.text = "Recorde: %d m  •  Cristais: %d" % [int(best_distance), total_crystals]

func show_shop() -> void:
	screen = "shop"
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = true
	hud_layer.visible = false
	var lines: Array[String] = []
	lines.append("FORMAS CRISTALINAS")
	lines.append("")
	lines.append("Cristais disponíveis: %d" % total_crystals)
	lines.append("")
	lines.append("✓ Orbe Inicial — liberado")
	lines.append("• Cometa Violeta — 1000 cristais")
	lines.append("• Núcleo Solar — 3000 cristais")
	lines.append("• Sombra Nebular — fragmento raro")
	lines.append("")
	lines.append("Nesta base, a loja já está estruturada.")
	lines.append("Na próxima etapa vamos colocar compra, seleção visual, skins animadas e baús.")
	lines.append("")
	lines.append("Direção do jogo:")
	lines.append("Quanto mais perto do perigo, maior a recompensa.")
	shop_info_label.text = "\n".join(lines)

func update_game(delta: float, real_delta: float) -> void:
	run_time += real_delta
	difficulty += real_delta * 0.018
	speed = minf(820.0, 390.0 + distance * 0.03 + difficulty * 42.0)
	distance += speed * delta * 0.045
	score += int(14.0 * delta * (1.0 + float(combo) * 0.08))
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
	var dash_scale: float = 0.11 if dash_timer > 0.0 else 0.0
	player.scale = Vector2.ONE * (1.0 + sin(run_time * 9.0) * 0.025 + dash_scale)
	if dash_timer > 0.0:
		spawn_particle(player.position, Color(0.45, 0.95, 1.0, 0.85), 9, 0.42)

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
	distance_label.text = "%d m" % int(distance)
	combo_label.text = "COMBO x%d" % combo if combo > 1 else ""

func move_lane(dir: int) -> void:
	player_lane = clampi(player_lane + dir, 0, LANES.size() - 1)
	target_x = screen_lane_x(player_lane)
	camera_shake = maxf(camera_shake, 2.0)

func do_dash() -> void:
	if dash_cooldown <= 0.0:
		dash_timer = 0.18
		dash_cooldown = 1.15
		invulnerable_timer = maxf(invulnerable_timer, 0.2)
		show_status("DASH ASTRAL", Color(0.55, 0.95, 1.0))
		for i in range(12):
			var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-38, 38), rng.randf_range(-38, 38))
			spawn_particle(particle_pos, Color(0.3, 0.9, 1.0, 0.8), 7, 0.55)

func spawn_obstacle_pattern() -> void:
	var pattern: int = rng.randi_range(0, 4)
	if pattern == 0:
		spawn_obstacle(rng.randi_range(0, 2), "meteor")
	elif pattern == 1:
		var safe: int = rng.randi_range(0, 2)
		for lane in range(3):
			if lane != safe:
				spawn_obstacle(lane, "crystal_spike")
	elif pattern == 2:
		spawn_obstacle(0, "barrier")
		spawn_obstacle(2, "barrier")
	elif pattern == 3:
		spawn_obstacle(rng.randi_range(0, 2), "rift")
	else:
		spawn_obstacle(rng.randi_range(0, 2), "meteor")
		spawn_obstacle(rng.randi_range(0, 2), "crystal_spike")

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
			"kind": "common",
			"lane": lane,
			"pos": Vector2(screen_lane_x(lane), -80.0 - float(i) * 72.0),
			"radius": 28.0,
			"value": 1
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
		"radius": 34.0
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

		if entity_type == "obstacle":
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
	var pos: Vector2 = e["pos"]
	spawn_particle(pos, Color(0.55, 0.95, 1.0, 0.85), 10, 0.5)
	if combo % 10 == 0:
		show_status("COMBO x%d" % combo, Color(1.0, 0.8, 0.24))

func collect_power(kind: String) -> void:
	match kind:
		"magnet":
			magnet_timer = 6.0
			show_status("ÍMÃ CRISTALINO", Color(0.55, 0.95, 1.0))
		"shield":
			invulnerable_timer = 5.0
			show_status("ESCUDO CÓSMICO", Color(0.6, 0.75, 1.0))
		"slowmo":
			slowmo_timer = 3.0
			show_status("TEMPO FRATURADO", Color(0.9, 0.75, 1.0))
		"double":
			combo += 5
			show_status("MULTIPLICADOR", Color(1.0, 0.8, 0.2))
	spawn_particle(player.position, Color(1, 1, 1, 0.75), 18, 0.7)

func perfect_graze() -> void:
	perfect_grazes += 1
	combo += 2
	var bonus: int = 90 + combo * 5
	score += bonus
	camera_shake = 9.0
	show_status("RASANTE PERFEITO +%d" % bonus, Color(1.0, 0.84, 0.24))
	for i in range(16):
		var particle_pos: Vector2 = player.position + Vector2(rng.randf_range(-42, 42), rng.randf_range(-42, 42))
		spawn_particle(particle_pos, Color(1.0, 0.78, 0.18, 0.85), 8, 0.45)

func game_over() -> void:
	screen = "result"
	total_crystals += crystals_run
	best_distance = maxf(best_distance, distance)
	save_game()
	hud_layer.visible = false
	result_layer.visible = true
	menu_layer.visible = false
	shop_layer.visible = false
	result_stats.text = "Distância: %d m\nPontuação: %d\nCristais coletados: %d\nRasantes perfeitos: %d\nMaior combo: x%d\n\nTotal de cristais: %d\nRecorde: %d m" % [int(distance), score, crystals_run, perfect_grazes, combo, total_crystals, int(best_distance)]
	camera_shake = 18.0

func show_status(text: String, color: Color) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
	var tween: Tween = create_tween()
	status_label.modulate.a = 1.0
	tween.tween_property(status_label, "modulate:a", 0.0, 0.82).set_delay(0.28)

func spawn_particle(pos: Vector2, color: Color, amount: int, lifetime: float) -> void:
	for i in range(amount):
		var particle: Dictionary = {
			"pos": pos,
			"vel": Vector2(rng.randf_range(-160, 160), rng.randf_range(-220, 80)),
			"color": color,
			"life": lifetime,
			"max": lifetime,
			"size": rng.randf_range(3, 9)
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
	for i in remove:
		particles.remove_at(i)

func skin_color(skin: String) -> Color:
	match skin:
		"cometa_violeta":
			return Color(0.75, 0.35, 1.0, 1.0)
		"nucleo_solar":
			return Color(1.0, 0.7, 0.18, 1.0)
		"sombra_nebular":
			return Color(0.24, 0.13, 0.42, 1.0)
		_:
			return Color(0.55, 0.95, 1.0, 1.0)

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
			selected_skin = str(parsed.get("selected_skin", "orbe_inicial"))
			var loaded_skins: Variant = parsed.get("owned_skins", {"orbe_inicial": true})
			if typeof(loaded_skins) == TYPE_DICTIONARY:
				owned_skins = loaded_skins

func _draw() -> void:
	# Fundo cósmico em camadas.
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEW_W, VIEW_H)), Color(0.025, 0.01, 0.07, 1.0))
	for y in range(0, int(VIEW_H), 64):
		var alpha_layer: float = 0.06 + 0.03 * sin((float(y) + run_time * 40.0) * 0.01)
		draw_rect(Rect2(0, y, VIEW_W, 64), Color(0.08, 0.02, 0.18, alpha_layer))
	for s in stars:
		var star_pos: Vector2 = s["pos"]
		var star_size: float = float(s["size"])
		var star_alpha: float = float(s["alpha"])
		draw_circle(star_pos, star_size, Color(0.65, 0.9, 1.0, star_alpha))
	# Trilhas/faixas de energia.
	for lane_offset in LANES:
		var x: float = VIEW_W * 0.5 + lane_offset
		draw_line(Vector2(x, 0), Vector2(x, VIEW_H), Color(0.25, 0.75, 1.0, 0.08), 4.0)
	# Entidades.
	for e in entities:
		var entity_type: String = str(e.get("type", ""))
		var p: Vector2 = e["pos"]
		if entity_type == "crystal":
			draw_crystal(p, 22.0, Color(0.52, 0.95, 1.0, 0.92))
		elif entity_type == "power":
			draw_circle(p, 34.0, Color(0.9, 0.55, 1.0, 0.22))
			draw_circle(p, 20.0, Color(1.0, 0.85, 0.35, 0.9))
		else:
			var col: Color = Color(1.0, 0.16, 0.28, 0.88)
			var kind: String = str(e.get("kind", ""))
			if kind == "crystal_spike":
				col = Color(0.8, 0.18, 1.0, 0.9)
			if kind == "barrier":
				col = Color(1.0, 0.55, 0.12, 0.88)
			if kind == "rift":
				col = Color(0.2, 0.05, 0.35, 0.95)
			var rot: float = float(e.get("rot", 0.0))
			draw_obstacle(p, 48.0, col, rot)
	for part in particles:
		var part_life: float = float(part["life"])
		var part_max: float = maxf(0.001, float(part["max"]))
		var alpha: float = maxf(0.0, part_life / part_max)
		var c: Color = part["color"]
		var part_pos: Vector2 = part["pos"]
		var part_size: float = float(part["size"])
		c.a *= alpha
		draw_circle(part_pos, part_size * alpha, c)

func draw_crystal(p: Vector2, r: float, color: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		Vector2(p.x, p.y - r * 1.4),
		Vector2(p.x + r, p.y),
		Vector2(p.x, p.y + r * 1.4),
		Vector2(p.x - r, p.y)
	])
	draw_colored_polygon(pts, color)
	var line_pts: PackedVector2Array = PackedVector2Array(pts)
	line_pts.append(pts[0])
	draw_polyline(line_pts, Color.WHITE, 2.0)

func draw_obstacle(p: Vector2, r: float, color: Color, rot: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var count: int = 8
	for i in range(count):
		var rr: float = r if i % 2 == 0 else r * 0.55
		var a: float = rot + TAU * float(i) / float(count)
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(pts, color)
	var line_pts: PackedVector2Array = PackedVector2Array(pts)
	line_pts.append(pts[0])
	draw_polyline(line_pts, Color(1, 1, 1, 0.45), 2.0)
