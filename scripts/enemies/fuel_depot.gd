extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	enemy_type = EnemyType.FUEL_DEPOT
	points = 80
	health = 1
	move_speed = 0.0
	is_fuel_depot = true
	hitbox_half = Vector3(0.7, 0.6, 0.7)
	super._ready()

func _build_visual() -> void:
	# Main tank (cylindrical look from boxes)
	var tank := _make_mesh(Vector3(1.0, 1.1, 1.0), Color(0.67, 0.80, 0.0))
	add_child(tank)

	# Stripe
	var stripe := _make_mesh(Vector3(1.02, 0.18, 1.02), Color(0.50, 0.62, 0.0))
	stripe.position = Vector3(0.0, 0.1, 0.0)
	add_child(stripe)

	# "F" indicator top (yellow dot)
	var top := _make_mesh(Vector3(0.3, 0.12, 0.3), Color(1.0, 1.0, 0.2))
	top.position = Vector3(0.0, 0.61, 0.0)
	add_child(top)

	# Pipe/connector
	var pipe := _make_mesh(Vector3(0.12, 0.12, 0.5), Color(0.4, 0.4, 0.4))
	pipe.position = Vector3(0.0, -0.25, -0.75)
	add_child(pipe)

func _move(_delta: float) -> void:
	pass  # Depot doesn't move

func get_refuel_half() -> Vector3:
	return Vector3(1.2, 1.0, 1.2)
