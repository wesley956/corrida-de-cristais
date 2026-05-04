extends Node
## EventBus.gd - Central de sinais globais do Fragment Rush.
## Nesta etapa, ele apenas declara eventos.
## As conexões serão feitas nas próximas refatorações.

# ── Game flow ─────────────────────────────────────────────────────────────────
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal run_finished(stats: Dictionary)

# ── Player ────────────────────────────────────────────────────────────────────
signal player_lane_changed(lane: int)
signal player_dash_used
signal player_hit
signal player_revived

# ── Score / progress ──────────────────────────────────────────────────────────
signal distance_updated(distance: float)
signal score_updated(score: int)
signal combo_changed(combo: int)
signal perfect_graze
signal resonance_changed(value: float)

# ── Collectibles ──────────────────────────────────────────────────────────────
signal crystal_collected(value: int, crystal_type: String)
signal rare_crystal_collected(crystal_type: String)
signal power_up_collected(power_up_type: String)

# ── Missions / rewards ────────────────────────────────────────────────────────
signal mission_progress_updated(mission_id: String, progress: int)
signal mission_completed(mission_id: String, reward: int)
signal reward_granted(reason: String, amount: int)

# ── Shop / skins ───────────────────────────────────────────────────────────────
signal skin_selected(skin_id: String)
signal skin_purchased(skin_id: String)
signal technique_upgraded(technique_id: String, new_level: int)

# ── UI feedback ────────────────────────────────────────────────────────────────
signal status_message_requested(message: String)
signal screen_changed(screen_name: String)


func emit_game_started() -> void:
	game_started.emit()


func emit_game_paused() -> void:
	game_paused.emit()


func emit_game_resumed() -> void:
	game_resumed.emit()


func emit_game_over() -> void:
	game_over.emit()


func emit_run_finished(stats: Dictionary) -> void:
	run_finished.emit(stats)


func emit_player_lane_changed(lane: int) -> void:
	player_lane_changed.emit(lane)


func emit_player_dash_used() -> void:
	player_dash_used.emit()


func emit_player_hit() -> void:
	player_hit.emit()


func emit_player_revived() -> void:
	player_revived.emit()


func emit_distance_updated(distance: float) -> void:
	distance_updated.emit(distance)


func emit_score_updated(score: int) -> void:
	score_updated.emit(score)


func emit_combo_changed(combo: int) -> void:
	combo_changed.emit(combo)


func emit_perfect_graze() -> void:
	perfect_graze.emit()


func emit_resonance_changed(value: float) -> void:
	resonance_changed.emit(value)


func emit_crystal_collected(value: int, crystal_type: String) -> void:
	crystal_collected.emit(value, crystal_type)


func emit_rare_crystal_collected(crystal_type: String) -> void:
	rare_crystal_collected.emit(crystal_type)


func emit_power_up_collected(power_up_type: String) -> void:
	power_up_collected.emit(power_up_type)


func emit_mission_progress_updated(mission_id: String, progress: int) -> void:
	mission_progress_updated.emit(mission_id, progress)


func emit_mission_completed(mission_id: String, reward: int) -> void:
	mission_completed.emit(mission_id, reward)


func emit_reward_granted(reason: String, amount: int) -> void:
	reward_granted.emit(reason, amount)


func emit_skin_selected(skin_id: String) -> void:
	skin_selected.emit(skin_id)


func emit_skin_purchased(skin_id: String) -> void:
	skin_purchased.emit(skin_id)


func emit_technique_upgraded(technique_id: String, new_level: int) -> void:
	technique_upgraded.emit(technique_id, new_level)


func emit_status_message_requested(message: String) -> void:
	status_message_requested.emit(message)


func emit_screen_changed(screen_name: String) -> void:
	screen_changed.emit(screen_name)
