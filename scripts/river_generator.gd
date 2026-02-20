extends Node3D

const CHUNK_DEPTH := 30.0
const WORLD_HALF_WIDTH := 14.0
const NUM_CHUNKS := 4

var scroll_speed: float = 6.0
var river_center_x: float = 0.0
var river_half_width: float = 6.5
const RIVER_MIN_HALF_WIDTH: float = 3.0
const CENTER_DRIFT: float = 1.5

var chunks: Array = []

var _mat_water: StandardMaterial3D
var _mat_bank: StandardMaterial3D
var _mat_bg: StandardMaterial3D
var _water_uv_offset: float = 0.0

func _ready() -> void:
	_create_materials()
	for i in range(NUM_CHUNKS):
		_spawn_chunk(-CHUNK_DEPTH * i)

func _create_materials() -> void:
	_mat_water = StandardMaterial3D.new()
	_mat_water.albedo_color = Color(0.11, 0.37, 0.80)
	_mat_water.roughness = 0.05
	_mat_water.metallic = 0.3
	_mat_water.uv1_scale = Vector3(2.0, 6.0, 1.0)

	_mat_bank = StandardMaterial3D.new()
	_mat_bank.albedo_color = Color(0.30, 0.68, 0.31)
	_mat_bank.roughness = 0.9

	_mat_bg = StandardMaterial3D.new()
	_mat_bg.albedo_color = Color(0.18, 0.35, 0.11)
	_mat_bg.roughness = 1.0

func _process(delta: float) -> void:
	_water_uv_offset += delta
	_mat_water.uv1_offset = Vector3(0.0, fmod(_water_uv_offset * 0.15, 1.0), 0.0)

	for chunk in chunks:
		chunk.position.z += scroll_speed * delta

	for chunk in chunks:
		if chunk.position.z > 20.0:
			var min_z: float = chunk.position.z
			for c in chunks:
				if c.position.z < min_z:
					min_z = c.position.z
			_reconfigure_chunk(chunk, min_z - CHUNK_DEPTH)

func _spawn_chunk(z_pos: float) -> void:
	var chunk := Node3D.new()
	chunk.position = Vector3(0.0, 0.0, z_pos)

	var new_center: float = river_center_x + randf_range(-CENTER_DRIFT, CENTER_DRIFT)
	new_center = clamp(new_center, -WORLD_HALF_WIDTH + river_half_width + 1.5,
						WORLD_HALF_WIDTH - river_half_width - 1.5)
	river_center_x = new_center
	var left_x: float = new_center - river_half_width
	var right_x: float = new_center + river_half_width

	_build_chunk_meshes(chunk, new_center, left_x, right_x)
	chunk.set_meta("left_bank", left_x)
	chunk.set_meta("right_bank", right_x)

	add_child(chunk)
	chunks.append(chunk)

func _reconfigure_chunk(chunk: Node3D, new_z: float) -> void:
	chunk.position.z = new_z
	for child in chunk.get_children():
		child.queue_free()

	var new_center: float = river_center_x + randf_range(-CENTER_DRIFT, CENTER_DRIFT)
	new_center = clamp(new_center, -WORLD_HALF_WIDTH + river_half_width + 1.5,
						WORLD_HALF_WIDTH - river_half_width - 1.5)
	river_center_x = new_center
	var left_x: float = new_center - river_half_width
	var right_x: float = new_center + river_half_width

	_build_chunk_meshes(chunk, new_center, left_x, right_x)
	chunk.set_meta("left_bank", left_x)
	chunk.set_meta("right_bank", right_x)

func _build_chunk_meshes(chunk: Node3D, center_x: float, left_x: float, right_x: float) -> void:
	var half_z: float = CHUNK_DEPTH / 2.0

	# Background terrain
	var bg := MeshInstance3D.new()
	var bg_mesh := PlaneMesh.new()
	bg_mesh.size = Vector2(WORLD_HALF_WIDTH * 2.0, CHUNK_DEPTH)
	bg.mesh = bg_mesh
	bg.material_override = _mat_bg
	bg.position = Vector3(0.0, -0.02, -half_z)
	chunk.add_child(bg)

	# Water surface
	var water_width: float = right_x - left_x
	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(water_width, CHUNK_DEPTH)
	water.mesh = water_mesh
	water.material_override = _mat_water
	water.position = Vector3(center_x, 0.0, -half_z)
	chunk.add_child(water)

	# Left bank
	var l_width: float = WORLD_HALF_WIDTH + left_x
	if l_width > 0.1:
		var lbank := MeshInstance3D.new()
		var lm := BoxMesh.new()
		lm.size = Vector3(l_width, 0.5, CHUNK_DEPTH)
		lbank.mesh = lm
		lbank.material_override = _mat_bank
		lbank.position = Vector3(-WORLD_HALF_WIDTH + l_width * 0.5, 0.25, -half_z)
		chunk.add_child(lbank)

	# Right bank
	var r_width: float = WORLD_HALF_WIDTH - right_x
	if r_width > 0.1:
		var rbank := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(r_width, 0.5, CHUNK_DEPTH)
		rbank.mesh = rm
		rbank.material_override = _mat_bank
		rbank.position = Vector3(WORLD_HALF_WIDTH - r_width * 0.5, 0.25, -half_z)
		chunk.add_child(rbank)

func get_river_bounds_at_z(world_z: float) -> Vector2:
	for chunk in chunks:
		var chunk_front: float = chunk.position.z + CHUNK_DEPTH * 0.5
		var chunk_back: float = chunk.position.z - CHUNK_DEPTH * 0.5
		if world_z <= chunk_front and world_z >= chunk_back:
			var lb: float = chunk.get_meta("left_bank")
			var rb: float = chunk.get_meta("right_bank")
			return Vector2(lb, rb)
	return Vector2(-river_half_width, river_half_width)

func get_river_center() -> float:
	return river_center_x

func narrow_river(amount: float = 0.3) -> void:
	river_half_width = max(RIVER_MIN_HALF_WIDTH, river_half_width - amount)
