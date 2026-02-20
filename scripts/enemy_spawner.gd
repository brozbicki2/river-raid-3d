extends Node

const TankerScript     := preload("res://scripts/enemies/tanker.gd")
const HelicopterScript := preload("res://scripts/enemies/helicopter.gd")
const JetScript        := preload("res://scripts/enemies/jet.gd")
const BoatScript       := preload("res://scripts/enemies/boat.gd")
const FuelDepotScript  := preload("res://scripts/enemies/fuel_depot.gd")
const BridgeScript     := preload("res://scripts/enemies/bridge.gd")

var scroll_speed: float = 6.0
var river_generator  # Node3D reference

var distance_traveled: float = 0.0
var next_spawn_distance: float = 8.0
var next_bridge_distance: float = 60.0

var difficulty: int = 0
var bridges_destroyed: int = 0

var enemies: Array = []

signal enemy_destroyed(pos: Vector3, pts: int)
signal bridge_destroyed

func _process(delta: float) -> void:
	distance_traveled += scroll_speed * delta

	if distance_traveled >= next_bridge_distance:
		_spawn_bridge()
		next_bridge_distance = distance_traveled + 55.0 + randf_range(0.0, 25.0)

	if distance_traveled >= next_spawn_distance:
		_spawn_random_enemy()
		next_spawn_distance = distance_traveled + _get_spawn_interval()

	enemies = enemies.filter(func(e): return is_instance_valid(e))

func _get_spawn_interval() -> float:
	var base: float = 9.0 - float(difficulty) * 0.7
	return max(3.5, base) + randf_range(-1.0, 1.0)

func _spawn_random_enemy() -> void:
	if not river_generator:
		return

	var bounds: Vector2 = river_generator.get_river_bounds_at_z(-15.0)
	var left_b: float = bounds.x
	var right_b: float = bounds.y

	if right_b - left_b < 2.0:
		return

	var roll: int = randi() % 100
	var enemy: Node3D

	if roll < 25:
		enemy = _make_enemy(TankerScript)
	elif roll < 45:
		enemy = _make_enemy(HelicopterScript)
	elif roll < 60:
		enemy = _make_enemy(BoatScript)
	elif roll < 75:
		enemy = _make_enemy(JetScript)
	else:
		enemy = _make_enemy(FuelDepotScript)

	if not enemy:
		return

	enemy.left_bound = left_b
	enemy.right_bound = right_b
	enemy.scroll_speed = scroll_speed
	enemy.position = Vector3(randf_range(left_b + 1.0, right_b - 1.0), 0.5, -18.0)
	enemy.move_dir = [-1.0, 1.0][randi() % 2]

	enemy.destroyed.connect(_on_enemy_destroyed)
	get_parent().add_child(enemy)
	enemies.append(enemy)

func _spawn_bridge() -> void:
	if not river_generator:
		return

	var bounds: Vector2 = river_generator.get_river_bounds_at_z(-15.0)
	var center_x: float = (bounds.x + bounds.y) / 2.0
	var river_width: float = bounds.y - bounds.x + 1.0

	var bridge: Node3D = Node3D.new()
	bridge.set_script(BridgeScript)
	bridge.position = Vector3(center_x, 0.3, -20.0)
	bridge.scroll_speed = scroll_speed

	bridge.destroyed.connect(_on_bridge_destroyed)
	get_parent().add_child(bridge)
	enemies.append(bridge)

	bridge.set_width(river_width)

func _make_enemy(script: Script) -> Node3D:
	var e := Node3D.new()
	e.set_script(script)
	return e

func _on_enemy_destroyed(pos: Vector3, pts: int) -> void:
	enemy_destroyed.emit(pos, pts)

func _on_bridge_destroyed() -> void:
	bridges_destroyed += 1
	bridge_destroyed.emit()
	difficulty = min(difficulty + 1, 10)
	if river_generator:
		river_generator.narrow_river(0.3)
	scroll_speed = min(14.0, scroll_speed + 0.5)
	for e in enemies:
		if is_instance_valid(e):
			e.scroll_speed = scroll_speed

func update_scroll_speed(spd: float) -> void:
	scroll_speed = spd
	for e in enemies:
		if is_instance_valid(e):
			e.scroll_speed = spd

func get_enemies() -> Array:
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	return enemies
