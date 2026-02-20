extends "res://scripts/enemy_base.gd"

var _rotor_node: Node3D
var _rotor_timer := 0.0

func _ready() -> void:
	enemy_type = EnemyType.HELICOPTER
	points = 60
	health = 1
	move_speed = 4.0
	hitbox_half = Vector3(0.8, 0.4, 0.6)
	super._ready()

func _build_visual() -> void:
	# Body
	var body := _make_mesh(Vector3(1.2, 0.55, 0.85), Color(0.80, 0.68, 0.0))
	add_child(body)

	# Tail boom
	var tail := _make_mesh(Vector3(0.18, 0.18, 0.9), Color(0.65, 0.55, 0.0))
	tail.position = Vector3(0.0, 0.05, 0.87)
	add_child(tail)

	# Tail rotor
	var tail_rot := _make_mesh(Vector3(0.05, 0.5, 0.05), Color(0.3, 0.3, 0.3))
	tail_rot.position = Vector3(0.12, 0.05, 1.3)
	add_child(tail_rot)

	# Main rotor hub
	_rotor_node = Node3D.new()
	_rotor_node.position = Vector3(0.0, 0.42, 0.0)
	add_child(_rotor_node)

	var blade1 := _make_mesh(Vector3(2.2, 0.04, 0.14), Color(0.25, 0.25, 0.25))
	_rotor_node.add_child(blade1)

	var blade2 := _make_mesh(Vector3(0.14, 0.04, 2.2), Color(0.25, 0.25, 0.25))
	_rotor_node.add_child(blade2)

func _process(delta: float) -> void:
	super._process(delta)
	if _rotor_node and not is_destroyed:
		_rotor_node.rotation.y += delta * 12.0
