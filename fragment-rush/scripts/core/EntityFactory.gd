extends RefCounted
## EntityFactory.gd
## Fábrica segura de dicionários de entidades.
##
## Nesta etapa, ela apenas cria os Dictionary.
## O Main.gd ainda controla:
## - entities.append()
## - colisão
## - desenho
## - movimento
## - coleta
## - efeitos

static func create_obstacle(x: float, y: float, obstacle_type: String) -> Dictionary:
	return {
		"type": "obstacle",
		"x": x,
		"y": y,
		"hw": 28.0,
		"hh": 38.0,
		"otype": obstacle_type,
		"rot": 0.0,
		"age": 0.0
	}


static func create_crystal(x: float, y: float, crystal_type: Dictionary) -> Dictionary:
	return {
		"type": "crystal",
		"x": x,
		"y": y,
		"crystal_type": str(crystal_type["id"]),
		"color": crystal_type["color"],
		"glow": crystal_type["glow"],
		"size": float(crystal_type["size"]),
		"age": 0.0
	}


static func create_powerup(x: float, y: float, powerup_type: String) -> Dictionary:
	return {
		"type": "powerup",
		"x": x,
		"y": y,
		"ptype": powerup_type,
		"age": 0.0
	}
