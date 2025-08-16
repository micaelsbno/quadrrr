extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var target: Node3D = $RigidBody3D

var follow_offset := Vector3(0, 2, -6)
var follow_speed := 8.0

func _process(delta):
	camera.make_current()
	if camera and target:
		var desired_pos = target.global_transform.origin + target.global_transform.basis * follow_offset
		camera.global_transform.origin = camera.global_transform.origin.lerp(desired_pos, delta * follow_speed)
		camera.look_at(target.global_transform.origin, Vector3.UP)
