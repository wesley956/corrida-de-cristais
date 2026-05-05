extends Node
## HudSystem.gd
## Ponte segura para centralizar formatação e estado textual do HUD.
##
## Nesta etapa:
## - Calcula textos, cores e valores de HUD.
## - Main.gd ainda mantém os Labels, ProgressBar e layout.
## - Main.gd ainda aplica os valores nos nodes visuais.

func build_hud_state(
	crystals_run: int,
	score: int,
	distance: float,
	best_distance: float,
	combo: int,
	dash_cooldown: float,
	resonance_value: float,
	flow_timer: float,
	magnet_timer: float,
	combo_color: Color
) -> Dictionary:
	var dash_text: String = "Dash pronto"
	var dash_color: Color = Color(0.76, 0.98, 0.82, 0.90)

	var dc: float = maxf(0.0, dash_cooldown)
	if dc > 0.0:
		dash_text = "Dash %.1fs" % dc
		dash_color = Color(0.7, 0.5, 0.3, 0.9)

	var resonance_text: String = "Ressonância"
	if flow_timer > 0.0:
		resonance_text = "FLUXO ATIVO  %.1fs" % flow_timer
	elif magnet_timer > 0.0:
		resonance_text = "TOQUE DE JADE  %.1fs" % magnet_timer

	return {
		"crystal_text": str(crystals_run),
		"score_text": "Pts %d" % score,
		"distance_text": "%d m" % int(distance),
		"best_text": "Recorde %d m" % int(best_distance),
		"combo_text": "x%d" % max(1, combo),
		"combo_color": combo_color,
		"dash_text": dash_text,
		"dash_color": dash_color,
		"resonance_value": resonance_value,
		"resonance_text": resonance_text
	}


func build_status_state(text: String, color: Color) -> Dictionary:
	return {
		"text": text,
		"color": color,
		"alpha": 1.0
	}


func update_status_alpha(current_text: String, current_alpha: float, delta: float) -> float:
	if current_text != "" and current_alpha > 0.0:
		return maxf(0.0, current_alpha - delta * 0.55)

	return current_alpha
