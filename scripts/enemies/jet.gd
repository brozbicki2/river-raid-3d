extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	enemy_type = EnemyType.JET
	points = 100
	health = 1
	move_speed = 9.0
	hitbox_half = Vector3(1.5, 0.2, 0.6)
	super._ready()

func _build_visual() -> void:
	# Fuselage
	var body := _make_mesh(Vector3(0.28, 0.2, 1.5), Color(0.80, 0.15, 0.15))
	add_child(body)

	# Wings
	var lwing := _make_mesh(Vector3(1.6, 0.06, 0.6), Color(0.70, 0.12, 0.12))
	lwing.position = Vector3(-1.0, 0.0, 0.15)
	add_child(lwing)

	var rwing := _make_mesh(Vector3(1.6, 0.06, 0.6), Color(0.70, 0.12, 0.12))
	rwing.position = Vector3(1.0, 0.0, 0.15)
	add_child(rwing)

	# Tail fins
	var ltail := _make_mesh(Vector3(0.5, 0.25, 0.25), Color(0.65, 0.10, 0.10))
	ltail.position = Vector3(-0.3, 0.12, 0.6)
	add_child(ltail)

	var rtail := _make_mesh(Vector3(0.5, 0.25, 0.25), Color(0.65, 0.10, 0.10))
	rtail.position = Vector3(0.3, 0.12, 0.6)
	add_child(rtail)

func _move(delta: float) -> void:
	# Jet crosses full world width and wraps
	position.x += move_speed * move_dir * delta
	if position.x < -16.0:
		position.x = 16.0
	elif position.x > 16.0:
		position.x = -16.0
