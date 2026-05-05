extends Node
## VfxSystem.gd
## Ponte segura para centralizar criação e atualização de efeitos visuais.
##
## Nesta etapa:
## - Controla particles, shockwaves, afterimages, skin_trails e vfx_png_sprites.
## - Main.gd ainda desenha tudo.
## - Main.gd ainda controla texturas PNG, draw_* e gameplay.

var particles_ref: Array = []
var shockwaves_ref: Array = []
var afterimages_ref: Array = []
var skin_trails_ref: Array = []
var vfx_png_sprites_ref: Array = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var has_bound_arrays: bool = false


func setup_rng(source_rng: RandomNumberGenerator) -> void:
	if source_rng != null:
		rng = source_rng


func bind_effect_arrays(
	particles: Array,
	shockwaves: Array,
	afterimages: Array,
	skin_trails: Array,
	vfx_png_sprites: Array
) -> void:
	particles_ref = particles
	shockwaves_ref = shockwaves
	afterimages_ref = afterimages
	skin_trails_ref = skin_trails
	vfx_png_sprites_ref = vfx_png_sprites
	has_bound_arrays = true


func clear_all() -> void:
	if not has_bound_arrays:
		return

	particles_ref.clear()
	shockwaves_ref.clear()
	afterimages_ref.clear()
	skin_trails_ref.clear()
	vfx_png_sprites_ref.clear()


# ── Spawn helpers ─────────────────────────────────────────────────────────────
func spawn_particle(pos: Vector2, color: Color, size: int, duration: float) -> void:
	if not has_bound_arrays:
		return

	particles_ref.append({
		"x": pos.x,
		"y": pos.y,
		"vx": rng.randf_range(-80.0, 80.0),
		"vy": rng.randf_range(-120.0, -20.0),
		"color": color,
		"size": size,
		"age": 0.0,
		"duration": duration
	})


func spawn_shockwave(pos: Vector2, color: Color, start_radius: float, end_radius: float, duration: float) -> void:
	if not has_bound_arrays:
		return

	shockwaves_ref.append({
		"pos": pos,
		"color": color,
		"start": start_radius,
		"end": end_radius,
		"duration": duration,
		"age": 0.0
	})


func spawn_afterimage(
	pos: Vector2,
	color: Color,
	duration: float,
	player_lean: float,
	player_state: String
) -> void:
	if not has_bound_arrays:
		return

	afterimages_ref.append({
		"pos": pos,
		"color": color,
		"duration": duration,
		"age": 0.0,
		"lean": player_lean,
		"state": player_state
	})


func spawn_vfx_png(
	pos: Vector2,
	kind: String,
	color: Color,
	size_px: float,
	duration: float,
	rotation: float = 0.0
) -> void:
	if not has_bound_arrays:
		return

	vfx_png_sprites_ref.append({
		"pos": pos,
		"kind": kind,
		"color": color,
		"size": size_px,
		"duration": duration,
		"age": 0.0,
		"rotation": rotation
	})

	if vfx_png_sprites_ref.size() > 64:
		vfx_png_sprites_ref.remove_at(0)


# ── Update helpers ────────────────────────────────────────────────────────────
func update_effects(delta: float) -> void:
	if not has_bound_arrays:
		return

	_update_vfx_png(delta)
	_update_shockwaves(delta)
	_update_afterimages(delta)
	_update_particles(delta)
	_update_skin_trails(delta)


func _update_vfx_png(delta: float) -> void:
	var remove_vfx: Array[int] = []

	for i in range(vfx_png_sprites_ref.size()):
		var sprite: Dictionary = vfx_png_sprites_ref[i]
		sprite["age"] = float(sprite.get("age", 0.0)) + delta
		vfx_png_sprites_ref[i] = sprite

		if float(sprite["age"]) >= float(sprite["duration"]):
			remove_vfx.append(i)

	_remove_by_indices(vfx_png_sprites_ref, remove_vfx)


func _update_shockwaves(delta: float) -> void:
	var remove_sw: Array[int] = []

	for i in range(shockwaves_ref.size()):
		var sw: Dictionary = shockwaves_ref[i]
		sw["age"] = float(sw["age"]) + delta
		shockwaves_ref[i] = sw

		if float(sw["age"]) >= float(sw["duration"]):
			remove_sw.append(i)

	_remove_by_indices(shockwaves_ref, remove_sw)


func _update_afterimages(delta: float) -> void:
	var remove_ai: Array[int] = []

	for i in range(afterimages_ref.size()):
		var ai: Dictionary = afterimages_ref[i]
		ai["age"] = float(ai["age"]) + delta
		afterimages_ref[i] = ai

		if float(ai["age"]) >= float(ai["duration"]):
			remove_ai.append(i)

	_remove_by_indices(afterimages_ref, remove_ai)


func _update_particles(delta: float) -> void:
	var remove_p: Array[int] = []

	for i in range(particles_ref.size()):
		var p: Dictionary = particles_ref[i]
		p["age"] = float(p["age"]) + delta
		p["x"] = float(p["x"]) + float(p["vx"]) * delta
		p["y"] = float(p["y"]) + float(p["vy"]) * delta
		p["vy"] = float(p["vy"]) + 120.0 * delta
		particles_ref[i] = p

		if float(p["age"]) >= float(p["duration"]):
			remove_p.append(i)

	_remove_by_indices(particles_ref, remove_p)


func _update_skin_trails(delta: float) -> void:
	var remove_st: Array[int] = []

	for i in range(skin_trails_ref.size()):
		var st: Dictionary = skin_trails_ref[i]
		st["age"] = float(st["age"]) + delta
		skin_trails_ref[i] = st

		if float(st["age"]) >= float(st["duration"]):
			remove_st.append(i)

	_remove_by_indices(skin_trails_ref, remove_st)


func _remove_by_indices(target_array: Array, indices: Array[int]) -> void:
	var sorted_indices: Array[int] = indices.duplicate()
	sorted_indices.reverse()

	for idx in sorted_indices:
		if idx >= 0 and idx < target_array.size():
			target_array.remove_at(idx)
