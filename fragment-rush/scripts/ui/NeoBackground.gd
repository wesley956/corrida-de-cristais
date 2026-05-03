extends Control
class_name NeoBackground

@export var accent: Color = FragmentUiTheme.JADE
@export var secondary: Color = FragmentUiTheme.CYAN
@export var intensity: float = 1.0
@export var biome: String = "bamboo"

var t: float = 0.0

var sky_tex: Texture2D = null
var mountains_tex: Texture2D = null
var mid_tex: Texture2D = null
var front_tex: Texture2D = null
var fog_tex: Texture2D = null

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _load_backgrounds()
    set_process(true)

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func set_biome(next_biome: String) -> void:
    biome = next_biome
    _load_backgrounds()
    queue_redraw()

func _load_texture_direct(path: String) -> Texture2D:
    var tex: Texture2D = load(path) as Texture2D

    if tex == null:
        push_warning("Background PNG nao carregou: " + path)

    return tex

func _load_backgrounds() -> void:
    var base_path: String = "res://assets/backgrounds/%s/" % biome

    sky_tex = _load_texture_direct(base_path + "sky.png")
    mountains_tex = _load_texture_direct(base_path + "mountains.png")
    mid_tex = _load_texture_direct(base_path + "mid.png")
    front_tex = _load_texture_direct(base_path + "front.png")
    fog_tex = _load_texture_direct(base_path + "fog.png")

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y

    if w <= 0.0 or h <= 0.0:
        return

    _draw_fallback_gradient(w, h)

    _draw_cover_layer(sky_tex, Vector2.ZERO, 1.0)
    _draw_cover_layer(mountains_tex, Vector2(0, sin(t * 0.16) * 7.0), 0.86)
    _draw_cover_layer(mid_tex, Vector2(0, fmod(t * 4.0, 32.0)), 0.88)

    _draw_energy_glow(w, h)

    _draw_cover_layer(front_tex, Vector2(0, fmod(t * 8.0, 46.0)), 0.96)
    _draw_cover_layer(fog_tex, Vector2(sin(t * 0.22) * 18.0, fmod(t * 3.6, 38.0)), 0.56)

    _draw_vignette(w, h)

func _draw_fallback_gradient(w: float, h: float) -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.004, 0.018, 0.010, 1.0))

    for y: int in range(0, int(h), 64):
        var f: float = float(y) / maxf(h, 1.0)
        var c: Color = Color(0.004, 0.022 + f * 0.050, 0.012 + f * 0.030, 1.0)
        draw_rect(Rect2(0, y, w, 66), c)

func _draw_cover_layer(tex: Texture2D, offset: Vector2, alpha: float) -> void:
    if tex == null:
        return

    var tw: float = float(tex.get_width())
    var th: float = float(tex.get_height())

    if tw <= 0.0 or th <= 0.0:
        return

    var scale_factor: float = maxf(size.x / tw, size.y / th)
    var draw_size: Vector2 = Vector2(tw, th) * scale_factor
    var pos: Vector2 = (size - draw_size) * 0.5 + offset

    if pos.y > 0.0:
        pos.y = 0.0

    if pos.x > 0.0:
        pos.x = 0.0

    draw_texture_rect(tex, Rect2(pos, draw_size), false, Color(1, 1, 1, alpha))

func _draw_energy_glow(w: float, h: float) -> void:
    draw_circle(Vector2(w * 0.5, h * 0.30), w * 0.52, Color(accent.r, accent.g, accent.b, 0.045 * intensity))
    draw_circle(Vector2(w * 0.5, h * 0.72), w * 0.68, Color(secondary.r, secondary.g, secondary.b, 0.024 * intensity))

    for i: int in range(5):
        var r: float = 110.0 + float(i) * 42.0 + sin(t * 0.45 + float(i)) * 7.0
        var start: float = t * 0.12 + float(i) * 0.58
        draw_arc(Vector2(w * 0.5, h * 0.30), r, start, start + PI * 1.06, 96, Color(accent.r, accent.g, accent.b, 0.026 * intensity), 1.4, true)

func _draw_vignette(w: float, h: float) -> void:
    draw_rect(Rect2(0, 0, w, 130), Color(0, 0, 0, 0.25))
    draw_rect(Rect2(0, h - 210, w, 210), Color(0, 0, 0, 0.34))
    draw_rect(Rect2(0, 0, 62, h), Color(0, 0, 0, 0.22))
    draw_rect(Rect2(w - 62, 0, 62, h), Color(0, 0, 0, 0.22))
