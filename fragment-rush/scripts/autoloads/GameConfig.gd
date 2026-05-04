extends Node
## GameConfig.gd - Configurações centrais do Fragment Rush.
## Nesta etapa, o arquivo concentra constantes antes mantidas no Main.gd.
## Não possui lógica de gameplay.

const LANES: Array[float] = [-230.0, 0.0, 230.0]
const PLAYER_Y: float = 960.0
const VIEW_W: float = 720.0
const VIEW_H: float = 1280.0

# Wuxia Color Palette
const C_BG_DEEP: Color    = Color(0.010, 0.036, 0.016, 1.0)
const C_BG_MID: Color     = Color(0.018, 0.060, 0.028, 1.0)
const C_JADE: Color       = Color(0.180, 0.840, 0.400, 1.0)
const C_JADE_SOFT: Color  = Color(0.260, 0.920, 0.500, 1.0)
const C_MIST: Color       = Color(0.160, 0.520, 0.340, 1.0)
const C_BAMBOO: Color     = Color(0.060, 0.220, 0.090, 1.0)
const C_GOLD: Color       = Color(1.000, 0.851, 0.502, 1.0)
const C_LANTERN: Color    = Color(0.950, 0.290, 0.090, 1.0)
const C_PEARL: Color      = Color(0.880, 0.980, 0.900, 1.0)
const C_ENERGY: Color     = Color(0.300, 0.900, 0.580, 1.0)
const C_VIOLET: Color     = Color(0.541, 0.361, 1.000, 1.0)
const C_RUBY: Color       = Color(0.950, 0.250, 0.180, 1.0)
const C_SHADOW: Color     = Color(0.060, 0.020, 0.120, 1.0)
const C_PANEL: Color      = Color(0.020, 0.075, 0.032, 0.78)

# ── Skins ─────────────────────────────────────────────────────────────────────
const SKINS: Dictionary = {
	"nucleo_errante":      {"name": "Corredor Inicial",     "price": 0,     "desc": "O iniciante do caminho marcial."},
	"semente_jade":        {"name": "Corredor de Jade",     "price": 1000,  "desc": "Flui com a energia da jade pura."},
	"corredor_rubi":       {"name": "Corredor Rubi",        "price": 2200,  "desc": "Chamas marciais do coração ardente."},
	"coracao_nebular":     {"name": "Corredor Nebular",     "price": 3800,  "desc": "Mistério estelar condensado em forma."},
	"essencia_dourada":    {"name": "Corredor Dourado",     "price": 6000,  "desc": "Ascensão dourada do espírito marcial."},
	"corredor_sombrio":    {"name": "Corredor Sombrio",     "price": 9000,  "desc": "As sombras do bambu na lua cheia."},
	"corredor_celestial":  {"name": "Corredor Celestial",   "price": 13000, "desc": "Toca os véus do paraíso espiritual."},
	"corredor_fragmentado":{"name": "Corredor Fragmentado", "price": 18000, "desc": "Além do tempo e do espaço marcial."}
}

# ── Técnicas ──────────────────────────────────────────────────────────────────
const TECHNIQUES: Dictionary = {
	"dash": {"name": "Passo Relâmpago", "max": 5, "base_price": 650,  "desc": "Reduz a recarga do dash."},
	"jade": {"name": "Toque de Jade",   "max": 5, "base_price": 800,  "desc": "Aumenta a duração do ímã."},
	"flow": {"name": "Estado de Fluxo", "max": 5, "base_price": 1000, "desc": "Aumenta a duração do fluxo espiritual."}
}

# ── Estágios de Cultivo ───────────────────────────────────────────────────────
const CULTIVATION_STAGES: Array[String] = [
	"Aprendiz Marcial",
	"Praticante de Qi",
	"Guerreiro de Jade",
	"Mestre do Fluxo",
	"Ascendido Espiritual"
]

# ── Círculos de Ressonância ────────────────────────────────────────────────────
const RESONANCE_CIRCLES: Array = [
	{"name": "Círculo do Bambu",    "xp": 500,   "color": Color(0.180, 0.840, 0.400, 1.0), "effect": "+Ressonância ao coletar cristais"},
	{"name": "Círculo da Jade",     "xp": 1400,  "color": Color(0.260, 0.920, 0.500, 1.0), "effect": "+Alcance do Toque de Jade"},
	{"name": "Círculo Nebular",     "xp": 3000,  "color": Color(0.541, 0.361, 1.000, 1.0), "effect": "+Bônus em Fluxo Perfeito"},
	{"name": "Círculo Dourado",     "xp": 6000,  "color": Color(1.000, 0.851, 0.502, 1.0), "effect": "+Valor dos Cristais Raros"},
	{"name": "Círculo Celestial",   "xp": 10000, "color": Color(0.880, 0.980, 0.900, 1.0), "effect": "+Duração do Estado de Fluxo"}
]

