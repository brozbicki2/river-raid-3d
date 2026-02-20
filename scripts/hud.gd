extends CanvasLayer

var score_label: Label
var lives_label: Label
var fuel_bar_fill: ColorRect
var fuel_low_label: Label
var game_over_panel: Control
var game_over_score: Label
var title_panel: Control

const W := 640
const H := 480

func _ready() -> void:
	_build_hud()

func _build_hud() -> void:
	# Score
	score_label = Label.new()
	score_label.position = Vector2(8, 4)
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.text = "SCORE: 000000"
	add_child(score_label)

	# Lives
	lives_label = Label.new()
	lives_label.position = Vector2(W - 100, 4)
	lives_label.add_theme_font_size_override("font_size", 14)
	lives_label.add_theme_color_override("font_color", Color.WHITE)
	lives_label.text = "LIVES: 3"
	add_child(lives_label)

	# Fuel bar BG
	var fuel_lbl := Label.new()
	fuel_lbl.position = Vector2(8, H - 22)
	fuel_lbl.add_theme_font_size_override("font_size", 11)
	fuel_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	fuel_lbl.text = "FUEL"
	add_child(fuel_lbl)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.15, 0.15, 0.15)
	bar_bg.position = Vector2(50, H - 20)
	bar_bg.size = Vector2(W - 60, 12)
	add_child(bar_bg)

	fuel_bar_fill = ColorRect.new()
	fuel_bar_fill.color = Color(0.27, 1.0, 0.27)
	fuel_bar_fill.position = Vector2(50, H - 20)
	fuel_bar_fill.size = Vector2(W - 60, 12)
	add_child(fuel_bar_fill)

	fuel_low_label = Label.new()
	fuel_low_label.position = Vector2(W - 50, H - 24)
	fuel_low_label.add_theme_font_size_override("font_size", 12)
	fuel_low_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	fuel_low_label.text = "LOW!"
	fuel_low_label.visible = false
	add_child(fuel_low_label)

	# --- Title screen ---
	title_panel = _make_panel(Color(0, 0, 0, 0.75))
	title_panel.visible = true
	add_child(title_panel)

	var t1 := _make_label("RIVER RAID", 40, Color(1.0, 1.0, 0.2))
	t1.position = Vector2(W / 2.0 - 160, H / 2.0 - 80)
	title_panel.add_child(t1)

	var t2 := _make_label("PRESS SPACE TO START", 16, Color(0.7, 1.0, 0.7))
	t2.position = Vector2(W / 2.0 - 140, H / 2.0)
	title_panel.add_child(t2)

	var t3 := _make_label("A/D = MOVE   W/S = SPEED   SPACE = FIRE", 11, Color(0.6, 0.6, 0.6))
	t3.position = Vector2(W / 2.0 - 160, H / 2.0 + 40)
	title_panel.add_child(t3)

	# --- Game Over panel ---
	game_over_panel = _make_panel(Color(0, 0, 0, 0.80))
	game_over_panel.visible = false
	add_child(game_over_panel)

	var go_lbl := _make_label("GAME OVER", 36, Color(1.0, 0.2, 0.2))
	go_lbl.position = Vector2(W / 2.0 - 120, H / 2.0 - 70)
	game_over_panel.add_child(go_lbl)

	game_over_score = _make_label("SCORE: 000000", 18, Color.WHITE)
	game_over_score.position = Vector2(W / 2.0 - 80, H / 2.0 - 10)
	game_over_panel.add_child(game_over_score)

	var go_restart := _make_label("PRESS SPACE TO RESTART", 14, Color(0.7, 1.0, 0.7))
	go_restart.position = Vector2(W / 2.0 - 120, H / 2.0 + 30)
	game_over_panel.add_child(go_restart)

func _make_panel(color: Color) -> ColorRect:
	var p := ColorRect.new()
	p.color = color
	p.position = Vector2(0, 0)
	p.size = Vector2(W, H)
	return p

func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func update_score(score: int) -> void:
	score_label.text = "SCORE: %06d" % score

func update_lives(lives: int) -> void:
	lives_label.text = "LIVES: %d" % lives

func update_fuel(fuel_ratio: float) -> void:
	fuel_bar_fill.size.x = (W - 60) * clamp(fuel_ratio, 0.0, 1.0)
	if fuel_ratio > 0.5:
		fuel_bar_fill.color = Color(0.27, 1.0, 0.27)
	elif fuel_ratio > 0.25:
		fuel_bar_fill.color = Color(1.0, 1.0, 0.27)
	else:
		fuel_bar_fill.color = Color(1.0, 0.27, 0.27)
		fuel_low_label.visible = true
		fuel_low_label.modulate.a = 1.0 if fmod(Time.get_ticks_msec() / 300.0, 2.0) < 1.0 else 0.0

	if fuel_ratio > 0.25:
		fuel_low_label.visible = false

func show_title() -> void:
	title_panel.visible = true

func hide_title() -> void:
	title_panel.visible = false

func show_game_over(score: int) -> void:
	game_over_score.text = "SCORE: %06d" % score
	game_over_panel.visible = true

func hide_game_over() -> void:
	game_over_panel.visible = false
