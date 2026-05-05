extends Node
## SpawnerSystem.gd
## Ponte segura para decisões de spawn do Fragment Rush.
##
## Responsabilidades atuais:
## - Controlar timers de spawn.
## - Escolher padrões de obstáculos.
## - Escolher padrões de cristais.
## - Escolher tipos de power-up.
## - Escolher tipos de obstáculo.
##
## A criação real das entidades ainda continua no Main.gd.

# ── Timers ────────────────────────────────────────────────────────────────────
var spawn_timer: float = 0.0
var crystal_spawn_timer: float = 0.0
var power_spawn_timer: float = 6.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


# ── Setup / lifecycle ─────────────────────────────────────────────────────────
func setup_rng(source_rng: RandomNumberGenerator) -> void:
	if source_rng != null:
		rng = source_rng


func reset() -> void:
	spawn_timer = 0.0
	crystal_spawn_timer = 0.0
	power_spawn_timer = 6.0


# ── Timer bridge ──────────────────────────────────────────────────────────────
func update_spawners(delta: float, difficulty: float, crystal_rain_active: float) -> Dictionary:
	var requests: Dictionary = {
		"obstacle": false,
		"crystal": false,
		"powerup": false
	}

	spawn_timer -= delta
	crystal_spawn_timer -= delta
	power_spawn_timer -= delta

	var spawn_interval: float = maxf(0.72, 1.60 - difficulty * 0.10)
	if crystal_rain_active > 0.0:
		spawn_interval *= 0.45

	if spawn_timer <= 0.0:
		spawn_timer = spawn_interval
		requests["obstacle"] = true

	var crystal_interval: float = maxf(0.30, 0.72 - difficulty * 0.035)
	if crystal_spawn_timer <= 0.0:
		crystal_spawn_timer = crystal_interval
		requests["crystal"] = true

	if power_spawn_timer <= 0.0:
		power_spawn_timer = rng.randf_range(8.0, 16.0)
		requests["powerup"] = true

	return requests


func get_timer_state() -> Dictionary:
	return {
		"spawn_timer": spawn_timer,
		"crystal_spawn_timer": crystal_spawn_timer,
		"power_spawn_timer": power_spawn_timer
	}


# ── Obstacle pattern bridge ───────────────────────────────────────────────────
func pick_obstacle_pattern(difficulty: float) -> String:
	var pattern_weights: Array[float] = [40.0, 25.0, 18.0, 12.0, 5.0]

	if difficulty < 1.0:
		pattern_weights = [70.0, 20.0, 10.0, 0.0, 0.0]
	elif difficulty < 2.5:
		pattern_weights = [50.0, 28.0, 15.0, 7.0, 0.0]

	var patterns: Array[String] = ["single", "wall_gap", "alternate", "narrow", "barrage"]
	return _weighted_choice(patterns, pattern_weights)


# ── Crystal pattern bridge ────────────────────────────────────────────────────
func pick_crystal_pattern() -> int:
	return rng.randi_range(0, 3)


# ── PowerUp type bridge ───────────────────────────────────────────────────────
func pick_powerup_type() -> String:
	var ptypes: Array[String] = ["magnet", "shield", "slowmo", "dash_boost"]
	var weights: Array[float] = [45.0, 30.0, 15.0, 10.0]

	return _weighted_choice(ptypes, weights)


# ── Obstacle type bridge ──────────────────────────────────────────────────────
func pick_obstacle_type(current_biome_index: int) -> String:
	var obs_types: Array[String] = ["bamboo_wall", "stone_pillar", "energy_barrier", "spirit_trap"]
	var obs_weights: Array[float] = [40.0, 30.0, 20.0, 10.0]

	if current_biome_index >= 3:
		obs_types = ["stone_pillar", "energy_barrier", "spirit_trap", "spinning_blade"]
		obs_weights = [28.0, 32.0, 22.0, 18.0]

	return _weighted_choice(obs_types, obs_weights)


# ── Helpers ───────────────────────────────────────────────────────────────────
func _weighted_choice(options: Array, weights: Array) -> String:
	var total: float = 0.0

	for w in weights:
		total += float(w)

	if total <= 0.0:
		return str(options[0])

	var roll: float = rng.randf() * total
	var acc: float = 0.0

	for i in range(options.size()):
		acc += float(weights[i])
		if roll <= acc:
			return str(options[i])

	return str(options[0])
