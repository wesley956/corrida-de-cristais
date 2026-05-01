extends CanvasLayer
class_name FragmentUiController

signal start_requested
signal pavilion_requested
signal core_requested
signal daily_requested
signal guide_requested
signal back_requested
signal skin_selected(skin_id: String)
signal skin_action_requested
signal upgrade_requested(tech_id: String)

var menu
var pavilion
var core

func _ready() -> void:
	menu = preload("res://scenes/ui/NeoMenuScreen.tscn").instantiate()
	pavilion = preload("res://scenes/ui/NeoPavilionScreen.tscn").instantiate()
	core = preload("res://scenes/ui/NeoCoreScreen.tscn").instantiate()

	add_child(menu)
	add_child(pavilion)
	add_child(core)

	menu.start_requested.connect(func() -> void: start_requested.emit())
	menu.pavilion_requested.connect(func() -> void: pavilion_requested.emit())
	menu.core_requested.connect(func() -> void: core_requested.emit())
	menu.daily_requested.connect(func() -> void: daily_requested.emit())
	menu.guide_requested.connect(func() -> void: guide_requested.emit())

	pavilion.back_requested.connect(func() -> void: back_requested.emit())
	pavilion.skin_selected.connect(func(id: String) -> void: skin_selected.emit(id))
	pavilion.action_requested.connect(func() -> void: skin_action_requested.emit())

	core.back_requested.connect(func() -> void: back_requested.emit())
	core.upgrade_requested.connect(func(id: String) -> void: upgrade_requested.emit(id))

	call_deferred("show_menu")

func show_menu() -> void:
	if menu == null or pavilion == null or core == null:
		return
	menu.visible = true
	pavilion.visible = false
	core.visible = false

func show_pavilion() -> void:
	if menu == null or pavilion == null or core == null:
		return
	menu.visible = false
	pavilion.visible = true
	core.visible = false

func show_core() -> void:
	if menu == null or pavilion == null or core == null:
		return
	menu.visible = false
	pavilion.visible = false
	core.visible = true

func hide_all() -> void:
	if menu != null:
		menu.visible = false
	if pavilion != null:
		pavilion.visible = false
	if core != null:
		core.visible = false
