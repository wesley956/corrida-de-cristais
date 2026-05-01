extends Control
class_name NeoPavilionScreen

signal back_requested
signal skin_selected(skin_id: String)
signal action_requested

@onready var bg: NeoBackground = $NeoBackground
@onready var orb: OrbPreview = $OrbPreview
@onready var title: Label = $Title
@onready var name_label: Label = $Info/Name
@onready var meta_label: Label = $Info/Meta
@onready var desc_label: Label = $Info/Description
@onready var crystals_label: Label = $Crystals
@onready var action_button: Button = $ActionButton
@onready var back_button: Button = $BackButton
@onready var skin_buttons: Array[Button] = [
	$SkinBar/Skin0,
	$SkinBar/Skin1,
	$SkinBar/Skin2,
	$SkinBar/Skin3,
	$SkinBar/Skin4
]

func _ready() -> void:
	FragmentUiTheme.label(title, 32, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(name_label, 30, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(meta_label, 18, FragmentUiTheme.GOLD, true)
	FragmentUiTheme.label(desc_label, 17, FragmentUiTheme.MUTED, true)
	FragmentUiTheme.label(crystals_label, 16, FragmentUiTheme.MUTED, true)

	for b: Button in skin_buttons:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.02, 0.09, 0.14, 0.42), FragmentUiTheme.CYAN, 28))
		b.add_theme_font_size_override("font_size", 14)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	for b: Button in [action_button, back_button]:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style())
		b.add_theme_stylebox_override("hover", FragmentUiTheme.button_style(Color(0.04, 0.14, 0.20, 0.62), FragmentUiTheme.JADE))
		b.add_theme_font_size_override("font_size", 19)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	action_button.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.05, 0.16, 0.22, 0.66), FragmentUiTheme.GOLD))
	back_button.pressed.connect(func() -> void: back_requested.emit())
	action_button.pressed.connect(func() -> void: action_requested.emit())

	var ids: Array[String] = ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for i: int in range(skin_buttons.size()):
		var sid: String = ids[i]
		skin_buttons[i].pressed.connect(_on_skin_button_pressed.bind(sid))

func _on_skin_button_pressed(skin_id: String) -> void:
	skin_selected.emit(skin_id)

func set_data(selected_id: String, selected_name: String, rarity: String, desc: String, effect: String, crystals: int, action_text: String, color: Color, ring_count: int, buttons: Array[Dictionary]) -> void:
	bg.accent = color
	orb.orb_color = color
	orb.ring_count = max(1, ring_count)
	name_label.text = selected_name
	meta_label.text = "%s · %s" % [rarity, effect]
	desc_label.text = desc
	crystals_label.text = "Cristais Espirituais · %d" % crystals
	action_button.text = action_text

	for i: int in range(min(buttons.size(), skin_buttons.size())):
		var data: Dictionary = buttons[i]
		skin_buttons[i].text = "%s\n%s" % [str(data.get("name", "")), str(data.get("state", ""))]
		var c: Color = data.get("color", FragmentUiTheme.CYAN)
		skin_buttons[i].add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(c.r, c.g, c.b, 0.16), c, 28))
