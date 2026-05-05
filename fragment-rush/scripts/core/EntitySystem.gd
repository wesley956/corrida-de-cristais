extends Node
## EntitySystem.gd
## Ponte segura para centralizar acesso à lista de entidades.
##
## Nesta etapa, ele NÃO controla colisão, desenho, movimento ou coleta.
## Ele apenas recebe a referência do Array entities do Main.gd e opera sobre ela.

var entities_ref: Array = []
var has_bound_entities: bool = false


func bind_entities(source_entities: Array) -> void:
	entities_ref = source_entities
	has_bound_entities = true


func add_entity(entity: Dictionary) -> void:
	if not has_bound_entities:
		return

	entities_ref.append(entity)


func clear_entities() -> void:
	if not has_bound_entities:
		return

	entities_ref.clear()


func get_entities() -> Array:
	return entities_ref


func count() -> int:
	if not has_bound_entities:
		return 0

	return entities_ref.size()
