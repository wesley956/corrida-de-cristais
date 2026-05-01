extends RefCounted
class_name FragmentUiTheme

const BG_DARK: Color = Color(0.007, 0.018, 0.035, 1.0)
const GLASS: Color = Color(0.035, 0.105, 0.155, 0.54)
const GLASS_SOFT: Color = Color(0.035, 0.105, 0.155, 0.28)
const PEARL: Color = Color(0.93, 0.98, 1.0, 1.0)
const MUTED: Color = Color(0.66, 0.82, 0.92, 0.80)
const CYAN: Color = Color(0.305, 0.922, 1.0, 1.0)
const JADE: Color = Color(0.376, 0.965, 0.702, 1.0)
const VIOLET: Color = Color(0.545, 0.424, 1.0, 1.0)
const GOLD: Color = Color(1.0, 0.824, 0.478, 1.0)

static func panel_style(bg: Color = GLASS, border: Color = CYAN, radius: int = 34, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.34)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
	style.shadow_size = 14
	style.set_content_margin_all(14.0)
	return style

static func button_style(bg: Color = GLASS_SOFT, border: Color = CYAN, radius: int = 42) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.42)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 8
	style.set_content_margin_all(10.0)
	return style

static func label(label: Label, size: int, color: Color = PEARL, center: bool = false) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	if center:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
