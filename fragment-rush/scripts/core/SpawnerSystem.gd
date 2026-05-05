extends Node
## SpawnerSystem.gd - Etapa 3A-1
## Ponte segura para timers de spawn.
##
## Controla apenas quando pedir spawn.
## A criação real das entidades continua no Main.gd.

var spawn_timer: float = 0.0
var crystal_spawn_timer: float = 0.0
var power_spawn_timer: float = 6.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func reset() -> void:
	spawn_timer = 0.0
	crystal_spawn_timer = 0.0
	power_spawn_timer = 6.0


func setup_rng(source_rng: RandomNumberGenerator) -> void:
	if source_rng != null:
		rng = source_rng


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
