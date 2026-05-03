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
	_apply_png_style_to_buttons(self)

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


func _load_ui_texture(path: String) -> Texture2D:
	var tex: Texture2D = load(path) as Texture2D

	if tex == null:
		push_warning("UI texture nao carregou: " + path)

	return tex

func _make_texture_style(path: String, fallback_color: Color) -> StyleBox:
	var tex: Texture2D = _load_ui_texture(path)

	if tex == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = fallback_color
		flat.corner_radius_top_left = 24
		flat.corner_radius_top_right = 24
		flat.corner_radius_bottom_left = 24
		flat.corner_radius_bottom_right = 24
		flat.border_width_left = 1
		flat.border_width_top = 1
		flat.border_width_right = 1
		flat.border_width_bottom = 1
		flat.border_color = Color(0.10, 0.95, 0.62, 0.55)
		return flat

	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 24
	sb.texture_margin_top = 24
	sb.texture_margin_right = 24
	sb.texture_margin_bottom = 24
	sb.content_margin_left = 18
	sb.content_margin_top = 10
	sb.content_margin_right = 18
	sb.content_margin_bottom = 10
	return sb

func _apply_png_style_to_buttons(root: Node) -> void:
	var main_style: StyleBox = _make_texture_style("res://assets/ui/ui_button_main.png", Color(0.00, 0.14, 0.11, 0.88))
	var sec_style: StyleBox = _make_texture_style("res://assets/ui/ui_button_secondary.png", Color(0.00, 0.08, 0.06, 0.72))

	_apply_png_style_to_buttons_recursive(root, main_style, sec_style)

func _apply_png_style_to_buttons_recursive(node: Node, main_style: StyleBox, sec_style: StyleBox) -> void:
	if node is Button:
		var btn := node as Button
		var txt := btn.text.to_lower()

		var chosen: StyleBox = main_style
		if txt != "iniciar corrida":
			chosen = sec_style

		btn.add_theme_stylebox_override("normal", chosen)
		btn.add_theme_stylebox_override("hover", chosen)
		btn.add_theme_stylebox_override("pressed", chosen)
		btn.add_theme_stylebox_override("focus", chosen)
		btn.add_theme_color_override("font_color", Color(0.88, 1.0, 0.93, 0.96))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.68, 1.0, 0.84, 1.0))

	for child in node.get_children():
		_apply_png_style_to_buttons_recursive(child, main_style, sec_style)
