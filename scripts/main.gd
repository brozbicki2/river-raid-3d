extends Node3D

const BASE_SCROLL_SPEED := 6.0

enum GameState { TITLE, PLAYING, DEAD, GAME_OVER }
var state: GameState = GameState.TITLE

var score: int = 0
var lives: int = 3
var fuel: float = 100.0
const FUEL_MAX: float = 100.0
const FUEL_DRAIN_BASE: float = 5.0
const EXTRA_LIFE_SCORE: int = 10000
var next_extra_life: int = 10000

var death_timer: float = 0.0
const DEATH_DELAY: float = 1.8

var _scroll_offset: float = 0.0

var river_gen: Node3D
var player: Node3D
var spawner: Node
var hud: CanvasLayer
var camera: Camera3D

var bullets: Array = []

func _ready() -> void:
	_setup_world()
	_setup_nodes()
	hud.show_title()

func _setup_world() -> void:
	# Camera
	camera = Camera3D.new()
	camera.position = Vector3(0.0, 12.0, 20.0)
	camera.look_at(Vector3(0.0, 0.0, 5.0))
	camera.fov = 65.0
	add_child(camera)

	# Directional light (sun)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, 30, 0)
	light.light_color = Color(1.0, 0.97, 0.90)
	light.light_energy = 1.3
	light.shadow_enabled = true
	add_child(light)

	# Ambient / world environment
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.18, 0.45, 0.80)
	sky_mat.sky_horizon_color = Color(0.55, 0.75, 0.92)
	sky_mat.ground_bottom_color = Color(0.15, 0.30, 0.10)
	sky_mat.ground_horizon_color = Color(0.30, 0.55, 0.20)
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.5
	environment.fog_enabled = true
	environment.fog_density = 0.008
	environment.fog_aerial_perspective = 0.3
	env.environment = environment
	add_child(env)

func _setup_nodes() -> void:
	# River
	river_gen = Node3D.new()
	river_gen.set_script(preload("res://scripts/river_generator.gd"))
	add_child(river_gen)

	# Player
	player = Node3D.new()
	player.set_script(preload("res://scripts/player.gd"))
	player.shoot_bullet.connect(_on_shoot_bullet)
	player.died.connect(_on_player_died)
	add_child(player)

	# Spawner
	spawner = Node.new()
	spawner.set_script(preload("res://scripts/enemy_spawner.gd"))
	spawner.river_generator = river_gen
	spawner.enemy_destroyed.connect(_on_enemy_destroyed)
	spawner.bridge_destroyed.connect(_on_bridge_destroyed)
	add_child(spawner)

	# HUD (CanvasLayer — works over 3D)
	hud = CanvasLayer.new()
	hud.set_script(preload("res://scripts/hud.gd"))
	add_child(hud)

func _start_game() -> void:
	state = GameState.PLAYING
	score = 0
	lives = 3
	fuel = FUEL_MAX
	next_extra_life = EXTRA_LIFE_SCORE
	hud.hide_title()
	hud.hide_game_over()
	hud.update_score(0)
	hud.update_lives(3)
	hud.update_fuel(1.0)
	player.position = Vector3(0.0, 1.5, 8.0)
	player.is_dead = false
	player.visible = true

func _process(delta: float) -> void:
	match state:
		GameState.TITLE:
			if Input.is_action_just_pressed("shoot"):
				_start_game()

		GameState.PLAYING:
			_update_game(delta)

		GameState.DEAD:
			death_timer -= delta
			if death_timer <= 0.0:
				_respawn()

		GameState.GAME_OVER:
			if Input.is_action_just_pressed("shoot"):
				_start_game()

func _update_game(delta: float) -> void:
	var speed_ratio: float = player.get_speed_ratio()
	var current_scroll: float = BASE_SCROLL_SPEED * speed_ratio
	river_gen.scroll_speed = current_scroll
	spawner.update_scroll_speed(current_scroll)
	_scroll_offset += current_scroll * delta

	# Fuel drain
	fuel -= FUEL_DRAIN_BASE * speed_ratio * delta
	fuel = max(0.0, fuel)
	hud.update_fuel(fuel / FUEL_MAX)

	if fuel <= 0.0:
		_on_player_died()
		return

	_check_bank_collision()
	_check_enemy_collisions()
	_check_bullet_collisions()
	_check_fuel_refueling(speed_ratio, delta)

	bullets = bullets.filter(func(b): return is_instance_valid(b))

