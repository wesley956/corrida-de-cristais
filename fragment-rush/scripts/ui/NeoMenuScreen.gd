extends Control
class_name NeoMenuScreen

signal start_requested
signal pavilion_requested
signal core_requested
signal daily_requested
signal guide_requested

@onready var bg: NeoBackground = $NeoBackground
@onready var orb: OrbPreview = $Center/OrbPreview
@onready var title: Label = $Center/Title
@onready var subtitle: Label = $Center/Subtitle
@onready var stats: Label = $Center/Stats
@onready var start_button: Button = $Center/StartButton
@onready var pavilion_button: Button = $Center/Secondary/PavilionButton
@onready var core_button: Button = $Center/Secondary/CoreButton
@onready var daily_button: Button = $Center/DailyButton
@onready var guide_button: Button = $Center/GuideButton

func _ready() -> void:
	FragmentUiTheme.label(title, 40, FragmentUiTheme.PEARL, true)
	FragmentUiTheme.label(subtitle, 18, FragmentUiTheme.MUTED, true)
	FragmentUiTheme.label(stats, 16, FragmentUiTheme.MUTED, true)

	for b in [start_button, pavilion_button, core_button, daily_button, guide_button]:
		b.add_theme_stylebox_override("normal", FragmentUiTheme.button_style())
		b.add_theme_stylebox_override("hover", FragmentUiTheme.button_style(Color(0.04, 0.14, 0.20, 0.62), FragmentUiTheme.JADE))
		b.add_theme_stylebox_override("pressed", FragmentUiTheme.button_style(Color(0.06, 0.18, 0.23, 0.72), FragmentUiTheme.GOLD))
		b.add_theme_font_size_override("font_size", 18)
		b.add_theme_color_override("font_color", FragmentUiTheme.PEARL)

	start_button.add_theme_stylebox_override("normal", FragmentUiTheme.button_style(Color(0.04, 0.16, 0.22, 0.66), FragmentUiTheme.CYAN))
	start_button.add_theme_font_size_override("font_size", 24)

	start_button.pressed.connect(func(): start_requested.emit())
	pavilion_button.pressed.connect(func(): pavilion_requested.emit())
	core_button.pressed.connect(func(): core_requested.emit())
	daily_button.pressed.connect(func(): daily_requested.emit())
	guide_button.pressed.connect(func(): guide_requested.emit())

	modulate.a = 0.0
	scale = Vector2(0.98, 0.98)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.36)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, 0.36)

func set_data(stage: String, xp: int, circles: int, circle_total: int, best: int, crystals: int, daily_available: bool, color: Color, ring_count: int) -> void:
	if bg == null or orb == null or stats == null:
		call_deferred("set_data", stage, xp, circles, circle_total, best, crystals, daily_available, color, ring_count)
		return

	bg.accent = color
	orb.orb_color = color
	orb.ring_count = max(1, ring_count)
	stats.text = "%s · XP %d · Círculos %d/%d\nMarca %dm · Cristais %d" % [stage, xp, circles, circle_total, best, crystals]
	daily_button.text = "ESSÊNCIA DIÁRIA +180" if daily_available else "ESSÊNCIA RECEBIDA"
	daily_button.disabled = not daily_available
