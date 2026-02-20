extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	enemy_type = EnemyType.TANKER
	points = 30
	health = 1
	move_speed = 2.5
	hitbox_half = Vector3(0.9, 0.3, 0.65)
	super._ready()

func _build_visual() -> void:
	# Hull
	var hull := _make_mesh(Vector3(1.8, 0.4, 1.3), Color(0.53, 0.53, 0.53))
	add_child(hull)

	# Deck superstructure
	var deck := _make_mesh(Vector3(0.9, 0.25, 0.7), Color(0.35, 0.35, 0.38))
	deck.position = Vector3(0.0, 0.33, -0.1)
	add_child(deck)

	# Smokestack
	var stack := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.09
	cm.bottom_radius = 0.12
	cm.height = 0.35
	stack.mesh = cm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.22, 0.22)
	stack.material_override = mat
	stack.position = Vector3(0.0, 0.55, -0.1)
	add_child(stack)
