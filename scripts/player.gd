extends Node3D

signal shoot_bullet(position: Vector3)
signal died

const MOVE_SPEED := 8.0
const PLAYER_Z := 8.0
const PLAYER_Y := 1.5

var shoot_cooldown := 0.22
var shoot_timer := 0.0
var is_dead := false
var _hit_flash_timer := 0.0
var _dir: float = 0.0

func _ready() -> void:
	position = Vector3(0.0, PLAYER_Y, PLAYER_Z)
	_build_model()

func _build_model() -> void:
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.88, 0.88, 0.90)
	white.roughness = 0.4
	white.metallic = 0.2

	var grey := StandardMaterial3D.new()
	grey.albedo_color = Color(0.55, 0.55, 0.60)
	grey.roughness = 0.5

	var engine_mat := StandardMaterial3D.new()
	engine_mat.albedo_color = Color(0.2, 0.2, 0.25)
	engine_mat.metallic = 0.6

	# Fuselage
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.35, 0.18, 1.4)
	body.mesh = bm
	body.material_override = white
	add_child(body)

	# Left wing
	var lwing := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(1.8, 0.07, 0.65)
	lwing.mesh = lm
	lwing.material_override = white
	lwing.position = Vector3(-1.07, 0.0, 0.1)
	add_child(lwing)

	# Right wing
	var rwing := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(1.8, 0.07, 0.65)
	rwing.mesh = rm
	rwing.material_override = white
	rwing.position = Vector3(1.07, 0.0, 0.1)
	add_child(rwing)

	# Tail fin
	var tail := MeshInstance3D.new()
	var tm := BoxMesh.new()
	tm.size = Vector3(0.55, 0.3, 0.3)
	tail.mesh = tm
	tail.material_override = grey
	tail.position = Vector3(0.0, 0.15, 0.65)
	add_child(tail)

	# Nose cone
	var nose := MeshInstance3D.new()
	var nm := CylinderMesh.new()
	nm.top_radius = 0.07
	nm.bottom_radius = 0.14
	nm.height = 0.3
	nose.mesh = nm
	nose.material_override = engine_mat
	nose.position = Vector3(0.0, 0.0, -0.85)
	nose.rotation_degrees = Vector3(90, 0, 0)
	add_child(nose)

func _process(delta: float) -> void:
	if is_dead:
		return

	_dir = 0.0
	if Input.is_action_pressed("move_left"):
		_dir = -1.0
	elif Input.is_action_pressed("move_right"):
		_dir = 1.0

	position.x += _dir * MOVE_SPEED * delta
	position.x = clamp(position.x, -12.0, 12.0)

	# Banking effect
	rotation.z = lerp(rotation.z, -_dir * 0.25, delta * 6.0)

	# Shoot
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		shoot_bullet.emit(position + Vector3(0.0, 0.0, -1.0))

	# Hit flash — toggle visibility (Node3D nie ma modulate)
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		visible = fmod(_hit_flash_timer * 10.0, 2.0) > 1.0
	else:
		visible = true

func get_speed_ratio() -> float:
	if Input.is_action_pressed("move_up"):
		return 1.4
	elif Input.is_action_pressed("move_down"):
		return 0.5
	return 1.0

func get_hitbox_half() -> Vector3:
	return Vector3(1.8, 0.4, 0.7)

func trigger_death() -> void:
	if is_dead or _hit_flash_timer > 0.0:
		return
	_hit_flash_timer = 1.5
	died.emit()
