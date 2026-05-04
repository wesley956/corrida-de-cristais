extends Node
## SaveManager.gd - Camada de persistência local (JSON)
## Responsável por ler/escrever o arquivo de save.
## Nesta etapa, ele funciona como ponte: não controla o estado do jogo.

const SAVE_PATH: String = "user://fragment_rush_save_v2.json"


func get_default_data() -> Dictionary:
	return {
		"selected_skin": "nucleo_errante",
		"owned_skins": {"nucleo_errante": true},
		"total_crystals": 0,
		"best_distance": 0.0,
		"cultivation_xp": 0,
		"technique_levels": {
			"dash": 0,
			"jade": 0,
			"flow": 0
		},
		"mission_progress": {},
		"mission_completed": {},
		"last_daily_reward": "",
		"tutorial_seen": false,
		"games_played_total": 0
	}


func load_game() -> Dictionary:
	var default_data: Dictionary = get_default_data()

	if not FileAccess.file_exists(SAVE_PATH):
		return default_data

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		printerr("SaveManager: não foi possível abrir o save para leitura.")
		return default_data

	var json_string: String = file.get_as_text()
	file.close()

	if json_string.strip_edges().is_empty():
		return default_data

	var json := JSON.new()
	var error: Error = json.parse(json_string)

	if error != OK:
		printerr("SaveManager: JSON inválido no save: ", json.get_error_message())
		return default_data

	var loaded_data: Variant = json.get_data()

	if typeof(loaded_data) != TYPE_DICTIONARY:
		printerr("SaveManager: o save carregado não é um Dictionary.")
		return default_data

	return _merge_with_defaults(loaded_data as Dictionary, default_data)


func save_game(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		printerr("SaveManager: não foi possível abrir o save para escrita.")
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func _merge_with_defaults(data: Dictionary, default_data: Dictionary) -> Dictionary:
	var merged: Dictionary = default_data.duplicate(true)

	for key in data.keys():
		if not default_data.has(key):
			merged[key] = data[key]
			continue

		if typeof(data[key]) == TYPE_DICTIONARY and typeof(default_data[key]) == TYPE_DICTIONARY:
			merged[key] = _merge_with_defaults(data[key], default_data[key])
		else:
			merged[key] = data[key]

	return merged
