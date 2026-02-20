extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	enemy_type = EnemyType.BOAT
	points = 30
	health = 1
	move_speed = 3.0
	hitbox_half = Vector3(0.85, 0.25, 0.55)
	super._ready()

func _build_visual() -> void:
	# Hull
	var hull := _make_mesh(Vector3(1.7, 0.32, 1.1), Color(0.55, 0.27, 0.07))
	add_child(hull)

	# Cabin
	var cabin := _make_mesh(Vector3(0.7, 0.4, 0.55), Color(0.65, 0.35, 0.12))
	cabin.position = Vector3(0.0, 0.36, -0.15)
	add_child(cabin)

	# Windshield (blue tint)
	var glass := _make_mesh(Vector3(0.55, 0.22, 0.08), Color(0.3, 0.5, 0.8))
	glass.position = Vector3(0.0, 0.45, -0.43)
	add_child(glass)
