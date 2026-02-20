extends Node3D

enum EnemyType { TANKER, HELICOPTER, BOAT, JET, FUEL_DEPOT, BRIDGE }

var enemy_type: EnemyType = EnemyType.TANKER
var points: int = 30
var health: int = 1
var move_speed: float = 3.0
var move_dir: float = 1.0

# River bounds in X (set by spawner)
var left_bound: float = -6.0
var right_bound: float = 6.0

var is_destroyed := false
var scroll_speed: float = 6.0
var is_fuel_depot := false
var refuel_rate: float = 30.0
var _hit_flash_timer: float = 0.0

# Hitbox half-extents (override per enemy)
var hitbox_half := Vector3(0.9, 0.3, 0.6)

signal destroyed(pos: Vector3, pts: int)

func _ready() -> void:
	_build_visual()

func _build_visual() -> void:
	pass  # Override in subclasses

func _process(delta: float) -> void:
	if is_destroyed:
		return

	# Scroll with river (+Z toward camera)
	position.z += scroll_speed * delta

	_move(delta)

	# Remove when past camera
	if position.z > 22.0:
		queue_free()

	# Hit flash
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		visible = fmod(_hit_flash_timer * 20.0, 2.0) > 1.0
	else:
		visible = true

func _move(delta: float) -> void:
	position.x += move_speed * move_dir * delta
	if position.x <= left_bound + 0.5:
		move_dir = 1.0
	elif position.x >= right_bound - 0.5:
		move_dir = -1.0

func _make_mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	mi.material_override = mat
	return mi

func take_hit() -> void:
	if is_destroyed:
		return
	health -= 1
	_hit_flash_timer = 0.2
	if health <= 0:
		_on_destroyed()

func _on_destroyed() -> void:
	is_destroyed = true
	destroyed.emit(position, points)
	queue_free()
