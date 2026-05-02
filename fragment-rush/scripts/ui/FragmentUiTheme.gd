extends RefCounted
class_name FragmentUiTheme

const BG_DARK: Color = Color(0.010, 0.036, 0.018, 1.0)
const GLASS: Color = Color(0.020, 0.076, 0.038, 0.60)
const GLASS_SOFT: Color = Color(0.022, 0.082, 0.040, 0.32)
const PEARL: Color = Color(0.880, 0.980, 0.900, 1.0)
const MUTED: Color = Color(0.500, 0.780, 0.600, 0.85)
const CYAN: Color = Color(0.220, 0.920, 0.560, 1.0)
const JADE: Color = Color(0.180, 0.840, 0.400, 1.0)
const VIOLET: Color = Color(0.545, 0.424, 1.0, 1.0)
const GOLD: Color = Color(1.0, 0.824, 0.478, 1.0)

static func panel_style(bg: Color = GLASS, border: Color = CYAN, radius: int = 34, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.38)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 14
	style.set_content_margin_all(14.0)
	return style

static func button_style(bg: Color = GLASS_SOFT, border: Color = CYAN, radius: int = 42) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.44)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
	style.shadow_size = 8
	style.set_content_margin_all(10.0)
	return style

static func label(lbl: Label, size: int, color: Color = PEARL, center: bool = false) -> void:
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.60))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	if center:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
