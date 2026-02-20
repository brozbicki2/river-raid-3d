extends Node3D

var _particles: Array = []
var _materials: Array = []
var _velocities: Array = []
var _timer: float = 0.0
const LIFETIME: float = 0.6

func _ready() -> void:
	var colors := [
		Color(1.0, 0.55, 0.0),
		Color(1.0, 0.25, 0.0),
		Color(1.0, 0.85, 0.1),
		Color(1.0, 0.1, 0.05),
	]

	for i in range(16):
		var p := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = randf_range(0.08, 0.22)
		sm.height = sm.radius * 2.0
		p.mesh = sm

		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[randi() % colors.size()]
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = 2.5
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		p.material_override = mat

		add_child(p)
		_particles.append(p)
		_materials.append(mat)

		var angle_h: float = randf() * TAU
		var angle_v: float = randf_range(-0.5, 0.5)
		var speed: float = randf_range(2.0, 8.0)
		_velocities.append(Vector3(
			cos(angle_h) * cos(angle_v) * speed,
			abs(sin(angle_v)) * speed * 0.5 + 1.0,
			sin(angle_h) * cos(angle_v) * speed
		))

func _process(delta: float) -> void:
	_timer += delta
	var t: float = _timer / LIFETIME

	if t >= 1.0:
		queue_free()
		return

	for i in range(_particles.size()):
		_particles[i].position += _velocities[i] * delta
		_velocities[i].y -= 5.0 * delta  # gravity
		_particles[i].scale = Vector3.ONE * (1.0 - t * 0.7)
		_materials[i].albedo_color.a = 1.0 - t
