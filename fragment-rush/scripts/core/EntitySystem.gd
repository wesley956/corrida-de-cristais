extends Node
## EntitySystem.gd
## Ponte segura para centralizar acesso à lista de entidades.
##
## Nesta etapa, ele NÃO controla colisão, desenho, movimento ou coleta.
## Ele apenas recebe a referência do Array entities do Main.gd e opera sobre ela.

var entities_ref: Array = []
var has_bound_entities: bool = false


func bind_entities(source_entities: Array) -> void:
	entities_ref = source_entities
	has_bound_entities = true


func add_entity(entity: Dictionary) -> void:
	if not has_bound_entities:
		return

	entities_ref.append(entity)


func clear_entities() -> void:
	if not has_bound_entities:
		return

	entities_ref.clear()


func get_entities() -> Array:
	return entities_ref


func count() -> int:
	if not has_bound_entities:
		return 0

	return entities_ref.size()

# ── Entity motion bridge ──────────────────────────────────────────────────────
func update_entity_motion(entity: Dictionary, delta: float, speed: float) -> Dictionary:
	var updated: Dictionary = entity.duplicate(true)
	updated["y"] = float(updated["y"]) + speed * delta
	updated["age"] = float(updated.get("age", 0.0)) + delta

	return updated


func is_entity_out_of_bounds(entity: Dictionary, view_height: float) -> bool:
	return float(entity["y"]) > view_height + 120.0

# ── Entity magnet bridge ──────────────────────────────────────────────────────
func apply_crystal_magnet(
	entity: Dictionary,
	delta: float,
	player_position: Vector2,
	magnet_timer: float,
	jade_level: int
) -> Dictionary:
	var updated: Dictionary = entity.duplicate(true)

	if str(updated.get("type", "")) != "crystal":
		return updated

	if magnet_timer <= 0.0:
		return updated

	var diff: Vector2 = player_position - Vector2(float(updated["x"]), float(updated["y"]))
	var magnet_range: float = 160.0 + float(jade_level) * 28.0

	if diff.length() < magnet_range:
		updated["x"] = float(updated["x"]) + diff.x * delta * 5.5
		updated["y"] = float(updated["y"]) + diff.y * delta * 5.5

	return updated

# ── Entity collision metrics bridge ───────────────────────────────────────────
func get_collision_delta(entity: Dictionary, player_position: Vector2) -> Vector2:
	return Vector2(
		absf(player_position.x - float(entity["x"])),
		absf(player_position.y - float(entity["y"]))
	)


func is_crystal_colliding(entity: Dictionary, player_position: Vector2) -> bool:
	var delta: Vector2 = get_collision_delta(entity, player_position)
	var radius: float = float(entity.get("size", 18.0)) + 12.0

	return delta.x < radius and delta.y < radius


func is_obstacle_colliding(entity: Dictionary, player_position: Vector2) -> bool:
	var delta: Vector2 = get_collision_delta(entity, player_position)
	var half_width: float = float(entity.get("hw", 26.0)) - 8.0
	var half_height: float = float(entity.get("hh", 30.0)) - 8.0

	return delta.x < half_width and delta.y < half_height


func is_powerup_colliding(entity: Dictionary, player_position: Vector2) -> bool:
	var delta: Vector2 = get_collision_delta(entity, player_position)
	var radius: float = 30.0

	return delta.x < radius and delta.y < radius

# ── Entity removal bridge ─────────────────────────────────────────────────────
func remove_entities_by_indices(indices: Array[int]) -> void:
	if not has_bound_entities:
		return

	var sorted_indices: Array[int] = indices.duplicate()
	sorted_indices.reverse()

	for idx in sorted_indices:
		if idx >= 0 and idx < entities_ref.size():
			entities_ref.remove_at(idx)
