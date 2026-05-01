extends Control
class_name OrbPreview

@export var orb_color: Color = FragmentUiTheme.CYAN
@export var secondary_color: Color = FragmentUiTheme.JADE
@export var ring_count: int = 2
@export var power: float = 0.65
@export var shape_variant: int = 0

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
		var r := base * (2.0 + float(i) * 0.38) + sin(t * (1.5 + float(shape_variant) * 0.08) + float(i)) * (4.0 + float(shape_variant) * 0.8)
		var start := t * (0.35 + float(i) * 0.08) + float(i) * 0.8
		var color := orb_color if i % 2 == 0 else secondary_color
		draw_arc(center, r, start, start + PI * 1.28, 96, Color(color.r, color.g, color.b, 0.18), 2.4, true)
		draw_arc(center, r * 0.82, -start, -start + PI * 0.65, 64, Color(1, 1, 1, 0.08), 1.2, true)

	var pts := PackedVector2Array()
	var sides: int = 8
	if shape_variant == 1:
		sides = 10
	elif shape_variant == 2:
		sides = 12
	elif shape_variant == 3:
		sides = 9
	elif shape_variant >= 4:
		sides = 14
	for i in range(sides):
		var a := TAU * float(i) / float(sides) + t * (0.14 + float(shape_variant) * 0.012)
		var rr := base * (0.90 if i % 2 == 0 else 0.56)
		if shape_variant == 2:
			rr = base * (0.98 if i % 2 == 0 else 0.46)
		elif shape_variant == 3:
			rr = base * (0.94 if i % 2 == 0 else 0.52) + sin(float(i) + t * 1.5) * 2.0
		elif shape_variant >= 4:
			rr = base * (1.06 if i % 2 == 0 else 0.66)
		pts.append(center + Vector2(cos(a), sin(a)) * rr)

	draw_colored_polygon(pts, Color(orb_color.r, orb_color.g, orb_color.b, 0.88))
	var outline := PackedVector2Array(pts)
	outline.append(pts[0])
	draw_polyline(outline, Color(1, 1, 1, 0.68), 2.0)
	draw_circle(center, base * 0.24 + sin(t * 4.0) * 1.5, Color(1, 1, 1, 0.85))
