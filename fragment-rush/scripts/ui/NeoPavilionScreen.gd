extends Control
class_name NeoPavilionScreen

signal back_requested
signal skin_selected(skin_id: String)
signal action_requested

const SKIN_IDS: Array[String] = [
	"nucleo_errante",
	"semente_jade",
	"corredor_rubi",
	"coracao_nebular",
	"essencia_dourada",
	"corredor_sombrio",
	"corredor_celestial",
	"corredor_fragmentado"
]

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
	$SkinBar/Skin4,
	$SkinBar/Skin5,
	$SkinBar/Skin6,
	$SkinBar/Skin7
]

func _ready() -> void:
	FragmentUiTheme.label(title, 30, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(name_label, 26, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(meta_label, 17, FragmentUiTheme.GOLD, true)
	FragmentUiTheme.label(desc_label, 15, FragmentUiTheme.MUTED, true)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FragmentUiTheme.label(crystals_label, 15, FragmentUiTheme.MUTED, true)

	for b: Button in skin_buttons:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.022, 0.085, 0.038, 0.48), FragmentUiTheme.CYAN, 26))
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	for b: Button in [action_button, back_button]:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style())
		b.add_theme_stylebox_override("hover", FragmentUiTheme.button_style(Color(0.04, 0.14, 0.06, 0.62), FragmentUiTheme.JADE))
		b.add_theme_font_size_override("font_size", 18)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	action_button.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.05, 0.18, 0.08, 0.66), FragmentUiTheme.GOLD))
	back_button.pressed.connect(func() -> void: back_requested.emit())
	action_button.pressed.connect(func() -> void: action_requested.emit())

	for i: int in range(skin_buttons.size()):
		var sid: String = SKIN_IDS[i]
		skin_buttons[i].pressed.connect(_on_skin_button_pressed.bind(sid))

func _on_skin_button_pressed(skin_id: String) -> void:
	skin_selected.emit(skin_id)

func set_data(selected_id: String, selected_name: String, rarity: String, desc: String, effect: String, crystals: int, action_text: String, color: Color, ring_count: int, buttons: Array[Dictionary]) -> void:
	if bg == null or orb == null or name_label == null:
		call_deferred("set_data", selected_id, selected_name, rarity, desc, effect, crystals, action_text, color, ring_count, buttons)
		return

	bg.accent = color
	orb.orb_color = color
	orb.secondary_color = Color(0.88, 0.98, 0.90, 1.0)
	orb.ring_count = max(1, ring_count)

	match selected_id:
		"semente_jade":
			orb.shape_variant = 1
			orb.secondary_color = FragmentUiTheme.JADE
		"corredor_rubi":
			orb.shape_variant = 2
			orb.secondary_color = Color(1.0, 0.50, 0.40, 1.0)
		"coracao_nebular":
			orb.shape_variant = 3
			orb.secondary_color = FragmentUiTheme.VIOLET
		"essencia_dourada":
			orb.shape_variant = 4
			orb.secondary_color = FragmentUiTheme.GOLD
		"corredor_sombrio":
			orb.shape_variant = 2
			orb.secondary_color = Color(0.40, 0.20, 0.80, 1.0)
		"corredor_celestial":
			orb.shape_variant = 3
			orb.secondary_color = Color(0.80, 0.96, 1.0, 1.0)
		"corredor_fragmentado":
			orb.shape_variant = 4
			orb.secondary_color = Color(1.0, 0.60, 1.0, 1.0)
		_:
			orb.shape_variant = 0

	name_label.text = selected_name
	meta_label.text = "%s · %s" % [rarity, effect]
	desc_label.text = desc
	crystals_label.text = "Cristais Espirituais · %d" % crystals
	action_button.text = action_text

	for i: int in range(min(buttons.size(), skin_buttons.size())):
		var data: Dictionary = buttons[i]
		skin_buttons[i].text = "%s\n%s" % [str(data.get("name", "")), str(data.get("state", ""))]
		var c: Color = data.get("color", FragmentUiTheme.CYAN)
		skin_buttons[i].add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(c.r, c.g, c.b, 0.14), c, 26))
