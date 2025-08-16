extends RigidBody3D

# Car movement properties
@export var max_speed = 20.0
@export var acceleration = 50.0
@export var steering_speed = 3.0
@export var steering_limit = 0.8

# Current state
var current_speed = 0.0
var steering = 0.0

func _ready():
	# Basic physics setup
	gravity_scale = 3.0
	axis_lock_angular_x = true
	axis_lock_angular_z = true

func _physics_process(delta):
	# Get input
	var forward = Input.get_action_strength("car_forward")
	var backward = Input.get_action_strength("car_backward")
	var left = Input.get_action_strength("car_left")
	var right = Input.get_action_strength("car_right")
	
	# Calculate acceleration
	var target_speed = 0.0
	if forward > 0:
		target_speed = max_speed
	elif backward > 0:
		target_speed = -max_speed * 0.5  # Reverse is slower
	
	# Apply acceleration/deceleration
	if abs(target_speed) > 0:
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, acceleration * delta)
	
	# Apply movement
	if current_speed != 0:
		# Get forward direction and remove any vertical component
		var forward_dir = -transform.basis.z
		forward_dir.y = 0
		forward_dir = forward_dir.normalized()
		
		# Calculate velocity
		linear_velocity = forward_dir * current_speed
		
		# Handle steering
		var steering_input = right - left
		if abs(steering_input) > 0:
			steering = move_toward(steering, steering_input * steering_limit, steering_speed * delta)
		else:
			steering = move_toward(steering, 0, steering_speed * delta)
		
		# Apply rotation based on steering and speed
		if abs(current_speed) > 0.1:
			rotate_y(steering * delta * (current_speed / max_speed))
	
	# Debug output
	if forward > 0 or backward > 0:
		print("Speed: ", current_speed)
		print("Velocity: ", linear_velocity)
		print("Position: ", global_position)
		print("Forward input: ", forward)
		print("Backward input: ", backward)
		print("Steering: ", steering)
