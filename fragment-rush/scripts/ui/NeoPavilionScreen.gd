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
	FragmentUiTheme.label(name_label, 28, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(meta_label, 18, FragmentUiTheme.GOLD, true)
	FragmentUiTheme.label(desc_label, 16, FragmentUiTheme.MUTED, true)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FragmentUiTheme.label(crystals_label, 16, FragmentUiTheme.MUTED, true)

	for b in skin_buttons:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.02, 0.09, 0.14, 0.42), FragmentUiTheme.CYAN, 28))
		b.add_theme_font_size_override("font_size", 13)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	for b in [action_button, back_button]:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style())
		b.add_theme_stylebox_override("hover", FragmentUiTheme.button_style(Color(0.04, 0.14, 0.20, 0.62), FragmentUiTheme.JADE))
		b.add_theme_font_size_override("font_size", 19)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	action_button.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.05, 0.16, 0.22, 0.66), FragmentUiTheme.GOLD))
	back_button.pressed.connect(func(): back_requested.emit())
	action_button.pressed.connect(func(): action_requested.emit())

	var ids := ["nucleo_errante", "semente_jade", "orbe_celestial", "coracao_nebular", "essencia_dourada"]
	for i in range(skin_buttons.size()):
		var sid := ids[i]
		skin_buttons[i].pressed.connect(func(id := sid): skin_selected.emit(id))

func set_data(selected_id: String, selected_name: String, rarity: String, desc: String, effect: String, crystals: int, action_text: String, color: Color, ring_count: int, buttons: Array[Dictionary]) -> void:
	bg.accent = color
	orb.orb_color = color
	orb.ring_count = max(1, ring_count)
	name_label.text = selected_name
	meta_label.text = "%s · %s" % [rarity, effect]
	desc_label.text = desc
	crystals_label.text = "Cristais Espirituais · %d" % crystals
	action_button.text = action_text
	for i in range(min(buttons.size(), skin_buttons.size())):
		var data := buttons[i]
		skin_buttons[i].text = "%s\n%s" % [str(data.get("name", "")), str(data.get("state", ""))]
		var c: Color = data.get("color", FragmentUiTheme.CYAN)
		skin_buttons[i].add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(c.r, c.g, c.b, 0.16), c, 28))
