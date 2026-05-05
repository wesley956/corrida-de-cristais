extends Node
## ResultSystem.gd
## Centraliza montagem de dados/textos da tela de resultado.
##
## Nesta etapa:
## - Calcula textos, labels, barras e contagens animadas do resultado.
## - Main.gd ainda aplica os dados nos Nodes.
## - Main.gd ainda controla save, XP real, missões e layers.

func build_result_state(
	new_record: bool,
	distance: float,
	score: int,
	crystals_run: int,
	run_mission_bonus: int,
	max_combo_run: int,
	rare_crystals_run: int,
	dashes_used_run: int,
	run_time: float,
	best_distance: float,
	completed_run_missions: Array,
	xp_gain: int,
	cultivation_xp: int,
	next_unlock_hint: String,
	stage_progress_percent: float,
	total_crystals: int,
	cheapest_skin_price: int
) -> Dictionary:
	var dist_m: int = int(distance)
	var total_run_crystals: int = crystals_run + run_mission_bonus
	var title_text: String = "NOVO RECORDE!" if new_record else "CAMINHO INTERROMPIDO"

	var stats_lines: Array[String] = []
	stats_lines.append("Distância:       %d m" % dist_m)
	stats_lines.append("Pontuação:       %d" % score)
	stats_lines.append("Cristais:        %d  (+%d missões)" % [crystals_run, run_mission_bonus])
	stats_lines.append("Combo máximo:    x%d" % max_combo_run)
	stats_lines.append("Cristais raros:  %d" % rare_crystals_run)
	stats_lines.append("Dashes usados:   %d" % dashes_used_run)
	stats_lines.append("Tempo:           %.1f s" % run_time)
	stats_lines.append("Recorde:         %d m" % int(best_distance))

	if completed_run_missions.size() > 0:
		stats_lines.append("")
		stats_lines.append("Missões concluídas:")
		for mission_text in completed_run_missions:
			stats_lines.append("  ✦ %s" % str(mission_text))

	return {
		"title_text": title_text,
		"summary_text": "%d m — Cristais %d — Combo x%d" % [dist_m, crystals_run, max_combo_run],
		"stats_text": "\n".join(stats_lines),
		"xp_label_text": "XP de Cultivo: +%d  (Total %d)" % [xp_gain, cultivation_xp],
		"form_label_text": "Próxima forma: %s" % next_unlock_hint,
		"xp_bar_value": clampf(stage_progress_percent, 0.0, 100.0),
		"form_bar_value": clampf(float(total_crystals + crystals_run) / float(max(1, cheapest_skin_price)) * 100.0, 0.0, 100.0),
		"result_reveal_timer": 0.0,
		"result_count_crystals": 0.0,
		"result_target_crystals": total_run_crystals,
		"result_count_xp": 0.0,
		"result_target_xp": xp_gain
	}


func update_result_motion(
	delta: float,
	result_reveal_timer: float,
	result_badge_pulse: float,
	result_count_crystals: float,
	result_target_crystals: int,
	result_count_xp: float,
	result_target_xp: int
) -> Dictionary:
	return {
		"result_reveal_timer": result_reveal_timer + delta,
		"result_badge_pulse": result_badge_pulse + delta,
		"result_count_crystals": minf(result_count_crystals + delta * 28.0, float(result_target_crystals)),
		"result_count_xp": minf(result_count_xp + delta * 40.0, float(result_target_xp))
	}
