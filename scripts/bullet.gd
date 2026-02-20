extends Node3D

const SPEED := 22.0

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.0)
	mat.emission_energy_multiplier = 3.0

	var mesh_inst := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.06
	cm.bottom_radius = 0.06
	cm.height = 0.45
	mesh_inst.mesh = cm
	mesh_inst.material_override = mat
	mesh_inst.rotation_degrees = Vector3(90, 0, 0)
	add_child(mesh_inst)

func _process(delta: float) -> void:
	position.z -= SPEED * delta
	if position.z < -30.0:
		queue_free()

func get_hitbox_half() -> Vector3:
	return Vector3(0.15, 0.15, 0.25)
