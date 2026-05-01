extends Control
class_name OrbPreview

@export var orb_color: Color = FragmentUiTheme.CYAN
@export var secondary_color: Color = FragmentUiTheme.JADE
@export var ring_count: int = 2
@export var power: float = 0.65

var t: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var base := minf(size.x, size.y) * 0.18
	draw_circle(center, base * 3.4, Color(orb_color.r, orb_color.g, orb_color.b, 0.045 + power * 0.025))
	draw_circle(center, base * 2.3, Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.035 + power * 0.025))

	for i in range(ring_count):
		var r := base * (2.0 + float(i) * 0.38) + sin(t * 1.5 + float(i)) * 4.0
		var start := t * (0.35 + float(i) * 0.08) + float(i) * 0.8
		var color := orb_color if i % 2 == 0 else secondary_color
		draw_arc(center, r, start, start + PI * 1.28, 96, Color(color.r, color.g, color.b, 0.18), 2.4, true)
		draw_arc(center, r * 0.82, -start, -start + PI * 0.65, 64, Color(1, 1, 1, 0.08), 1.2, true)

	var pts := PackedVector2Array()
	for i in range(8):
		var a := TAU * float(i) / 8.0 + t * 0.18
		var rr := base * (0.86 if i % 2 == 0 else 0.56)
		pts.append(center + Vector2(cos(a), sin(a)) * rr)

	draw_colored_polygon(pts, Color(orb_color.r, orb_color.g, orb_color.b, 0.88))
	var outline := PackedVector2Array(pts)
	outline.append(pts[0])
	draw_polyline(outline, Color(1, 1, 1, 0.68), 2.0)
	draw_circle(center, base * 0.24 + sin(t * 4.0) * 1.5, Color(1, 1, 1, 0.85))
