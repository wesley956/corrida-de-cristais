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
	var base := minf(size.x, size.y) * 0.14
	var c := orb_color
	var gc := secondary_color

	# Outer glow halos
	draw_circle(center, base * 4.2, Color(c.r, c.g, c.b, 0.040 + power * 0.020))
	draw_circle(center, base * 2.8, Color(gc.r, gc.g, gc.b, 0.055 + power * 0.025))

	# Resonance rings
	for i in range(ring_count):
		var r := base * (2.0 + float(i) * 0.42) + sin(t * (1.4 + float(shape_variant) * 0.08) + float(i)) * (4.5 + float(shape_variant) * 0.9)
		var start := t * (0.32 + float(i) * 0.09) + float(i) * 0.85
		var ring_c := c if i % 2 == 0 else gc
		draw_arc(center, r, start, start + PI * 1.32, 96, Color(ring_c.r, ring_c.g, ring_c.b, 0.22), 2.6, true)
		draw_arc(center, r * 0.80, -start, -start + PI * 0.70, 64, Color(1, 1, 1, 0.10), 1.2, true)

	# Draw animated stickman
	_draw_stickman_preview(center, base)

func _draw_stickman_preview(center: Vector2, base: float) -> void:
	var c := orb_color
	var gc := secondary_color
	var stroke: float = maxf(2.2, base * 0.16)
	var head_r: float = base * 0.72
	var body_h: float = base * 1.90
	var arm_l: float = base * 1.30
	var leg_l: float = base * 1.60

	var run_phase: float = t * 5.5
	var arm_swing: float = sin(run_phase) * 16.0
	var leg_swing: float = sin(run_phase) * 20.0
	var bob: float = sin(run_phase * 2.0) * 2.5

	var head_pos := center + Vector2(0, -body_h - head_r + bob)
	var neck_pos := center + Vector2(0, -body_h + bob)
	var hip_pos := center + Vector2(0, bob)

	# Glow
	draw_circle(head_pos, head_r + base * 0.60, Color(gc.r, gc.g, gc.b, 0.14))
	draw_line(neck_pos + Vector2(-1, 0), hip_pos + Vector2(-1, 0), Color(gc.r, gc.g, gc.b, 0.20), stroke + 5)
	draw_circle(head_pos, head_r + base * 0.28, Color(gc.r, gc.g, gc.b, 0.26))

	# Body
	draw_line(neck_pos, hip_pos, Color(c.r, c.g, c.b, 0.92), stroke)

	# Head
	draw_circle(head_pos, head_r, Color(c.r, c.g, c.b, 0.90))
	draw_circle(head_pos, head_r * 0.48, Color(1.0, 1.0, 1.0, 0.22))

	# Crystal on chest
	var chest := neck_pos.lerp(hip_pos, 0.38)
	var cs: float = base * 0.38
	var crystal_pts := PackedVector2Array([
		chest + Vector2(0, -cs),
		chest + Vector2(cs * 0.7, 0),
		chest + Vector2(0, cs),
		chest + Vector2(-cs * 0.7, 0)
	])
	draw_colored_polygon(crystal_pts, Color(gc.r, gc.g, gc.b, 0.92))
	draw_circle(chest, cs * 0.32, Color(1.0, 1.0, 1.0, 0.80))

	# Arms
	var shoulder := neck_pos + Vector2(0, base * 0.45)
	draw_line(shoulder, shoulder + Vector2(-arm_l * 0.45 + arm_swing * 0.55, arm_l * 0.75), Color(c.r, c.g, c.b, 0.85), stroke - 0.5)
	draw_line(shoulder, shoulder + Vector2(arm_l * 0.45 - arm_swing * 0.55, arm_l * 0.75), Color(c.r, c.g, c.b, 0.85), stroke - 0.5)

	# Legs
	draw_line(hip_pos + Vector2(-base * 0.22, 0), hip_pos + Vector2(-base * 0.22 - leg_swing * 0.48, leg_l), Color(c.r, c.g, c.b, 0.85), stroke - 0.5)
	draw_line(hip_pos + Vector2(base * 0.22, 0), hip_pos + Vector2(base * 0.22 + leg_swing * 0.48, leg_l), Color(c.r, c.g, c.b, 0.85), stroke - 0.5)

	# Variant accents
	if shape_variant >= 1:
		for i in range(min(shape_variant, 4)):
			var a: float = t * 0.38 + float(i) * TAU / maxf(float(shape_variant), 1.0)
			var rr: float = base * (1.65 + float(i) * 0.22)
			var p: Vector2 = center + Vector2(cos(a), sin(a)) * rr
			draw_circle(p, base * 0.18, Color(gc.r, gc.g, gc.b, 0.55))
