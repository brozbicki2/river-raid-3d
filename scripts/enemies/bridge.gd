extends "res://scripts/enemy_base.gd"

const MAX_HEALTH := 3
var _bridge_width: float = 13.0

func _ready() -> void:
	enemy_type = EnemyType.BRIDGE
	points = 500
	health = MAX_HEALTH
	move_speed = 0.0
	hitbox_half = Vector3(7.0, 0.3, 0.8)
	super._ready()

func _build_visual() -> void:
	_build_bridge(_bridge_width)

func set_width(river_width: float) -> void:
	_bridge_width = river_width
	hitbox_half.x = river_width * 0.5
	for child in get_children():
		child.queue_free()
	_build_bridge(river_width)

func _build_bridge(width: float) -> void:
	# Main deck
	var deck := _make_mesh(Vector3(width, 0.28, 1.4), Color(0.55, 0.55, 0.60))
	deck.position = Vector3(0.0, 0.0, 0.0)
	add_child(deck)

	# Road surface (slightly lighter)
	var road := _make_mesh(Vector3(width * 0.6, 0.05, 1.35), Color(0.42, 0.42, 0.45))
	road.position = Vector3(0.0, 0.17, 0.0)
	add_child(road)

	# Pillars
	var num_pillars := int(width / 3.5) + 1
	for i in range(num_pillars):
		var px: float = -width * 0.5 + (width / float(num_pillars - 1 if num_pillars > 1 else 1)) * i
		var pillar := _make_mesh(Vector3(0.3, 1.2, 0.3), Color(0.45, 0.45, 0.50))
		pillar.position = Vector3(px, -0.6, 0.0)
		add_child(pillar)

	# Railing left/right
	var rail_mat := StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.6, 0.6, 0.65)
	for side in [-1, 1]:
		var rail := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(width, 0.15, 0.12)
		rail.mesh = rm
		rail.material_override = rail_mat
		rail.position = Vector3(0.0, 0.22, side * 0.65)
		add_child(rail)

func _move(_delta: float) -> void:
	pass

func take_hit() -> void:
	if is_destroyed:
		return
	health -= 1
	_hit_flash_timer = 0.2
	if health <= 0:
		_on_destroyed()
