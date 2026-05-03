extends Control
class_name OrbPreview

@export var orb_color: Color = FragmentUiTheme.CYAN
@export var secondary_color: Color = FragmentUiTheme.JADE
@export var ring_count: int = 3
@export var power: float = 0.75
@export var shape_variant: int = 0

var t: float = 0.0
var run_frames: Array[Texture2D] = []
var dash_frames: Array[Texture2D] = []
var frames_loaded: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _load_character_frames()
    set_process(true)

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _load_png(path: String) -> Texture2D:
    var tex: Texture2D = load(path) as Texture2D

    if tex == null:
        push_warning("OrbPreview PNG nao carregou: " + path)

    return tex

func _load_character_frames() -> void:
    if frames_loaded:
        return

    frames_loaded = true
    run_frames.clear()
    dash_frames.clear()

    for i: int in range(1, 9):
        var tex: Texture2D = _load_png("res://assets/characters/stick_runner/frames/run/run_%02d.png" % i)
        if tex != null:
            run_frames.append(tex)

    for i: int in range(1, 7):
        var tex: Texture2D = _load_png("res://assets/characters/stick_runner/frames/dash/dash_%02d.png" % i)
        if tex != null:
            dash_frames.append(tex)

func _draw() -> void:
    var center: Vector2 = size * 0.5
    var base: float = minf(size.x, size.y) * 0.14
    var c: Color = orb_color
    var gc: Color = secondary_color

    # Aura grande atrás do personagem
    draw_circle(center, base * 4.55, Color(c.r, c.g, c.b, 0.040 + power * 0.025))
    draw_circle(center, base * 3.20, Color(gc.r, gc.g, gc.b, 0.055 + power * 0.030))
    draw_circle(center, base * 2.10, Color(0.0, 0.0, 0.0, 0.22))

    # Anéis girando
    for i: int in range(ring_count):
        var r: float = base * (2.05 + float(i) * 0.48) + sin(t * (1.25 + float(shape_variant) * 0.08) + float(i)) * (4.0 + float(shape_variant) * 0.8)
        var start: float = t * (0.35 + float(i) * 0.10) + float(i) * 0.85
        var ring_c: Color = c if i % 2 == 0 else gc

        draw_arc(center, r, start, start + PI * 1.30, 96, Color(ring_c.r, ring_c.g, ring_c.b, 0.26), 2.8, true)
        draw_arc(center, r * 0.78, -start, -start + PI * 0.72, 64, Color(1, 1, 1, 0.11), 1.3, true)

    # Bolinhas orbitando
    var dots: int = 3 + min(shape_variant, 3)
    for i: int in range(dots):
        var a: float = t * (0.72 + float(i) * 0.05) + float(i) * TAU / float(max(dots, 1))
        var rr: float = base * (2.25 + float(i % 2) * 0.34)
        var p: Vector2 = center + Vector2(cos(a), sin(a)) * rr
        draw_circle(p, base * 0.17, Color(gc.r, gc.g, gc.b, 0.68))
        draw_circle(p, base * 0.09, Color(1, 1, 1, 0.45))

    _draw_character_preview(center, base)

func _draw_character_preview(center: Vector2, base: float) -> void:
    _load_character_frames()

    var frames: Array[Texture2D] = run_frames

    if frames.size() <= 0:
        _draw_fallback_character(center, base)
        return

    var idx: int = int(t * 10.0) % frames.size()
    var tex: Texture2D = frames[idx]

    if tex == null:
        _draw_fallback_character(center, base)
        return

    var target_h: float = minf(size.x, size.y) * 0.58
    var aspect: float = float(tex.get_width()) / maxf(float(tex.get_height()), 1.0)
    var draw_size: Vector2 = Vector2(target_h * aspect, target_h)

    # Levemente acima do centro para ficar bonito no menu
    var draw_pos: Vector2 = center + Vector2(0, base * 0.18)

    # Glow atrás do sprite
    draw_circle(draw_pos + Vector2(0, -base * 0.25), target_h * 0.38, Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.12))
    draw_circle(draw_pos + Vector2(0, -base * 0.10), target_h * 0.24, Color(orb_color.r, orb_color.g, orb_color.b, 0.10))

    draw_set_transform(draw_pos, 0.0, Vector2.ONE)
    draw_texture_rect(
        tex,
        Rect2(-draw_size.x * 0.5, -draw_size.y * 0.5, draw_size.x, draw_size.y),
        false,
        Color(1, 1, 1, 1)
    )
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_fallback_character(center: Vector2, base: float) -> void:
    var c: Color = orb_color
    var gc: Color = secondary_color

    draw_circle(center + Vector2(0, -base * 1.7), base * 0.65, Color(0, 0, 0, 0.95))
    draw_arc(center + Vector2(0, -base * 1.7), base * 0.72, 0.0, TAU, 96, Color(1, 1, 1, 0.9), 3.0, true)

    draw_line(center + Vector2(0, -base * 1.05), center + Vector2(0, base * 0.72), Color(0, 0, 0, 0.95), base * 0.28)
    draw_line(center + Vector2(-base * 0.55, -base * 0.42), center + Vector2(base * 0.55, -base * 0.42), Color(gc.r, gc.g, gc.b, 0.75), 3.0)

    var crystal: PackedVector2Array = PackedVector2Array([
        center + Vector2(0, -base * 0.78),
        center + Vector2(base * 0.26, -base * 0.38),
        center + Vector2(0, base * 0.02),
        center + Vector2(-base * 0.26, -base * 0.38)
    ])

    draw_colored_polygon(crystal, Color(gc.r, gc.g, gc.b, 0.95))
    draw_circle(center + Vector2(0, -base * 0.38), base * 0.14, Color(1, 1, 1, 0.85))