# ── Biomas Wuxia ──────────────────────────────────────────────────────────────
const BIOMES: Array = [
	{"name": "Floresta de Bambu Noturna", "at": 0.0,    "deep": Color(0.010, 0.036, 0.016, 1.0), "mist": Color(0.018, 0.065, 0.030, 1.0), "accent": Color(0.180, 0.840, 0.400, 1.0), "secondary": Color(0.260, 0.920, 0.500, 1.0)},
	{"name": "Ponte Suspensa na Névoa",   "at": 600.0,  "deep": Color(0.014, 0.042, 0.040, 1.0), "mist": Color(0.025, 0.085, 0.075, 1.0), "accent": Color(0.200, 0.860, 0.600, 1.0), "secondary": Color(0.300, 0.900, 0.700, 1.0)},
	{"name": "Vale Espiritual de Jade",   "at": 1300.0, "deep": Color(0.010, 0.055, 0.025, 1.0), "mist": Color(0.020, 0.100, 0.048, 1.0), "accent": Color(0.200, 0.950, 0.450, 1.0), "secondary": Color(0.320, 0.980, 0.560, 1.0)},
	{"name": "Ruínas do Pavilhão Antigo", "at": 2200.0, "deep": Color(0.035, 0.038, 0.015, 1.0), "mist": Color(0.075, 0.070, 0.025, 1.0), "accent": Color(0.880, 0.780, 0.300, 1.0), "secondary": Color(0.950, 0.290, 0.090, 1.0)},
	{"name": "Penhascos com Lanternas",   "at": 3300.0, "deep": Color(0.012, 0.020, 0.040, 1.0), "mist": Color(0.025, 0.040, 0.090, 1.0), "accent": Color(0.950, 0.290, 0.090, 1.0), "secondary": Color(1.000, 0.851, 0.502, 1.0)},
	{"name": "Templo Esquecido",          "at": 4500.0, "deep": Color(0.030, 0.010, 0.048, 1.0), "mist": Color(0.060, 0.020, 0.095, 1.0), "accent": Color(0.880, 0.980, 0.900, 1.0), "secondary": Color(0.541, 0.361, 1.000, 1.0)}
]

# ── Missões ───────────────────────────────────────────────────────────────────
const MISSIONS: Array = [
	{"id": "collect_50",   "text": "Coletar 50 cristais",       "goal": 50,  "reward": 80},
	{"id": "survive_60",   "text": "Sobreviver 60 segundos",     "goal": 60,  "reward": 120},
	{"id": "combo_10",     "text": "Fazer combo x10",            "goal": 10,  "reward": 100},
	{"id": "use_dash_5",   "text": "Usar dash 5 vezes",          "goal": 5,   "reward": 60},
	{"id": "rare_3",       "text": "Coletar 3 cristais raros",   "goal": 3,   "reward": 150},
	{"id": "play_3",       "text": "Jogar 3 partidas",           "goal": 3,   "reward": 70},
	{"id": "beat_record",  "text": "Bater o recorde",            "goal": 1,   "reward": 200}
]

# ── Crystal rarities ──────────────────────────────────────────────────────────
const CRYSTAL_TYPES: Array = [
	{"id": "common",    "weight": 60, "value": 1,  "color": Color(0.220, 0.920, 0.560, 1.0), "glow": Color(0.160, 0.720, 0.440, 1.0), "size": 16.0, "label": "Cristal"},
	{"id": "rare",      "weight": 26, "value": 3,  "color": Color(0.200, 0.840, 0.400, 1.0), "glow": Color(0.300, 0.980, 0.540, 1.0), "size": 20.0, "label": "Jade"},
	{"id": "epic",      "weight": 11, "value": 8,  "color": Color(0.541, 0.361, 1.000, 1.0), "glow": Color(0.700, 0.500, 1.000, 1.0), "size": 24.0, "label": "Nebular"},
	{"id": "legendary", "weight": 3,  "value": 20, "color": Color(1.000, 0.851, 0.502, 1.0), "glow": Color(1.000, 0.950, 0.650, 1.0), "size": 28.0, "label": "Lendário"}
]
