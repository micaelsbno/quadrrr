extends RigidBody3D

# Car movement properties
@export var engine_force = 100.0
@export var steering_speed = 1.5
@export var steering_limit = 0.4

# Current steering angle
var steering = 0.0

func _physics_process(delta):
    # Get input
    var input = Vector2.ZERO
    input.x = Input.get_axis("ui_left", "ui_right")  # Steering
    input.y = Input.get_axis("ui_down", "ui_up")     # Acceleration/Brake
    
    # Apply engine force
    var force = transform.basis.z * engine_force * input.y
    apply_central_force(force)
    
    # Handle steering
    if abs(input.x) > 0:
        steering = move_toward(steering, input.x * steering_limit, steering_speed * delta)
    else:
        steering = move_toward(steering, 0, steering_speed * delta)
    
    # Apply rotation based on steering
    if abs(linear_velocity.length()) > 0.1:
        angular_velocity.y = steering * linear_velocity.length() * 0.1
