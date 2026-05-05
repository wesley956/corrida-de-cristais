extends RefCounted
## RunStateSystem.gd
## Centraliza os valores padrão de uma nova corrida.
##
## Nesta etapa:
## - Main.gd ainda aplica os valores.
## - Este arquivo apenas fornece o Dictionary de estado inicial.
## - Nenhuma UI, VFX, colisão ou entidade é controlada aqui.

static func build_default_run_state(rng: RandomNumberGenerator) -> Dictionary:
	return {
		"score": 0,
		"crystals_run": 0,
		"rare_crystals_run": 0,
		"dashes_used_run": 0,
		"combo": 0,
		"max_combo_run": 0,

		"distance": 0.0,
		"scrolled_distance": 0.0,
		"run_time": 0.0,
		"speed": 380.0,
		"difficulty": 0.0,

		"player_lane": 1,
		"player_lean": 0.0,
		"player_lean_target": 0.0,
		"player_run_phase": 0.0,
		"player_hit_flash": 0.0,

		"dash_cooldown": 0.0,
		"dash_timer": 0.0,
		"invulnerable_timer": 0.0,
		"magnet_timer": 0.0,
		"slowmo_timer": 0.0,
		"resonance_value": 0.0,
		"flow_timer": 0.0,
		"flow_activations": 0,

		"current_biome_index": 0,
		"spawn_timer": 0.0,
		"crystal_spawn_timer": 0.0,
		"power_spawn_timer": 6.0,
		"crystal_rain_timer": rng.randf_range(14.0, 22.0),
		"crystal_rain_active": 0.0,

		"flash_alpha": 0.0,
		"camera_shake": 0.0,
		"completed_run_missions": [],
		"run_mission_bonus": 0,
		"circles_unlocked_run": 0,
		"result_reveal_timer": 0.0,
		"result_badge_pulse": 0.0
	}
