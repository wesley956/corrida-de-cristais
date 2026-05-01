extends Control
class_name NeoCoreScreen

signal back_requested
signal upgrade_requested(tech_id: String)

@onready var bg: NeoBackground = $NeoBackground
@onready var orb: OrbPreview = $OrbPreview
@onready var title: Label = $Title
@onready var stage_label: Label = $Stage
@onready var next_label: Label = $NextCircle
@onready var xp_bar: ProgressBar = $XpBar
@onready var back_button: Button = $BackButton
@onready var tech_buttons: Array[Button] = [
	$Techniques/Dash,
	$Techniques/Jade,
	$Techniques/Flow
]

func _ready() -> void:
	FragmentUiTheme.label(title, 32, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(stage_label, 22, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(next_label, 16, FragmentUiTheme.MUTED, true)
	next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	xp_bar.add_theme_stylebox_override("background", FragmentUiTheme.panel_style(Color(0.03, 0.08, 0.12, 0.62), FragmentUiTheme.CYAN, 18, 1))
	xp_bar.add_theme_stylebox_override("fill", FragmentUiTheme.panel_style(FragmentUiTheme.JADE, FragmentUiTheme.JADE, 18, 0))
	xp_bar.show_percentage = false

	for b in tech_buttons:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.02, 0.09, 0.14, 0.42), FragmentUiTheme.CYAN, 36))
		b.add_theme_stylebox_override("hover", FragmentUiTheme.button_style(Color(0.04, 0.14, 0.20, 0.62), FragmentUiTheme.JADE, 36))
		b.add_theme_font_size_override("font_size", 13)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	tech_buttons[0].pressed.connect(func(): upgrade_requested.emit("dash"))
	tech_buttons[1].pressed.connect(func(): upgrade_requested.emit("jade"))
	tech_buttons[2].pressed.connect(func(): upgrade_requested.emit("flow"))

	back_button.add_theme_stylebox_override("normal", FragmentUiTheme.button_style())
	back_button.add_theme_font_size_override("font_size", 18)
	back_button.add_theme_color_override("font_color", FragmentUiTheme.PEARL)
	back_button.pressed.connect(func(): back_requested.emit())

func set_data(stage: String, xp: int, progress: float, next_circle: String, color: Color, ring_count: int, techniques: Array[Dictionary]) -> void:
	bg.accent = color
	orb.orb_color = color
	orb.ring_count = max(1, ring_count)
	stage_label.text = "%s\nXP de Cultivo · %d" % [stage, xp]
	next_label.text = next_circle
	xp_bar.value = clampf(progress, 0.0, 100.0)

	for i in range(min(techniques.size(), tech_buttons.size())):
		var d := techniques[i]
		tech_buttons[i].text = "%s\nNv. %s\n%s" % [str(d.get("name", "")), str(d.get("level", "")), str(d.get("action", ""))]
