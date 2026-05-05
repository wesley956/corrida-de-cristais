class_name PlayerController
extends Node
## PlayerController.gd - Etapa 2A-1
## Ponte segura para movimento entre faixas.

signal lane_changed(lane: int, target_x: float, direction: int)

var player_lane: int = 1
var target_x: float = 0.0
var player_state: String = "running"


func setup(initial_lane: int = 1) -> void:
	player_lane = clampi(initial_lane, 0, GameConfig.LANES.size() - 1)
	target_x = screen_lane_x(player_lane)


static func screen_lane_x(lane: int) -> float:
	return GameConfig.VIEW_W * 0.5 + GameConfig.LANES[clampi(lane, 0, GameConfig.LANES.size() - 1)]


func reset_to_center() -> void:
	setup(1)
	lane_changed.emit(player_lane, target_x, 0)
	EventBus.emit_player_lane_changed(player_lane)



func can_move(_player_state: String = "") -> bool:
	return player_state in ["running", "moving_left", "moving_right"]

func move_lane(direction: int, _player_state: String = "") -> bool:
	if direction == 0:
		return false

	if not can_move():
		return false

	var new_lane: int = clampi(player_lane + direction, 0, GameConfig.LANES.size() - 1)

	if new_lane == player_lane:
		return false

	player_lane = new_lane
	target_x = screen_lane_x(player_lane)

	lane_changed.emit(player_lane, target_x, direction)
	EventBus.emit_player_lane_changed(player_lane)

	return true
func set_state(new_state: String) -> bool:
	var valid_states: Array[String] = ["running", "moving_left", "moving_right", "dash", "hit"]

	if new_state not in valid_states:
		printerr("PlayerController: estado inválido: ", new_state)
		return false

	if player_state == new_state:
		return true

	var old_state: String = player_state
	player_state = new_state

	if new_state == "hit":
		dash_timer = 0.0

	EventBus.emit_player_state_changed(old_state, new_state)
	return true


func get_state() -> String:
	return player_state


func is_state(states: Array) -> bool:
	return player_state in states

# ── Dash bridge ────────────────────────────────────────────────────────────────
var dash_cooldown: float = 0.0
var dash_timer: float = 0.0



func request_dash(dash_level: int, _player_state: String = "") -> bool:
	if dash_cooldown > 0.0:
		return false

	if dash_timer > 0.0:
		return false

	if not can_move():
		return false

	var max_cd: float = maxf(1.4, 2.8 - float(dash_level) * 0.28)
	dash_cooldown = max_cd
	dash_timer = 0.28
	set_state("dash")

	return true
func update_dash_timers(delta: float) -> void:
	if dash_timer > 0.0:
		dash_timer = maxf(0.0, dash_timer - delta)

	if dash_cooldown > 0.0:
		dash_cooldown = maxf(0.0, dash_cooldown - delta)


func reset_dash() -> void:
	dash_cooldown = 0.0
	dash_timer = 0.0
