extends Control
class_name NeoBackground

@export var accent: Color = FragmentUiTheme.JADE
@export var secondary: Color = FragmentUiTheme.CYAN
@export var intensity: float = 1.0

var t: float = 0.0
var fireflies: Array[Dictionary] = []
var bamboo_stalks: Array[Dictionary] = []
var mist_ribbons: Array[Dictionary] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	_setup_fireflies()
	_setup_bamboo()
	_setup_mist()
	set_process(true)

func _setup_fireflies() -> void:
	for i in range(55):
		fireflies.append({
			"p": Vector2(rng.randf() * 720.0, rng.randf() * 1280.0),
			"s": rng.randf_range(1.2, 3.2),
			"a": rng.randf_range(0.12, 0.65),
			"v": rng.randf_range(6.0, 22.0),
			"drift": rng.randf_range(-12.0, 12.0),
			"phase": rng.randf() * TAU
		})

func _setup_bamboo() -> void:
	var positions: Array[float] = [42.0, 88.0, 140.0, 195.0, 580.0, 630.0, 678.0]
	for i in range(positions.size()):
		var far: bool = i >= 5
		bamboo_stalks.append({
			"x": positions[i],
			"y_offset": rng.randf() * 120.0,
			"speed": 0.18 if far else 0.32,
			"width": rng.randf_range(4.0, 7.0) if far else rng.randf_range(7.0, 12.0),
			"alpha": rng.randf_range(0.10, 0.20) if far else rng.randf_range(0.22, 0.38),
			"seg_h": rng.randf_range(70.0, 110.0),
			"leaf_offset": rng.randf_range(0.0, TAU)
		})
	for _i in range(5):
		bamboo_stalks.append({
			"x": rng.randf_range(220.0, 500.0),
			"y_offset": rng.randf() * 120.0,
			"speed": 0.08,
			"width": rng.randf_range(2.0, 4.0),
			"alpha": rng.randf_range(0.05, 0.10),
			"seg_h": rng.randf_range(80.0, 120.0),
			"leaf_offset": rng.randf_range(0.0, TAU)
		})

func _setup_mist() -> void:
	for i in range(6):
		mist_ribbons.append({
			"y": rng.randf() * 1280.0,
			"speed": rng.randf_range(4.0, 14.0),
			"alpha": rng.randf_range(0.04, 0.11),
			"h": rng.randf_range(40.0, 120.0),
			"phase": rng.randf() * TAU
		})

func _process(delta: float) -> void:
	t += delta
	for i in range(fireflies.size()):
		var ff := fireflies[i]
		var p: Vector2 = ff["p"]
		p.y += float(ff["v"]) * delta
		p.x += sin(t * 0.8 + float(ff["phase"])) * float(ff["drift"]) * delta
		if p.y > size.y + 30.0:
			p.y = -20.0
			p.x = rng.randf() * size.x
		ff["p"] = p
		fireflies[i] = ff
	for i in range(mist_ribbons.size()):
		var mr := mist_ribbons[i]
		var my: float = float(mr["y"])
		my += float(mr["speed"]) * delta
		if my > size.y + 80.0:
			my = -60.0
		mr["y"] = my
		mist_ribbons[i] = mr
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y

	# Deep background gradient - dark green wuxia
	draw_rect(Rect2(Vector2.ZERO, size), FragmentUiTheme.BG_DARK)
	for yi in range(0, int(h), 56):
		var f := float(yi) / maxf(h, 1.0)
		var c := Color(0.014, 0.048, 0.022, 0.18 + f * 0.12)
		draw_rect(Rect2(0, yi, w, 56), c)

	# Ambient light pools
	var top_c := Vector2(w * 0.5, h * 0.22)
	draw_circle(top_c, 380.0, Color(accent.r, accent.g, accent.b, 0.020 * intensity))
	draw_circle(top_c + Vector2(0, 180), 520.0, Color(secondary.r, secondary.g, secondary.b, 0.012 * intensity))

	# Bamboo stalks
	_draw_bamboo(w, h)

	# Mist ribbons
	for mr in mist_ribbons:
		var my: float = float(mr["y"])
		var mh: float = float(mr["h"])
		var ma: float = float(mr["alpha"]) * (0.7 + sin(t * 0.5 + float(mr["phase"])) * 0.3) * intensity
		draw_rect(Rect2(0, my, w, mh), Color(accent.r, accent.g, accent.b, ma))

	# Fireflies / spirit lights
	for ff in fireflies:
		var p: Vector2 = ff["p"]
		var a := float(ff["a"]) * (0.55 + sin(t * 1.8 + p.x * 0.03 + float(ff["phase"])) * 0.38)
		var s: float = float(ff["s"])
		draw_circle(p, s + 3.0, Color(accent.r, accent.g, accent.b, a * 0.28 * intensity))
		draw_circle(p, s, Color(0.72, 0.98, 0.80, a * 0.75 * intensity))

	# Decorative arcs (qi circles)
	for i in range(4):
		var r := 100.0 + float(i) * 40.0 + sin(t * 0.45 + float(i)) * 5.0
		var start := t * 0.10 + float(i) * 0.68
		draw_arc(top_c, r, start, start + PI * 1.18, 80, Color(accent.r, accent.g, accent.b, 0.038 * intensity), 1.4, true)

	# Subtle horizontal lines (energy flow)
	for i in range(7):
		var ly := 200.0 + float(i) * 86.0 + sin(t * 0.30 + float(i)) * 8.0
		draw_line(Vector2(48, ly), Vector2(w - 48, ly + sin(float(i)) * 18), Color(accent.r, accent.g, accent.b, 0.022 * intensity), 1.0)

func _draw_bamboo(w: float, h: float) -> void:
	for stalk in bamboo_stalks:
		var x: float = float(stalk["x"])
		var seg_h: float = float(stalk["seg_h"])
		var sw: float = float(stalk["width"])
		var base_alpha: float = float(stalk["alpha"])
		var y_scroll: float = fmod(float(stalk["y_offset"]) + t * float(stalk["speed"]) * 60.0, seg_h)
		var leaf_off: float = float(stalk["leaf_offset"])

		# Bamboo color - muted dark green
		var bc := Color(0.060, 0.220, 0.090, base_alpha)
		var nc := Color(0.090, 0.300, 0.120, base_alpha * 0.9)

		var sy: float = -seg_h + fmod(y_scroll, seg_h)
		while sy < h + seg_h:
			var seg_end: float = sy + seg_h - 3.0
			# Stalk segment
			draw_line(Vector2(x, sy), Vector2(x, seg_end), bc, sw)
			# Node mark
			draw_line(Vector2(x - sw * 1.8, sy), Vector2(x + sw * 1.8, sy), nc, sw * 0.7)
			# Leaf hint (small diagonal lines)
			if fmod(sy + leaf_off, 240.0) < seg_h:
				var lf_a: float = base_alpha * 0.55
				var lf_len: float = sw * 4.5
				draw_line(Vector2(x, sy + seg_h * 0.3), Vector2(x + lf_len, sy + seg_h * 0.3 - lf_len * 0.5), Color(0.080, 0.270, 0.110, lf_a), 1.5)
				draw_line(Vector2(x, sy + seg_h * 0.6), Vector2(x - lf_len, sy + seg_h * 0.6 - lf_len * 0.5), Color(0.080, 0.270, 0.110, lf_a), 1.5)
			sy += seg_h
