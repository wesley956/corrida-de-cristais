extends Control
class_name NeoBackground

@export var accent: Color = FragmentUiTheme.CYAN
@export var secondary: Color = FragmentUiTheme.JADE
@export var intensity: float = 1.0

var t: float = 0.0
var stars: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(70):
		stars.append({
			"p": Vector2(randf() * 720.0, randf() * 1280.0),
			"s": randf_range(0.7, 2.6),
			"a": randf_range(0.16, 0.72),
			"v": randf_range(8.0, 34.0)
		})
	set_process(true)

func _process(delta: float) -> void:
	t += delta
	for i in range(stars.size()):
		var st := stars[i]
		var p: Vector2 = st["p"]
		p.y += float(st["v"]) * delta
		if p.y > size.y + 20.0:
			p.y = -20.0
			p.x = randf() * size.x
		st["p"] = p
		stars[i] = st
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), FragmentUiTheme.BG_DARK)
	for y in range(0, int(h), 64):
		var f := float(y) / maxf(h, 1.0)
		var c := FragmentUiTheme.BG_DARK.lerp(accent, 0.10 + f * 0.08)
		c.a = 0.12 * intensity
		draw_rect(Rect2(0, y, w, 64), c)

	var center := Vector2(w * 0.5, h * 0.28)
	draw_circle(center, 360.0, Color(accent.r, accent.g, accent.b, 0.025 * intensity))
	draw_circle(center + Vector2(0, 120), 520.0, Color(secondary.r, secondary.g, secondary.b, 0.012 * intensity))

	for st in stars:
		var p: Vector2 = st["p"]
		var a := float(st["a"]) * (0.65 + sin(t * 1.3 + p.x * 0.02) * 0.25)
		draw_circle(p, float(st["s"]), Color(0.82, 0.96, 1.0, a * 0.45))

	for i in range(9):
		var yy := 180.0 + float(i) * 88.0 + sin(t * 0.38 + float(i)) * 10.0
		draw_line(Vector2(42, yy), Vector2(w - 42, yy + sin(float(i)) * 22), Color(accent.r, accent.g, accent.b, 0.025 * intensity), 1.0)

	for i in range(5):
		var r := 110.0 + float(i) * 46.0 + sin(t * 0.6 + float(i)) * 4.0
		var start := t * 0.12 + float(i) * 0.72
		draw_arc(center, r, start, start + PI * 1.35, 96, Color(accent.r, accent.g, accent.b, 0.050 * intensity), 1.6, true)