# --- Collision helpers ---

func _aabb(a_pos: Vector3, b_pos: Vector3, a_h: Vector3, b_h: Vector3) -> bool:
	return (abs(a_pos.x - b_pos.x) < a_h.x + b_h.x and
			abs(a_pos.z - b_pos.z) < a_h.z + b_h.z)

func _check_bank_collision() -> void:
	var px: float = player.position.x
	var bounds: Vector2 = river_gen.get_river_bounds_at_z(player.position.z)
	if px < bounds.x - 0.3 or px > bounds.y + 0.3:
		_on_player_died()

func _check_enemy_collisions() -> void:
	var p_pos: Vector3 = player.position
	var p_h: Vector3 = player.get_hitbox_half()
	for enemy in spawner.get_enemies():
		if not is_instance_valid(enemy) or enemy.is_destroyed:
			continue
		if _aabb(p_pos, enemy.position, p_h, enemy.hitbox_half):
			_on_player_died()
			return

func _check_bullet_collisions() -> void:
	for bullet in bullets:
		if not is_instance_valid(bullet):
			continue
		var b_pos: Vector3 = bullet.position
		var b_h: Vector3 = bullet.get_hitbox_half()
		for enemy in spawner.get_enemies():
			if not is_instance_valid(enemy) or enemy.is_destroyed:
				continue
			if _aabb(b_pos, enemy.position, b_h, enemy.hitbox_half):
				enemy.take_hit()
				if is_instance_valid(bullet):
					bullet.queue_free()
				break

func _check_fuel_refueling(speed_ratio: float, delta: float) -> void:
	var p_pos: Vector3 = player.position
	for enemy in spawner.get_enemies():
		if not is_instance_valid(enemy) or enemy.is_destroyed or not enemy.is_fuel_depot:
			continue
		if "get_refuel_half" in enemy:
			var f_h: Vector3 = enemy.get_refuel_half()
			if _aabb(p_pos, enemy.position, Vector3(1.0, 1.0, 1.0), f_h):
				var refuel_amount: float = enemy.refuel_rate * (1.5 - speed_ratio) * delta
				fuel = min(FUEL_MAX, fuel + max(0.0, refuel_amount))

# --- Events ---

func _on_shoot_bullet(pos: Vector3) -> void:
	if state != GameState.PLAYING:
		return
	var b := Node3D.new()
	b.set_script(preload("res://scripts/bullet.gd"))
	b.position = pos
	add_child(b)
	bullets.append(b)

func _on_enemy_destroyed(pos: Vector3, pts: int) -> void:
	score += pts
	hud.update_score(score)
	_spawn_explosion(pos)
	if score >= next_extra_life:
		next_extra_life += EXTRA_LIFE_SCORE
		lives = min(9, lives + 1)
		hud.update_lives(lives)

func _on_bridge_destroyed() -> void:
	pass  # checkpoint stored implicitly by spawner

func _on_player_died() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.DEAD
	death_timer = DEATH_DELAY
	player.is_dead = true
	player.visible = false
	_spawn_explosion(player.position)
	lives -= 1
	hud.update_lives(lives)

func _respawn() -> void:
	if lives <= 0:
		state = GameState.GAME_OVER
		hud.show_game_over(score)
		return
	state = GameState.PLAYING
	fuel = FUEL_MAX
	player.is_dead = false
	player.visible = true
	player._hit_flash_timer = 0.0
	player.position = Vector3(0.0, 1.5, 8.0)
	hud.update_fuel(1.0)

func _spawn_explosion(pos: Vector3) -> void:
	var exp := Node3D.new()
	exp.set_script(preload("res://scripts/explosion.gd"))
	exp.position = pos
	add_child(exp)
