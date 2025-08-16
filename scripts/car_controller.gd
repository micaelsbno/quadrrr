extends RigidBody3D

# Car movement properties
@export var engine_force = 8000.0  # Increased force
@export var steering_speed = 2.0
@export var steering_limit = 0.5
@export var brake_force = 500.0

# Current steering angle
var steering = 0.0
var is_grounded = false

func _ready():
	# Make sure physics simulation is enabled
	freeze = false
	# Lock rotation except for Y axis (steering)
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	# Lock linear movement on Y axis to prevent bouncing
	axis_lock_linear_y = true

func _physics_process(delta):
	# Get input for steering and acceleration
	var forward = Input.get_action_strength("car_forward")
	var backward = Input.get_action_strength("car_backward")
	var left = Input.get_action_strength("car_left")
	var right = Input.get_action_strength("car_right")
	
	# Calculate input vectors
	var acceleration = forward - backward
	var steering_input = right - left
	
	# Check if we're touching the ground
	is_grounded = get_contact_count() > 0
	
	# Apply engine force in local Z direction
	if acceleration != 0:
		# Calculate forward direction in world space
		var forward_dir = -transform.basis.z.normalized()
		# Remove any vertical component to keep car on ground
		forward_dir.y = 0
		forward_dir = forward_dir.normalized()
		
		# Apply force
		var force = forward_dir * engine_force * acceleration
		apply_central_force(force)
		print("Forward direction: ", forward_dir)
		print("Applying force: ", force)
	
	# Apply braking
	if backward > 0 and linear_velocity.length() > 0.1:
		var brake = -linear_velocity.normalized() * brake_force
		brake.y = 0  # Don't apply vertical brake force
		apply_central_force(brake)
	
	# Handle steering
	if abs(steering_input) > 0:
		steering = move_toward(steering, steering_input * steering_limit, steering_speed * delta)
	else:
		steering = move_toward(steering, 0, steering_speed * delta)
	
	# Apply rotation based on steering
	if abs(linear_velocity.length()) > 0.1:
		var rotation_amount = steering * linear_velocity.length() * 0.002
		rotate_y(rotation_amount)
		print("Rotating by: ", rotation_amount)

	# Add some natural drag/friction
	var drag_force = -linear_velocity * 1.0  # Reduced drag
	drag_force.y = 0  # Don't apply vertical drag
	apply_central_force(drag_force)

	# Print debug info
	if acceleration != 0 or steering_input != 0:
		print("Input - Forward/Back: ", acceleration, " Left/Right: ", steering_input)
		print("Velocity: ", linear_velocity)
		print("Speed: ", linear_velocity.length())
		print("Position: ", global_position)
		print("Grounded: ", is_grounded)
		print("Contacts: ", get_contact_count())
