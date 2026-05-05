extends Node
## EntitySystem.gd
## Ponte segura para centralizar operações básicas de entidades.
##
## Responsabilidades atuais:
## - Manter referência ao Array entities do Main.gd.
## - Adicionar, limpar e remover entidades.
## - Atualizar movimento básico e idade.
## - Aplicar magnetismo em cristais.
## - Calcular métricas simples de colisão.
## - Calcular helpers puros de coleta de cristal.
## - Calcular helpers puros de efeito de power-up.
##
## Ainda NÃO controla:
## - Coleta final.
## - Dano final.
## - Aplicação real de power-ups.
## - Desenho.
## - Recompensas.
## - Missões.
## - VFX.

# ── Bound entities ────────────────────────────────────────────────────────────
var entities_ref: Array = []
var has_bound_entities: bool = false


func bind_entities(source_entities: Array) -> void:
	entities_ref = source_entities
	has_bound_entities = true


func get_entities() -> Array:
	return entities_ref


func count() -> int:
	if not has_bound_entities:
		return 0

	return entities_ref.size()


# ── Basic operations ──────────────────────────────────────────────────────────
func add_entity(entity: Dictionary) -> void:
	if not has_bound_entities:
		return

	entities_ref.append(entity)


func clear_entities() -> void:
	if not has_bound_entities:
		return

	entities_ref.clear()


func remove_entities_by_indices(indices: Array[int]) -> void:
	if not has_bound_entities:
		return

	var sorted_indices: Array[int] = indices.duplicate()
	sorted_indices.reverse()

	for idx in sorted_indices:
		if idx >= 0 and idx < entities_ref.size():
			entities_ref.remove_at(idx)


# ── Motion ────────────────────────────────────────────────────────────────────
func update_entity_motion(entity: Dictionary, delta: float, speed: float) -> Dictionary:
	var updated: Dictionary = entity.duplicate(true)
	updated["y"] = float(updated["y"]) + speed * delta
	updated["age"] = float(updated.get("age", 0.0)) + delta

	return updated


func is_entity_out_of_bounds(entity: Dictionary, view_height: float) -> bool:
	return float(entity["y"]) > view_height + 120.0


# ── Magnet ────────────────────────────────────────────────────────────────────
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


# ── Collision metrics ─────────────────────────────────────────────────────────
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


# ── Crystal collection helpers ────────────────────────────────────────────────
func calculate_crystal_value(base_value: int, flow_active: bool, combo: int) -> int:
	var value: int = base_value

	if flow_active:
		value = int(ceil(float(value) * 1.5))

	if combo > 0:
		value = int(ceil(float(value) * (1.0 + float(combo) * 0.05)))

	return value


func calculate_resonance_gain(combo: int) -> float:
	return 8.0 + float(combo) * 0.6


func should_spawn_combo_vfx(combo: int) -> bool:
	return combo >= 5 and combo % 5 == 0


func is_rare_crystal(entity: Dictionary) -> bool:
	return str(entity.get("crystal_type", "common")) != "common"


# ── PowerUp effect helpers ────────────────────────────────────────────────────
func get_powerup_type(entity: Dictionary) -> String:
	return str(entity.get("ptype", "magnet"))


func get_magnet_duration(jade_level: int) -> float:
	return 5.0 + float(jade_level) * 0.6


func get_shield_duration() -> float:
	return 4.5


func get_slowmo_duration() -> float:
	return 3.0


func should_reset_dash_cooldown(powerup_type: String) -> bool:
	return powerup_type == "dash_boost"


func build_powerup_effect_state(
	powerup_type: String,
	current_magnet_timer: float,
	current_invulnerable_timer: float,
	current_slowmo_timer: float,
	current_dash_cooldown: float,
	jade_level: int
) -> Dictionary:
	var state: Dictionary = {
		"ptype": powerup_type,
		"magnet_timer": current_magnet_timer,
		"invulnerable_timer": current_invulnerable_timer,
		"slowmo_timer": current_slowmo_timer,
		"dash_cooldown": current_dash_cooldown,
		"reset_dash_cooldown": false
	}

	match powerup_type:
		"magnet":
			state["magnet_timer"] = get_magnet_duration(jade_level)

		"shield":
			state["invulnerable_timer"] = maxf(current_invulnerable_timer, get_shield_duration())

		"slowmo":
			state["slowmo_timer"] = maxf(current_slowmo_timer, get_slowmo_duration())

		"dash_boost":
			if should_reset_dash_cooldown(powerup_type):
				state["dash_cooldown"] = 0.0
				state["reset_dash_cooldown"] = true

	return state
